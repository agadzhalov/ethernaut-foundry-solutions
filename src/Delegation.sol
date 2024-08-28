// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script, console} from "forge-std/Script.sol";


contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public {
        console.log("pwn");
        owner = msg.sender;
    }
}

contract Delegation {
    address public owner;
    Delegate delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        console.log("vlezz");
        console.logBytes(msg.data);
        (bool result,) = address(delegate).delegatecall(msg.data);
        console.log(result);
        if (result) {
            this;
        }
    }
}