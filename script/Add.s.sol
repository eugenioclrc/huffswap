// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

import {IFactory} from "src/interfaces/IFactory.sol";
import {IExchange} from "src/interfaces/IExchange.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract ERC20Mock is ERC20("Mock", "MOCK", 18) {
    constructor() {
        _mint(msg.sender, 1000000000000000000000000);
    }
}

contract Deploy2 is Script {
    function run() public {
        vm.startBroadcast();
        ERC20Mock token = new ERC20Mock();

        // address exchange = 0x694e0D6136bD370E1654469Bcd22F3c7545ce2b4;

        address factory = 0xa6b091D1DBA5a3F672D3e4e4D1B6Bd9F53FcD1b6;

        IFactory _factory = IFactory(factory);
        address _token = address(token);

        address _exchange = _factory.createExchange(_token);

        token.approve(_exchange, type(uint256).max);
        uint256 gas = gasleft();
        IExchange(_exchange).addLiquidity{value: 1000}(1, 1010, block.timestamp + 99);
        gas = gas - gasleft();
        console.log("Total gas spend adding liquidity", gas);

        gas = gasleft();
        IExchange(_exchange).addLiquidity{value: 1000}(1, 1010, block.timestamp + 99);
        gas = gas - gasleft();
        console.log("Total gas spend adding liquidity", gas);
    }
}
