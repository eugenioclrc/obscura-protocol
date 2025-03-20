pragma solidity ^0.8.17;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract ElToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 DEPOSIT_MULTIPLE;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    IERC20 immutable underlyingToken;

    mapping(address => uint256) public mintPending;

    constructor(
        string memory _name,
        string memory _symbol,
        address _underlyingToken
    ) {
        name = string.concat("ElGamal ", IERC20(_underlyingToken).name());
        symbol = string.concat("EL-", IERC20(_underlyingToken).symbol());
        uint8 _decimal = IERC20(_underlyingToken).decimals();

        if (_decimal < 4) {
            DEPOSIT_MULTIPLE = 10 ** _decimal;
            decimals = _decimal;
        } else {
            DEPOSIT_MULTIPLE = 10 ** _decimal - 4;
            decimals = _decimal - 4;
        }
        underlyingToken = IERC20(_underlyingToken);
    }

    function deposit(uint256 amount) external {
        require((amount / DEPOSIT_MULTIPLE) * DEPOSIT_MULTIPLE == amount, "INVALID_AMOUNT");
        mintPending[msg.sender] += amount;

        underlyingToken.transferFrom(msg.sender, address(this), amount);        
    }

    function mint() external {
        // todo
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