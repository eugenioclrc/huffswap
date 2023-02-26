// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "./BaseTest.sol";
import "src/uniswapv1/UniV1Bytecode.sol";

contract UniV1Test is BaseTest {
    function setUp() public override {
        super.setUp();

        UniV1Bytecode uniBytecode = new UniV1Bytecode();
        exchange = uniBytecode.deployExchange();

        factory = uniBytecode.deployFactory();

        // var to avoid verbosity
        _f = IUniswapFactory(factory);

        vm.label(factory, "Factory");
        vm.label(exchange, "Exchange");

        _f.initializeFactory(exchange);

        exchange_address = _f.createExchange(address(token));
        token.approve(exchange_address, type(uint256).max);
    }

    // uniswap v1 hack
    function testExchangeMetadata() public override {
        // LP metadata
        IExchange _exchange = IExchange(exchange_address);

        // -HACK univ1 response metadata is in bytes32 format and ERC20 standar in string
        (, bytes memory _name) = exchange_address.call(abi.encodeWithSignature("name()"));
        assertEq(bytes32(_name), bytes32("Uniswap V1"));
        (, bytes memory _symbol) = exchange_address.call(abi.encodeWithSignature("symbol()"));
        assertEq(bytes32(_symbol), bytes32("UNI-V1"));
        assertEq(_exchange.decimals(), 18);
    }
}
