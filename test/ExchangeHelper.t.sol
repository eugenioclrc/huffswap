// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

interface Foo {
    function addLiquidity(uint256 lpMinted, uint256 maxAmountTokens, address token)
        external
        payable
        returns (uint256 amount, uint256 amount2);
}

contract ERC20Mock is ERC20("Mock", "MOCK", 18) {
    constructor() {
        _mint(msg.sender, 1000000000000000000000000);
    }
}

contract ExchangeHelperTest is Test {
    address deployed;
    ERC20Mock token;

    function setUp() public {
        deployed = HuffDeployer.config().deploy("mocks/TestExchangeHelp");

        token = new ERC20Mock();
    }

    /*
    function testAddLiquidityFirst(uint256 maxTokens, uint256 eth) public {
        vm.assume(eth > 0);
        vm.assume(eth < 10 ether);
        vm.assume(maxTokens > 0);

        (uint256 expectedMint, uint256 expectedTokens) = calcLiquidity(0, eth, 0, maxTokens, eth);

        (uint256 mintLpAmount, uint256 tokens) = Foo(deployed).addLiquidity{value: eth}(0, maxTokens, address(token));
        assertEq(tokens, expectedTokens, "Should have 100 tokens");
        assertEq(mintLpAmount, expectedMint, "Should have 100 eth"); 
    }
    */

    function calcLiquidity(
        uint256 total_liquidity,
        uint256 eth_reserve,
        uint256 token_reserve,
        uint256 maxTokens,
        uint256 value
    ) internal pure returns (uint256 liquidity_minted, uint256 token_amount) {
        if (total_liquidity > 0) {
            // nB = (B * nA) / A
            token_amount = value * token_reserve / eth_reserve;
            liquidity_minted = value * total_liquidity / eth_reserve;
        } else {
            token_amount = maxTokens;
            liquidity_minted = value;
        }
    }

    function testAddLiquidityFuzz(
        uint256 lpSupply,
        uint256 eth_reserve,
        uint256 tokens_reserve,
        uint256 maxTokens,
        uint256 value
    ) public {
        lpSupply = bound(lpSupply, 1 ether, 10 ether);
        eth_reserve = bound(eth_reserve, 1 ether, 10 ether);
        tokens_reserve = bound(tokens_reserve, 1 ether, 10 ether);
        value = bound(value, 1 ether, 10 ether);
        maxTokens = bound(maxTokens, 1 ether, 10 ether);

        deal(deployed, eth_reserve);
        deal(address(token), deployed, tokens_reserve);

        (uint256 expectedMint, uint256 expectedTokens) =
            calcLiquidity(lpSupply, eth_reserve, tokens_reserve, maxTokens, value);

        (uint256 mintLpAmount, uint256 tokens) =
            Foo(deployed).addLiquidity{value: value}(lpSupply, maxTokens, address(token));

        assertEq(tokens, expectedTokens, "Should have tokens");
        assertEq(mintLpAmount, expectedMint, "Should have eth");
    }
}
