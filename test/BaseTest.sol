// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {Math} from "@openzeppelin/utils/math/Math.sol";
import "src/interfaces/IUniswapFactory.sol";
import {IExchange} from "src/interfaces/ExpectedInterfaceExchange.sol";

import "src/mocks/Token.sol";

abstract contract BaseTest is Test {
    address factory;
    address exchange;

    IUniswapFactory _f;

    address exchange_address;

    Token token = new Token("Stable ETH", "sETH");
    Token token2 = new Token("Stable ETH", "sETH");

    function setUp() public virtual {
        // block.timestamp is never 0 :S, so we can avoid undeflow checks;
        vm.warp(1);

        Token(token).mint(200 ether);
        Token(token2).mint(200 ether);

        vm.label(address(token), "Token 1");
        vm.label(address(token2), "Token 2");
    }

    function testExchangeMetadata() public virtual {
        // LP metadata
        IExchange _exchange = IExchange(exchange_address);

        assertEq(_exchange.name(), "Uniswap V1");
        assertEq(_exchange.symbol(), "UNI-V1");
        assertEq(_exchange.decimals(), 18);
    }

    /// @dev basic tests for the factory and exchange
    function testCreateExchange() public {
        assertEq(_f.tokenCount(), 1);
        assertEq(_f.getExchange(address(token2)), address(0));

        uint256 _gasleft = gasleft();
        address _foo = _f.createExchange(address(token2));
        console.log("gasUsage", _gasleft - gasleft());
        assertEq(_f.tokenCount(), 2);
        assertEq(_foo, _f.getExchange(address(token2)));

        assertEq(_f.getTokenWithId(0), address(0));
        assertEq(_f.getTokenWithId(1), address(token));
        assertEq(_f.getTokenWithId(2), address(token2));
        assertEq(_f.getTokenWithId(3), address(0));
    }

    function testAddLiquidity() public {
        assertEq(exchange_address, _f.getExchange(address(token)));

        IExchange _exchange = IExchange(exchange_address);

        vm.expectRevert();
        _exchange.addLiquidity{value: 0 ether}(0, 0, block.timestamp + 1);

        vm.expectRevert();
        _exchange.addLiquidity{value: 1 ether}(0, 1, block.timestamp);

        vm.expectRevert();
        _exchange.addLiquidity{value: 0}(0, 1, block.timestamp + 1);

        uint256 _gasleft = gasleft();
        _exchange.addLiquidity{value: 100 ether}(
            0,
            100 ether,
            block.timestamp + 1
        );
        console.log("gasUsage", _gasleft - gasleft());
        /*
        _gasleft = gasleft();
        _exchange.addLiquidity{value: 50 ether}(0, 50 ether, block.timestamp + 1);
        console.log("gasUsage 2", _gasleft - gasleft());

        assertEq(_exchange.totalSupply(), 150 ether);
        */
        assertEq(_exchange.totalSupply(), 100 ether);
    }

    function testRemoveLiquidity() public {
        IExchange _exchange = IExchange(exchange_address);

        uint256 addedLiquidity = _exchange.addLiquidity{value: 100 ether}(
            0,
            100 ether,
            block.timestamp + 1
        );

        uint256 etherPrev = address(this).balance;
        uint256 tokenPrev = token.balanceOf(address(this));

        //vm.expectRevert();
        //_exchange.removeLiquidity(addedLiquidity, 0, 0, block.timestamp + 1);
        uint256 _gasleft = gasleft();
        _exchange.removeLiquidity(addedLiquidity, 1, 1, block.timestamp + 1);
        console.log("gasUsage", _gasleft - gasleft());

        // this test its only for uni v1...
        // should have received 100 ether and 100 tokens
        assertEq(address(this).balance, etherPrev + 100 ether);
        assertEq(token.balanceOf(address(this)), tokenPrev + 100 ether);
    }

    function testSwapEthToken() public {
        IExchange _exchange = IExchange(exchange_address);

        _exchange.addLiquidity{value: 100 ether}(
            0,
            100 ether,
            block.timestamp + 1
        );

        uint256 swap1 = _exchange.getEthToTokenInputPrice(1 ether);
        uint256 swap10 = _exchange.getEthToTokenInputPrice(10 ether);
        assertGt(swap1, swap10 / 10);
        assertEq(swap1, 987158034397061298, "Wrong swap output 1 ether");
        assertEq(swap10, 9066108938801491315, "Wrong swap output 10 ether");

        // test K invariant
        uint256 etherBalance = address(_exchange).balance;
        uint256 tokenBalance = token.balanceOf(address(_exchange));
        uint256 oldK = etherBalance * tokenBalance;
        uint256 newK = (etherBalance + (1 ether * 997) / 1000) *
            (tokenBalance - swap1);

        assertGt(newK, oldK, "new K should be greater than old K");
        assertEq(oldK, 10**40);
        assertEq(newK, 10**40 + 85.894 ether);

        assertEq(
            Math.sqrt(oldK),
            Math.sqrt(newK),
            "sqrt(K) should be invariant"
        );

        uint256 ethBefore = address(this).balance;
        uint256 tokenBefore = token.balanceOf(address(this));

        vm.expectRevert();
        _exchange.ethToTokenSwapInput{value: 1 ether}(
            swap1 + 1,
            block.timestamp + 1
        );

        uint256 _gasleft = gasleft();
        _exchange.ethToTokenSwapInput{value: 1 ether}(
            swap1,
            block.timestamp + 1
        );
        console.log("gasUsage", _gasleft - gasleft());

        // spent 1 ether
        assertEq(ethBefore - address(this).balance, 1 ether);
        // received 85.894 tokens
        assertEq(token.balanceOf(address(this)) - tokenBefore, swap1);
    }

    function testSwapTokenEth() public {
        IExchange _exchange = IExchange(exchange_address);

        _exchange.addLiquidity{value: 100 ether}(
            0,
            100 ether,
            block.timestamp + 1
        );

        uint256 swap1 = _exchange.getTokenToEthInputPrice(1 ether);
        uint256 swap10 = _exchange.getTokenToEthInputPrice(10 ether);
        assertGt(swap1, swap10 / 10);
        assertEq(swap1, 987158034397061298, "Wrong swap output 1 ether");
        assertEq(swap10, 9066108938801491315, "Wrong swap output 10 ether");

        // test K invariant
        uint256 etherBalance = address(_exchange).balance;
        uint256 tokenBalance = token.balanceOf(address(_exchange));
        uint256 oldK = etherBalance * tokenBalance;
        uint256 newK = (etherBalance + (1 ether * 997) / 1000) *
            (tokenBalance - swap1);

        assertGt(newK, oldK, "new K should be greater than old K");
        assertEq(oldK, 10**40);
        assertEq(newK, 10**40 + 85.894 ether);

        assertEq(
            Math.sqrt(oldK),
            Math.sqrt(newK),
            "sqrt(K) should be invariant"
        );

        uint256 ethBefore = address(this).balance;
        uint256 tokenBefore = token.balanceOf(address(this));

        vm.expectRevert();
        _exchange.tokenToEthSwapInput(1 ether, swap1 + 1, block.timestamp + 1);

        uint256 _gasleft = gasleft();
        _exchange.tokenToEthSwapInput(1 ether, swap1, block.timestamp + 1);
        console.log("gasUsage", _gasleft - gasleft());

        // spent 1 ether tokens
        assertEq(tokenBefore - token.balanceOf(address(this)), 1 ether);
        assertEq(address(this).balance - ethBefore, 987158034397061298);
        assertEq(address(this).balance - ethBefore, swap1);
    }

    function testSwapMultipleTimes() public {
        IExchange _exchange = IExchange(exchange_address);

        _exchange.addLiquidity{value: 100 ether}(
            0,
            100 ether,
            block.timestamp + 1
        );

        address bob = makeAddr("bob");
        deal(bob, 1 ether);

        vm.startPrank(bob);
        token.approve(exchange_address, type(uint256).max);
        uint256 tokensBought;

        for (uint256 i; i < 100; ++i) {
            tokensBought = _exchange.ethToTokenSwapInput{value: bob.balance}(
                1,
                block.timestamp + 1
            );
            assertEq(tokensBought, token.balanceOf(bob));
            _exchange.tokenToEthSwapInput(tokensBought, 1, block.timestamp + 1);
        }

        vm.stopPrank();
        // magic number is the amount of ether after 100 swaps (tested on univ1)
        assertEq(1 ether - bob.balance, 449219912501890102);

        // should be greater than initial liquidity due to fees
        assertEq(
            address(_exchange).balance,
            100449219912501890102,
            "ether on LP wrong"
        );
        assertEq(token.balanceOf(address(_exchange)), 100 ether);
    }

    function testSwapTokenToToken() public {
        IExchange _exchange = IExchange(exchange_address);
        IExchange _exchange2 = IExchange(_f.createExchange(address(token2)));

        vm.label(address(_exchange), "exchange token 1");
        vm.label(address(_exchange2), "exchange token 2");
        vm.label(address(this), "user");

        _exchange.addLiquidity{value: 100 ether}(
            0,
            100 ether,
            block.timestamp + 1
        );
        token2.approve(address(_exchange2), type(uint256).max);
        _exchange2.addLiquidity{value: 80 ether}(
            0,
            80 ether,
            block.timestamp + 1
        );

        uint256 _gasleft = gasleft();
        _exchange.tokenToTokenSwapInput(
            1 ether,
            1,
            1,
            block.timestamp + 1,
            address(token2)
        );
        console.log("gasUsage", _gasleft - gasleft());
    }

    function testSwapTokesToTokenMultipleTimes() public {
        IExchange _exchange = IExchange(exchange_address);
        IExchange _exchange2 = IExchange(_f.createExchange(address(token2)));

        vm.label(address(_exchange), "exchange token 1");
        vm.label(address(_exchange2), "exchange token 2");
        vm.label(address(this), "user");

        _exchange.addLiquidity{value: 100 ether}(
            0,
            100 ether,
            block.timestamp + 1
        );
        token2.approve(address(_exchange2), type(uint256).max);
        _exchange2.addLiquidity{value: 80 ether}(
            0,
            80 ether,
            block.timestamp + 1
        );

        address bob = makeAddr("bob");
        deal(bob, 1 ether);

        vm.startPrank(bob);
        token.approve(exchange_address, type(uint256).max);
        token2.approve(address(_exchange2), type(uint256).max);
        uint256 tokensBought;
        uint256 newTokensBought;
        tokensBought = _exchange.ethToTokenSwapInput{value: bob.balance}(
            1,
            block.timestamp + 1
        );

        for (uint256 i; i < 100; ++i) {
            assertEq(tokensBought, token.balanceOf(bob));
            newTokensBought = _exchange.tokenToTokenSwapInput(
                tokensBought,
                1,
                1,
                block.timestamp + 1,
                address(token2)
            );
            assertEq(newTokensBought, token2.balanceOf(bob));
            tokensBought = _exchange2.tokenToTokenSwapInput(
                newTokensBought,
                1,
                1,
                block.timestamp + 1,
                address(token)
            );
        }

        // amount expexte according to univ1 (tested as a blackbox)
        assertEq(tokensBought, 300146760304738626);
        assertGt(address(_exchange).balance, 100 ether);
        assertGt(address(_exchange2).balance, 80 ether);

        vm.stopPrank();
    }

    receive() external payable {
        // fallback for burn liquidity
    }
}
