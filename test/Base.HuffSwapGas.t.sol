// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "./BaseTest.sol";
import "foundry-huff/HuffDeployer.sol";

contract HuffswapGasTest is BaseTest {
    function setUp() public override {
        super.setUp();

        //address _factory = 0x4cf7fafd89861de660f7ebbe75033ab9ed31867b;

        //solExchange = address(new SolExchange(_factory));

        // address _factory = HuffDeployer.creation_code('Exchange').get_config_with_create_2(2);
        address _factory = 0x9aCe4Afab142FbCBc90e317977a6800076bD64bA;
        // address _exchange = HuffDeployer.get_config_with_create_2(1);

        exchange = HuffDeployer.config()
            .with_addr_constant("FACTORY_ADDRESS", _factory)
            // Huffswap V1
            .with_constant("META_NAME", "0x4875666673776170205631000000000000000000000000000000000000000000")
            // 11
            .with_constant("META_NAME_LENGTH", "0x0b")
            // "UNI-V1"
            .with_constant("META_SYMBOL", "0x554e492d56310000000000000000000000000000000000000000000000000000")
            .with_constant("META_SYMBOL_LENGTH", "0x06")
            .deploy("Exchange");

        factory = HuffDeployer.config()
            .with_addr_constant("EXCHANGE_IMPLEMENTATION", exchange)
            .deploy("Factory");

        vm.label(factory, "Factory");
        vm.label(exchange, "Exchange");

        _f = IUniswapFactory(factory);

        exchange_address = _f.createExchange(address(token));
        token.approve(exchange_address, type(uint256).max);
    }

    // uniswap v1 hack
    function testExchangeMetadata() public override {
        // LP metadata
        IExchange _exchange = IExchange(exchange_address);

        // 0x4875666673776170205631000000000000000000000000000000000000000000
        assertEq(_exchange.name(), "Huffswap V1");
        // 0x554e492d56310000000000000000000000000000000000000000000000000000
        assertEq(_exchange.symbol(), "UNI-V1");
        assertEq(_exchange.decimals(), 18);
    }
}
