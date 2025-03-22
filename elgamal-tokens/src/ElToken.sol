pragma solidity ^0.8.17;

//import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {PublicKeyInfrastructure, PublicKey} from "./PublicKeyInfrastructure.sol";

import {IVerifier} from "./IVerifier.sol";

import {ElTokenFactory} from "./Factory.sol";

contract ElToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public immutable MIN_DEPOSIT;
    uint256 public immutable PRECISION_DIFF;

    uint256 public totalSupply;
    mapping(address => EncryptedBalance) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    IERC20 immutable underlyingToken;
    ElTokenFactory immutable FACTORY;

    mapping(address => uint256) public mintPending;
    uint256 public mintTotal;

    event PrivateTransfer(address indexed from, address indexed to);

    struct EncryptedBalance {
        // #TODO : We could pack those in 2 uints instead of 4 to save storage costs (for e.g using circomlibjs library to pack points on BabyJubjub)
        uint256 C1x;
        uint256 C1y;
        uint256 C2x;
        uint256 C2y;
    }

    constructor(address _underlyingToken) {
        FACTORY = ElTokenFactory(msg.sender);
        name = string.concat("ElGamal ", IERC20(_underlyingToken).name());
        symbol = string.concat("EL-", IERC20(_underlyingToken).symbol());
        uint8 _decimal = IERC20(_underlyingToken).decimals();

        if (_decimal < 4) {
            MIN_DEPOSIT = 0;
            decimals = _decimal;
            PRECISION_DIFF = 0;
        } else {
            MIN_DEPOSIT = 10 ** (_decimal - 4);
            decimals = _decimal - 4;
            PRECISION_DIFF = _decimal - 4;
        }
        underlyingToken = IERC20(_underlyingToken);
    }

    // @dev Returns amount but is not real, because is encrypted
    function balanceOf(address account) external view override returns (uint256 ret) {
        EncryptedBalance storage balance = balances[account];

        if (balance.C1x == 0 && balance.C1y == 0 && balance.C2x == 0 && balance.C2y == 0) {
            return ret;
        }
        unchecked {
            ret = balance.C1x + balance.C1y + balance.C2x + balance.C2y;
        }
        ret = ret == 0 ? 1 : ret;
    }

    function deposit(uint256 amountUnderlying) external {
        require(FACTORY.PKI().isRegistered(msg.sender), "NOT_REGISTERED");
        require(amountUnderlying >= MIN_DEPOSIT, "MIN_DEPOSIT_NOT_MET");

        uint256 amount = amountUnderlying / (10 ** PRECISION_DIFF);
        amountUnderlying = amount * (10 ** PRECISION_DIFF);
        mintPending[msg.sender] += amount;
        mintTotal += amount;
        require(mintTotal + totalSupply <= type(uint40).max, "OVERFLOW_UINT40");

        uint256 startBalance = underlyingToken.balanceOf(address(this));
        underlyingToken.transferFrom(msg.sender, address(this), amountUnderlying);
        require(underlyingToken.balanceOf(address(this)) - startBalance == amountUnderlying, "TRANSFER_FAILED");
    }

    function mint(bytes memory proof_mint, EncryptedBalance memory amountEncrypted) external {
        uint256 amount = mintPending[msg.sender];
        mintPending[msg.sender] = 0;
        totalSupply += amount;
        mintTotal -= amount;

        (uint256 registeredKeyX, uint256 registeredKeyY) = FACTORY.PKI().registry(msg.sender);
        //_mint(msg.sender, amount, proof_mint, registeredKey, amountEncrypted);

        bytes32[] memory publicInputs = new bytes32[](7);
        publicInputs[0] = bytes32(registeredKeyX);
        publicInputs[1] = bytes32(registeredKeyY);
        publicInputs[2] = bytes32(uint256(amount));
        publicInputs[3] = bytes32(amountEncrypted.C1x);
        publicInputs[4] = bytes32(amountEncrypted.C1y);
        publicInputs[5] = bytes32(amountEncrypted.C2x);
        publicInputs[6] = bytes32(amountEncrypted.C2y);
        require(FACTORY.MINT_VERIFIER().verify(proof_mint, publicInputs), "Mint proof is invalid"); // checks that the initial balance of the deployer is a correct encryption of the initial supply (and the deployer owns the private key corresponding to his registered public key)
        balances[msg.sender] = amountEncrypted;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        revert("NOT_IMPLEMENTED");
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        revert("NOT_IMPLEMENTED");
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        revert("NOT_IMPLEMENTED");
    }

    function transferPrivate(
        address to,
        EncryptedBalance calldata EncryptedBalanceOldMe,
        EncryptedBalance calldata EncryptedBalanceOldTo,
        EncryptedBalance calldata EncryptedBalanceNewMe,
        EncryptedBalance calldata EncryptedBalanceNewTo,
        bytes memory proof_transfer
    ) external returns (bool) {
        EncryptedBalance memory EncryptedBalanceOldMeNow = balances[msg.sender];
        EncryptedBalance memory EncryptedBalanceOldToNow = balances[to];

        (uint256 registeredKeyMeX, uint256 registeredKeyMeY) = FACTORY.PKI().registry(msg.sender);
        require(registeredKeyMeX + registeredKeyMeY != 0, "SENDER_NOT_REGISTERED");

        (uint256 registeredKeyToX, uint256 registeredKeyToY) = FACTORY.PKI().registry(to);
        require(registeredKeyToX + registeredKeyToY != 0, "RECEIVER_NOT_REGISTERED");


        // this requires is at the top of the transfer function, in order to limit gas spent in case of accidental front-running - front-running attack issue is already deterred thanks to the assert(value>=1) constraint inside the circuits (see comments in transfer/src/main.nr)
        require(EncryptedBalanceOldMeNow.C1x == EncryptedBalanceOldMe.C1x, "wrong C1x old me");
        require(EncryptedBalanceOldMeNow.C1y == EncryptedBalanceOldMe.C1y, "wrong C1y old me");
        require(EncryptedBalanceOldMeNow.C2x == EncryptedBalanceOldMe.C2x, "wrong C2x old me");
        require(EncryptedBalanceOldMeNow.C2y == EncryptedBalanceOldMe.C2y, "wrong C2y old me");

        require(EncryptedBalanceOldToNow.C1x == EncryptedBalanceOldTo.C1x, "wrong C1x old to");
        require(EncryptedBalanceOldToNow.C1y == EncryptedBalanceOldTo.C1y, "wrong C1y old to");
        require(EncryptedBalanceOldToNow.C2x == EncryptedBalanceOldTo.C2x, "wrong C2x old to");
        require(EncryptedBalanceOldToNow.C2y == EncryptedBalanceOldTo.C2y, "wrong C2y old to");

        require(msg.sender != to, "Cannot transfer to self");

        require(
            EncryptedBalanceOldMe.C1x + EncryptedBalanceOldMe.C1y + EncryptedBalanceOldMe.C1y
                + EncryptedBalanceOldMe.C2y != 0,
            "Sender has not received tokens yet"
        ); // this should never overflow because 4*p<type(uint256).max

        bool receiverAlreadyReceived = (
            EncryptedBalanceOldTo.C1x + EncryptedBalanceOldTo.C1y + EncryptedBalanceOldTo.C1y
                + EncryptedBalanceOldTo.C2y != 0
        ); // this should never overflow because 4*p<type(uint256).max

        if (receiverAlreadyReceived) {
            bytes32[] memory publicInputs = new bytes32[](20);
            publicInputs[0] = bytes32(registeredKeyMeX);
            publicInputs[1] = bytes32(registeredKeyMeY);

            publicInputs[2] = bytes32(registeredKeyToX);
            publicInputs[3] = bytes32(registeredKeyToY);

            publicInputs[4] = bytes32(EncryptedBalanceOldMe.C1x);
            publicInputs[5] = bytes32(EncryptedBalanceOldMe.C1y);
            publicInputs[6] = bytes32(EncryptedBalanceOldMe.C2x);
            publicInputs[7] = bytes32(EncryptedBalanceOldMe.C2y);

            publicInputs[8] = bytes32(EncryptedBalanceOldTo.C1x);
            publicInputs[9] = bytes32(EncryptedBalanceOldTo.C1y);
            publicInputs[10] = bytes32(EncryptedBalanceOldTo.C2x);
            publicInputs[11] = bytes32(EncryptedBalanceOldTo.C2y);

            publicInputs[12] = bytes32(EncryptedBalanceNewMe.C1x);
            publicInputs[13] = bytes32(EncryptedBalanceNewMe.C1y);
            publicInputs[14] = bytes32(EncryptedBalanceNewMe.C2x);
            publicInputs[15] = bytes32(EncryptedBalanceNewMe.C2y);

            publicInputs[16] = bytes32(EncryptedBalanceNewTo.C1x);
            publicInputs[17] = bytes32(EncryptedBalanceNewTo.C1y);
            publicInputs[18] = bytes32(EncryptedBalanceNewTo.C2x);
            publicInputs[19] = bytes32(EncryptedBalanceNewTo.C2y);

            require(FACTORY.TRANSFER_VERIFIER().verify(proof_transfer, publicInputs), "Transfer proof is invalid");
        } else {
            bytes32[] memory publicInputs = new bytes32[](16);
            publicInputs[0] = bytes32(registeredKeyMeX);
            publicInputs[1] = bytes32(registeredKeyMeY);

            publicInputs[2] = bytes32(registeredKeyToX);
            publicInputs[3] = bytes32(registeredKeyToY);

            publicInputs[4] = bytes32(EncryptedBalanceOldMe.C1x);
            publicInputs[5] = bytes32(EncryptedBalanceOldMe.C1y);
            publicInputs[6] = bytes32(EncryptedBalanceOldMe.C2x);
            publicInputs[7] = bytes32(EncryptedBalanceOldMe.C2y);

            publicInputs[8] = bytes32(EncryptedBalanceNewMe.C1x);
            publicInputs[9] = bytes32(EncryptedBalanceNewMe.C1y);
            publicInputs[10] = bytes32(EncryptedBalanceNewMe.C2x);
            publicInputs[11] = bytes32(EncryptedBalanceNewMe.C2y);

            publicInputs[12] = bytes32(EncryptedBalanceNewTo.C1x);
            publicInputs[13] = bytes32(EncryptedBalanceNewTo.C1y);
            publicInputs[14] = bytes32(EncryptedBalanceNewTo.C2x);
            publicInputs[15] = bytes32(EncryptedBalanceNewTo.C2y);

            require(
                FACTORY.TRANSFER_TO_NEW_VERIFIER().verify(proof_transfer, publicInputs),
                "Transfer to new address proof is invalid"
            );
        }
        balances[msg.sender] = EncryptedBalanceNewMe;
        balances[to] = EncryptedBalanceNewTo;

        emit PrivateTransfer(msg.sender, to);
        unchecked {
            emit Transfer(
                msg.sender,
                to,
                EncryptedBalanceNewTo.C1x + EncryptedBalanceNewTo.C1y + EncryptedBalanceNewTo.C2x
                    + EncryptedBalanceNewTo.C2y
            );
        }

        return true;
    }
}
