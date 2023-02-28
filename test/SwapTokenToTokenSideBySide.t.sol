// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "foundry-huff/HuffDeployer.sol";

import {UniV1Bytecode} from "src/uniswapv1/UniV1Bytecode.sol";
import {IUniswapFactory} from "src/interfaces/IUniswapFactory.sol";
import {IExchange} from "src/interfaces/ExpectedInterfaceExchange.sol";

import {Token} from "src/mocks/Token.sol";

import {Math} from "@openzeppelin/utils/math/Math.sol";

contract SwapTokenToTokenSideBySideTest is Test {
    address private bob = makeAddr("bob");

    IUniswapFactory private ufactory;
    IExchange private uexchange1;
    IExchange private uexchange2;

    IUniswapFactory private factory;
    IExchange private exchange1;
    IExchange private exchange2;

    Token private token1;
    Token private token2;

    function setUp() public {
        token1 = new Token("tkn1", "tkn1");
        token2 = new Token("tkn2", "tkn2");

        vm.label(address(token1), "token1");
        vm.label(address(token2), "token2");

        // huff
        address factoryAddress = 0x9aCe4Afab142FbCBc90e317977a6800076bD64bA;

        address exchange = HuffDeployer
            .config()
            .with_addr_constant("FACTORY_ADDRESS", factoryAddress)
            .deploy("Exchange");

        factory = IUniswapFactory(
            HuffDeployer
                .config()
                .with_addr_constant("EXCHANGE_IMPLEMENTATION", exchange)
                .deploy("Factory")
        );
        vm.label(address(factory), "huff:factory");

        exchange1 = IExchange(factory.createExchange(address(token1)));
        exchange2 = IExchange(factory.createExchange(address(token2)));

        token1.approve(address(exchange1), type(uint256).max);
        token2.approve(address(exchange2), type(uint256).max);

        vm.label(address(exchange1), "huff:exchange:token1");
        vm.label(address(exchange2), "huff:exchange:token2");

        // solidity

        UniV1Bytecode uniBytecode = new UniV1Bytecode();
        address exchangeImplementation = uniBytecode.deployExchange();
        ufactory = IUniswapFactory(uniBytecode.deployFactory());

        ufactory.initializeFactory(exchangeImplementation);

        uexchange1 = IExchange(ufactory.createExchange(address(token1)));
        uexchange2 = IExchange(ufactory.createExchange(address(token2)));

        token1.approve(address(uexchange1), type(uint256).max);
        token2.approve(address(uexchange2), type(uint256).max);

        vm.label(address(ufactory), "uni:factory");
        vm.label(address(uexchange1), "uni:exchange:token1");
        vm.label(address(uexchange2), "uni:exchange:token2");

        _resetBalances();
    }

    function _resetBalances() private {
        deal(address(token1), bob, 1000 ether);
        deal(address(token2), bob, 1000 ether);
        deal(bob, 1000 ether);

        deal(address(token1), address(uexchange1), 100 ether);
        deal(address(uexchange1), 100 ether);
        deal(address(token1), address(exchange1), 100 ether);
        deal(address(exchange1), 100 ether);

        deal(address(token2), address(uexchange2), 80 ether);
        deal(address(uexchange2), 80 ether);
        deal(address(token2), address(exchange2), 80 ether);
        deal(address(exchange2), 80 ether);

        vm.startPrank(bob);
        token1.approve(address(uexchange1), type(uint256).max);
        token1.approve(address(exchange1), type(uint256).max);
        token2.approve(address(uexchange2), type(uint256).max);
        token2.approve(address(exchange2), type(uint256).max);
        vm.stopPrank();
    }

    function test_swapTokenToToken() public {
        vm.prank(bob);
        uint256 expected = uexchange1.tokenToTokenSwapInput(
            1 ether,
            1,
            1,
            block.timestamp + 1,
            address(token2)
        );

        vm.prank(bob);
        uint256 actual = exchange1.tokenToTokenSwapInput(
            1 ether,
            1,
            1,
            block.timestamp + 1,
            address(token2)
        );

        assertEq(expected, actual);
    }
}
