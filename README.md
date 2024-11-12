# Ethernaut Foundry Solutions by agadzhalov

## Prerequisites
Before running the scripts, ensure you have the following tools installed:

- Foundry

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Setup

1. `git clone` 
2. `forge build`
3. Create `.env` file with your account address and privete key

```
WALLLET_ADDRESS =
PRIVATE_KEY = 
```

## Solutions
1. All the solutions are in `/script` directory

## Solutions explained
1. You will find comments in every script `.sol` file that are explaining the solution

## How to run scripts
1. First you must replace the instance address from Ethernaut with your own in the script.
2. Let's take for example Fallback.s.sol. There you have to replace the address on line 18 with your instance.
3. You must have an RPC url. You can get one from Alchemy or Infura
4. In order to execute a script this is the pattern

```
forge script script/NAME_OF_THE_FILE.s.sol:NAME_OF_SCRIPT --rpc-url YOUR_RPC_URL --private-key YOUR_PRIVATE_KEY
```
5. To run `script/Fallback.s.sol` you have to execute 
```
forge script Fallback.s.sol:FallbackScript --rpc-url YOUR_RPC_URL --private-key YOUR_PRIVATE_KEY
```