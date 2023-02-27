// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Token} from "src/mocks/Token.sol";

contract PriceCallMacros {
    Token public token;

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
    }

    /* events */
    event EthPurchase(address indexed buyer, address recipient, uint256 tokens_sold, uint256 eth_bought);

    event TokenPurchase(address indexed buyer, address recipient, uint256 eth_sold, uint256 tokens_bought);

    /* errors */
    error ErrDeadlineExpired(uint256 deadline);
    error ErrZero();
    error ErrEthOutput(uint256 min_eth);
    error ErrTokensOutpur(uint256 min_tokens);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline, address recipient, address tokenAddress)
        public
        payable
        returns (uint256 tokens_bought)
    {
        if (deadline < block.timestamp) {
            revert ErrDeadlineExpired(deadline);
        }
        if (msg.value == 0) {
            revert ErrZero();
        }
        if (min_tokens == 0) {
            revert ErrZero();
        }

        uint256 token_reserve = ERC20(tokenAddress).balanceOf(address(this));
        tokens_bought = getInputPrice(msg.value, address(this).balance - msg.value, token_reserve);
        // uint256 input_amount,
        // uint256 input_reserve,
        // uint256 output_reserve
        if (tokens_bought < min_tokens) {
            revert ErrTokensOutpur(min_tokens);
        }

        ERC20(tokenAddress).transfer(recipient, tokens_bought);

        emit TokenPurchase(msg.sender, recipient, msg.value, tokens_bought);
    }

    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient,
        address tokenAddress
    ) public returns (uint256 eth_bought) {
        if (deadline <= block.timestamp) {
            revert ErrDeadlineExpired(deadline);
        }

        if (tokens_sold == 0) {
            revert ErrZero();
        }
        if (min_eth == 0) {
            revert ErrZero();
        }

        uint256 token_reserve = ERC20(tokenAddress).balanceOf(address(this));

        eth_bought = getInputPrice(tokens_sold, token_reserve, address(this).balance);
        if (eth_bought < min_eth) {
            revert ErrEthOutput(min_eth);
        }

        // todo: use safeTransferFrom
        ERC20(tokenAddress).transferFrom(msg.sender, address(this), tokens_sold);

        // todo: use safeTransferETH
        (bool success,) = recipient.call{value: eth_bought}("");
        require(success, "transfer failed");

        emit EthPurchase(msg.sender, recipient, tokens_sold, eth_bought);
    }

    function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve)
        public
        pure
        returns (uint256)
    {
        unchecked {
            uint256 input_amount_with_fee = input_amount * 997;
            uint256 numerator = input_amount_with_fee * output_reserve;
            uint256 denominator = (input_reserve * 1000) + input_amount_with_fee;
            return numerator / denominator;
        }
    }

    function getEthToTokenInputPrice(uint256 eth_sold, address tokenAddress)
        public
        view
        returns (uint256 tokens_bought)
    {
        if (eth_sold == 0) {
            revert ErrZero();
        }
        uint256 token_reserve = ERC20(tokenAddress).balanceOf(address(this));

        if (token_reserve == 0) {
            revert ErrZero();
        }
        return getInputPrice(eth_sold, address(this).balance, token_reserve);
    }

    function getTokenToEthInputPrice(uint256 tokens_sold, address tokenAddress)
        public
        view
        returns (uint256 eth_bought)
    {
        if (tokens_sold == 0) {
            revert ErrZero();
        }
        uint256 token_reserve = ERC20(tokenAddress).balanceOf(address(this));
        return getInputPrice(tokens_sold, token_reserve, address(this).balance);
    }
}

contract PriceCallMacrosTest is Test {
    Token public token;
    PriceCallMacros public helper;
    PriceCallMacros public exchange;

    uint256 initialEthBalance = 99 ether;
    uint256 initialTokenBalance = 232 ether;

    address user = makeAddr("user");

    function setUp() public {
        token = new Token("token", "tkn");
        helper = PriceCallMacros(HuffDeployer.config().deploy("mocks/TestSwapHelp"));
        exchange = new PriceCallMacros(address(token));

        vm.label(address(token), "token");
        vm.label(address(this), "original");
        vm.label(address(helper), "helper");
        vm.label(address(exchange), "exchange");

        _resetBalances();
    }

    function _resetBalances() internal {
        deal(address(exchange), initialEthBalance);
        deal(address(token), address(exchange), initialTokenBalance);

        deal(address(helper), initialEthBalance);
        deal(address(token), address(helper), initialTokenBalance);

        deal(user, 100 ether);
        deal(address(token), user, 76 ether);

        vm.startPrank(user);
        token.approve(address(exchange), type(uint256).max);
        token.approve(address(helper), type(uint256).max);
        vm.stopPrank();
    }

    function test_ethToTokenSwapInput() external {
        uint256 min_tokens = 10 ether;
        uint256 deadline = block.timestamp + 1 days;

        uint256 value = 10 ether;

        vm.prank(user);
        uint256 expectedTokenBought =
            exchange.ethToTokenSwapInput{value: value}(min_tokens, deadline, user, address(token));
        uint256 expectedTokenBalance = token.balanceOf(user);
        uint256 expectedEthBalance = address(user).balance;

        _resetBalances();

        vm.prank(user);
        uint256 actualTokenBought = helper.ethToTokenSwapInput{value: value}(min_tokens, deadline, user, address(token));
        uint256 actualTokenBalance = token.balanceOf(user);
        uint256 actualEthBalance = address(user).balance;

        assertEq(expectedTokenBought, actualTokenBought);
        assertEq(expectedEthBalance, actualEthBalance);
        assertEq(expectedTokenBalance, actualTokenBalance);
    }

    function test_tokenToEthSwapInput() external {
        uint256 tokens_sold = 65 ether;
        uint256 min_eth = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        vm.prank(user);
        uint256 expectedEthBought = helper.tokenToEthSwapInput(tokens_sold, min_eth, deadline, user, address(token));
        uint256 expectedTokenBalance = token.balanceOf(user);
        uint256 expectedEthBalance = address(user).balance;

        _resetBalances();

        vm.prank(user);
        uint256 actualEthBought = exchange.tokenToEthSwapInput(tokens_sold, min_eth, deadline, user, address(token));
        uint256 actualTokenBalance = token.balanceOf(user);
        uint256 actualEthBalance = address(user).balance;

        assertEq(expectedEthBought, actualEthBought);
        assertEq(expectedEthBalance, actualEthBalance);
        assertEq(expectedTokenBalance, actualTokenBalance);
    }

    function test_getEthToTokenInputPrice() external {
        uint256 ethSold = 1 ether;

        uint256 expected = exchange.getEthToTokenInputPrice(ethSold, address(token));
        uint256 actual = helper.getEthToTokenInputPrice(ethSold, address(token));

        assertEq(actual, expected);
    }

    function test_fuzz_getEthToTokenInputPrice(uint256 balance, uint256 tokenBalance, uint256 ethSold) external {
        vm.assume(balance != 0);
        vm.assume(tokenBalance != 0);
        vm.assume(ethSold != 0);

        deal(address(exchange), balance);
        deal(address(token), address(exchange), tokenBalance);

        deal(address(helper), balance);
        deal(address(token), address(helper), tokenBalance);

        uint256 expected = exchange.getTokenToEthInputPrice(ethSold, address(token));
        uint256 actual = helper.getTokenToEthInputPrice(ethSold, address(token));
        assertEq(actual, expected);
    }

    function test_getTokenToEthInputPrice() external {
        uint256 balance = 10 ether;
        uint256 tokenBalance = 5 ether;
        uint256 tokensSold = 1 ether;

        deal(address(exchange), balance);
        deal(address(token), address(exchange), tokenBalance);

        deal(address(helper), balance);
        deal(address(token), address(helper), tokenBalance);

        uint256 expected = exchange.getTokenToEthInputPrice(tokensSold, address(token));
        uint256 actual = helper.getTokenToEthInputPrice(tokensSold, address(token));

        assertEq(actual, expected);
    }

    function test_fuzz_getTokenToEthInputPrice(uint256 balance, uint256 tokenBalance, uint256 tokensSold) external {
        vm.assume(balance != 0);
        vm.assume(tokenBalance != 0);
        vm.assume(tokensSold != 0);

        deal(address(exchange), balance);
        deal(address(token), address(exchange), tokenBalance);

        deal(address(helper), balance);
        deal(address(token), address(helper), tokenBalance);

        uint256 expected = exchange.getTokenToEthInputPrice(tokensSold, address(token));
        uint256 actual = helper.getTokenToEthInputPrice(tokensSold, address(token));
        assertEq(actual, expected);
    }

    function test_getInputPrice() external {
        uint256 input_amount = 100;
        uint256 input_reserve = 999;
        uint256 output_reserve = 800;
        uint256 expected = exchange.getInputPrice(input_amount, input_reserve, output_reserve);

        uint256 actual = helper.getInputPrice(input_amount, input_reserve, output_reserve);
        assertEq(actual, expected);
    }

    function test_fuzz_getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) external {
        vm.assume(input_reserve != 0);
        uint256 expected = exchange.getInputPrice(input_amount, input_reserve, output_reserve);

        uint256 actual = helper.getInputPrice(input_amount, input_reserve, output_reserve);
        assertEq(actual, expected);
    }
}
