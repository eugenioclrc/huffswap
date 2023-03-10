<img align="right" width="150" height="150" top="100" src="./assets/blueprint.png">

# huffswap AMM • [![ci](https://github.com/huff-language/huff-project-template/actions/workflows/ci.yaml/badge.svg)](https://github.com/eugenioclrc/huffswap/actions/actions/workflows/ci.yaml) ![license](https://img.shields.io/github/license/huff-language/huff-project-template.svg) ![solidity](https://img.shields.io/badge/solidity-^0.8.15-lightgrey)

A Huff implementation of UniswapV1.


**Why Uniswap V1 and not V2?**

This is a proof of concept for a hackathon; because we only have a limited amount of time, we chose to reimplement V1 because it is simpler than V2.

## Security concerns

To make it comparable to uniswap V1 i have to avoid using a Reentrancy guard this is just a POC of a minimal AMM with low gas consumptions build for the ETH Denver hackaton. DO NOT USE IT IN PRODUCTION.

## Gas Savings

| method           | Uniswap | Huffswap | delta  | percent cheaper |
|------------------|---------|----------|--------|-----------------|
| createExchange   | 227994  | 106858   | 121136 | 53,13%          |
| addLiquidity     | 99367   | 91304    | 8063   | 8,11%           |
| removeLiquidity  | 18150   | 14286    | 3864   | 21,29%          |
| swapEthToken     | 16250   | 12953    | 3297   | 20,29%          |
| swapTokenEth     | 16999   | 13595    | 3404   | 20,02%          |
| swapTokenToToken | 28406   | 20098    | 8308   | 29,25%          |


Lets make a gas budget, lets imagine 1 create pair, 5 add liquidity, 5 remove liquidity and 30 swaps (per each type of swap);

	
- Uniswap: 1432129
- Huffswap:  1101268


**Gas savings, around 30%** 

## Huffswap frontend

The Huffswap frontend is a fork of Uniswap frontend, you could find it in:
https://github.com/nicobevilacqua/huffswap-frontend

## Deployment

Huffswap has been deployed so far on
- [X] Mantle
- [X] Scroll
- [X] Neon EVM
- [X] Filecoin EVM
- [X] Polygon

### Mantle

Factory: 0xD9D26e61D8F02AF7e1Dd8A72313770E6B00EAabB
exchange: 0x8d867eC6107763cbfcCc71a98Cf3689E73d49C74


Deployed via created2 using this contract:
https://explorer.testnet.mantle.xyz/address/0xC26ab96b8d2Ad4E2e7e097025308Fe06d82255A1

### Scroll

Factory: [0x420fAd7011A85cc6C308941A7245b7c0E695Fe85](https://blockscout.scroll.io/address/0x420fAd7011A85cc6C308941A7245b7c0E695Fe85)<br />
Exchange: [0x7a479AAe93f97F00117571ee1e61bacaB2C780A1](https://blockscout.scroll.io/address/0x7a479AAe93f97F00117571ee1e61bacaB2C780A1)


### NEON EVM

factory: [0xfF6AE961405b4f3e3169e6640Cd1cA3083D58a7b](https://devnet.neonscan.org/tx/0x6bb8976515e8f097437379a506667f34456c406244deb512179a0b848af7a402)<br />
exchange: [0x2Ca416EA2F4bb26ff448823EB38e533b60875C81](https://devnet.neonscan.org/tx/0xf89c0b6d285f920e196b422a9a914fefdbdad723d0e8e942d73b40e3a5bfb22e)

### Filecoin EVM
factory: address [0xacBC672c3612b4417588f98e783f30694b8f83Cb](https://hyperspace.filfox.info/en/address/0xacBC672c3612b4417588f98e783f30694b8f83Cb)<br />
exchange: [0x77bA1c193661EeF8653C69F8f7f825DF47614518](https://hyperspace.filfox.info/en/address/0x77ba1c193661eef8653c69f8f7f825df47614518)


### Polygon

factory: address [0x420fAd7011A85cc6C308941A7245b7c0E695Fe85](https://mumbai.polygonscan.com/address/0x420fad7011a85cc6c308941a7245b7c0e695fe85)<br />
exchange: [0x7a479AAe93f97F00117571ee1e61bacaB2C780A1](https://mumbai.polygonscan.com/address/0x7a479AAe93f97F00117571ee1e61bacaB2C780A1)

## Getting Started

### Requirements

The following will need to be installed in order to use this template. Please follow the links and instructions.

-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    -   You'll know you've done it right if you can run `git --version`
-   [Foundry / Foundryup](https://github.com/gakonst/foundry)
    -   This will install `forge`, `cast`, and `anvil`
    -   You can test you've installed them right by running `forge --version` and get an output like: `forge 0.2.0 (92f8951 2022-08-06T00:09:32.96582Z)`
    -   To get the latest of each, just run `foundryup`
-   [Huff Compiler](https://docs.huff.sh/get-started/installing/)
    -   You'll know you've done it right if you can run `huffc --version` and get an output like: `huffc 0.3.0`

### Quickstart

1. Clone this repo or use template

Click "Use this template" on [GitHub](https://github.com/huff-language/huff-project-template) to create a new repository with this repo as the initial state.

Or run:

```
git clone https://github.com/huff-language/huff-project-template
cd huff-project-template
```

2. Install dependencies

Once you've cloned and entered into your repository, you need to install the necessary dependencies. In order to do so, simply run:

```shell
forge install
```

3. Build & Test

To build and test your contracts, you can run:

```shell
forge build
forge test
```

For more information on how to use Foundry, check out the [Foundry Github Repository](https://github.com/foundry-rs/foundry/tree/master/forge) and the [foundry-huff library repository](https://github.com/huff-language/foundry-huff).


## Blueprint

```ml
scripts
├─ Deploy.s.sol — Deployment Script
src
├─ Exchange — LP token implementation
├─ Factory  — Factory of LP Tokens
```


## License

[The Unlicense](https://github.com/huff-language/huff-project-template/blob/master/LICENSE)


## Acknowledgements

- [forge-template](https://github.com/foundry-rs/forge-template)
- [femplate](https://github.com/abigger87/femplate)
- [huffmate](https://github.com/pentagonxyz/huffmate)


## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk._