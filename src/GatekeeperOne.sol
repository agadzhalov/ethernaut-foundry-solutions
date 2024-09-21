// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        console.log("gateOne passed");
        _;
    }

    modifier gateTwo() {
        console.log("gateTwo hit");
        console.log("gasleft", gasleft());
        console.log("division", gasleft() % 8191);
        require(gasleft() % 8191 == 0);
        console.log("gateTwo passed");
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        console.log("gate three");
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        console.log("gate three", "1");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        console.log("gate three", "2");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        console.log("gate three", "3");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}