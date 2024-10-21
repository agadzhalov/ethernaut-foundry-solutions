// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DoubleEntryPoint, CryptoVault, Forta, LegacyToken} from "../src/DoubleEntryPoint.sol";
import "openzeppelin-contracts-08/contracts/token/ERC20/ERC20.sol";

/**
 * Solution
 * =====================================================================================
 * Part 1
 * As it is written in the requirement there's a bug in the CryptoVault and we have to find it and protect it.
 * What is the bug?
 * 1. CryptoVault contains 100 Legacy token. By requirement we can redeem them by calling sweepRedeem 
 * 2. The big is LegacyToken -> transfer() because "delegate" is the address of DET token.
 * 3. Meaning that when transfer() is executed actually DoubleEntryPoint -> delegateTransfer() is being executed
 * and instead of LegacyTokens DoubleEntryPointTokens are being transferred. This way the CryptoVault can be drained.
 * 
 * =====================================================================================
 * Part 2
 * We need to implement a bot that detects and notifes for this behaviour. 
 * 1. This means we must know what calldata is malicious, to have validation for that calldata and then to raise the
 * correct alerts
 * 2. We should raise alert when delegateTransfer is called from LegacyToken
 * 
 * Calldata to pass
 * 
 * 9cd1a121 - signature -> delegateTransfer(address,uint256,address)	
 * 000000000000000000000000_YOUR_PUBLIC_KEY_20_BYTES -> address YOUR_PUBLIC_KEY_20_BYTES -> recipient 
 * 0000000000000000000000000000000000000000000000056bc75e2d63100000 -> 56bc75e2d63100000 is 100000000000000000000 in dec
 * 000000000000000000000000a3db718524ed80c89881a236bc90face16db1cc0 -> address a3db718524ed80c89881a236bc90face16db1cc0
 * 
 * =====================================================================================
 * Part 3
 * 
 * We must implement the bot when "delegateTransfer()" is triggered from LegacyToken to raise alert from Forta.
 * We can raise alert from Forta by simply calling "raiseAlert()" and passing the address of the user as an argument.
 * 
 * May be you've noticed that the bot is IDetectionBot which means me must implement all of the methods in the interface.
 * Luckily the method is only one and it's "handleTransaction(address user, bytes calldata msgData)". 
 * The only thing we need to check is whether the passed msg.data equals the calldata from part two. 
 * But since we cannot just check if (bytes == bytes) we must hash it with keccak
 * So the method would like this
 * 
 * function handleTransaction(address user, bytes calldata msgData) external {
 *       if (keccak256(msgData) == keccak256(hex"SOME BYTES OF CALLDATA HERE")) {
 *           forta.raiseAlert(user);
 *       }
 *   }
 */

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

contract Bot {
    Forta forta; 
    constructor(address _fortaAddr) {
        forta = Forta(_fortaAddr);
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        console.logBytes(msgData); // in order to get the calldata easier
        if (keccak256(msgData) == keccak256(hex"9cd1a121000000000000000000000000YOUR_PUBLIC_KEY0000000000000000000000000000000000000000000000056bc75e2d63100000000000000000000000000000a3db718524ed80c89881a236bc90face16db1cc0")) {
            forta.raiseAlert(user);
        }
    }
}

contract DoubleEntryPointScript is Script {

    function run() public {        
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        DoubleEntryPoint de = DoubleEntryPoint(0x028dBe4eE020e626A931AF64a390823d915B296F);
        CryptoVault cryptoVault = CryptoVault(de.cryptoVault());

        Bot bot = new Bot(address(de.forta()));
        de.forta().setDetectionBot(address(bot));

        cryptoVault.sweepToken(IERC20(de.delegatedFrom()));
        vm.stopBroadcast();
    }
}
