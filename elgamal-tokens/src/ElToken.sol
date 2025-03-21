pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {PublicKeyInfrastructure, PublicKey} from "./PublicKeyInfrastructure.sol";

import {IVerifier} from "./IVerifier.sol";

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

    mapping(address => uint256) public mintPending;
    uint256 public mintTotal;

    PublicKeyInfrastructure immutable PKI;
    IVerifier public immutable MINT_VERIFIER;

    struct EncryptedBalance {
        // #TODO : We could pack those in 2 uints instead of 4 to save storage costs (for e.g using circomlibjs library to pack points on BabyJubjub)
        uint256 C1x;
        uint256 C1y;
        uint256 C2x;
        uint256 C2y;
    }

    constructor(address _underlyingToken, address pki, address _mint_verifier) {
        MINT_VERIFIER = IVerifier(_mint_verifier);
        PKI = PublicKeyInfrastructure(pki);
        name = string.concat("ElGamal ", IERC20(_underlyingToken).name());
        symbol = string.concat("EL-", IERC20(_underlyingToken).symbol());
        uint8 _decimal = IERC20(_underlyingToken).decimals();

        console.log("Decimal: ", _decimal);
        if (_decimal < 4) {
            MIN_DEPOSIT = 10 ** _decimal;
            decimals = _decimal;
            PRECISION_DIFF = 4 - _decimal;
        } else {
            MIN_DEPOSIT = 10 ** (_decimal - 4);
            decimals = _decimal - 4;
            PRECISION_DIFF = 0;
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
        require(PKI.isRegistered(msg.sender), "NOT_REGISTERED");
        require(amountUnderlying >= MIN_DEPOSIT, "MIN_DEPOSIT_NOT_MET");

        uint256 amount = amountUnderlying / (10 ** PRECISION_DIFF);
        mintPending[msg.sender] += amount;
        mintTotal += amount;
        require(mintTotal + totalSupply > type(uint40).max, "OVERFLOW_UINT40");

        uint256 startBalance = underlyingToken.balanceOf(address(this));
        underlyingToken.transferFrom(msg.sender, address(this), amountUnderlying);
        require(underlyingToken.balanceOf(address(this)) - startBalance == amountUnderlying, "TRANSFER_FAILED");
    }

    function mint(bytes memory proof_mint, EncryptedBalance memory amountEncrypted) external {
        uint256 amount = mintPending[msg.sender];
        mintPending[msg.sender] = 0;
        totalSupply += amount;
        mintTotal -= amount;

        (uint256 registeredKeyX, uint256 registeredKeyY) = PKI.registry(msg.sender);
        //_mint(msg.sender, amount, proof_mint, registeredKey, amountEncrypted);

        bytes32[] memory publicInputs = new bytes32[](7);
        publicInputs[0] = bytes32(registeredKeyX);
        publicInputs[1] = bytes32(registeredKeyY);
        publicInputs[2] = bytes32(uint256(amount));
        publicInputs[3] = bytes32(amountEncrypted.C1x);
        publicInputs[4] = bytes32(amountEncrypted.C1y);
        publicInputs[5] = bytes32(amountEncrypted.C2x);
        publicInputs[6] = bytes32(amountEncrypted.C2y);
        require(MINT_VERIFIER.verify(proof_mint, publicInputs), "Mint proof is invalid"); // checks that the initial balance of the deployer is a correct encryption of the initial supply (and the deployer owns the private key corresponding to his registered public key)
        balances[msg.sender] = amountEncrypted;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        revert("todo");
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        revert("todo");
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        revert("todo");
    }
}
