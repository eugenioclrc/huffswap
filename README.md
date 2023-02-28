<img align="right" width="150" height="150" top="100" src="./assets/blueprint.png">

# huffswap AMM • [![ci](https://github.com/huff-language/huff-project-template/actions/workflows/ci.yaml/badge.svg)](https://github.com/eugenioclrc/huffswap/actions/actions/workflows/ci.yaml) ![license](https://img.shields.io/github/license/huff-language/huff-project-template.svg) ![solidity](https://img.shields.io/badge/solidity-^0.8.15-lightgrey)

A Huff implementation of UniswapV1.

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