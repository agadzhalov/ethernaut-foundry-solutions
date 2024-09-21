// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GatekeeperOne} from "../src/GatekeeperOne.sol";
import {Attacker} from "../script/GatekeeperOne.s.sol";

contract GateKeeperOneTest is Test {

    GatekeeperOne private target;
    Attacker private attacker;

    function setUp() public {
        target = GatekeeperOne(0xC01F24955aa62651fa88E19E9fe4d01DF97F2911);
        attacker = new Attacker(0xC01F24955aa62651fa88E19E9fe4d01DF97F2911);
    }
    
    function test() public {
        for (uint256 i = 100; i < 8191; i++) {
            try attacker.bypass(i) {
                console.log("gas", i);
            } catch {
                
            }
        }
    }

}