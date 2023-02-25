// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

contract PriceCallMacros {
    error ErrZero();

    function getInputPrice(
        uint256 input_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) public pure returns (uint256) {
        unchecked {
            uint256 input_amount_with_fee = input_amount * 997;
            uint256 numerator = input_amount_with_fee * output_reserve;
            uint256 denominator = (input_reserve * 1000) +
                input_amount_with_fee;
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

contract StandardToken is ERC20 {
    constructor() ERC20("ss", "ss", 18) {}
}

contract PriceCallMacrosTest is Test, PriceCallMacros {
    StandardToken public token;
    PriceCallMacros public helper;

    function setUp() public {
        token = new StandardToken();
        helper = PriceCallMacros(
            HuffDeployer.config().deploy("mocks/TestPriceCallMacrosHelp")
        );
    }

    function test_getEthToTokenInputPrice() external {
        uint256 balance = 10 ether;
        uint256 tokenBalance = 5 ether;
        uint256 ethSold = 1 ether;

        deal(address(this), balance);
        deal(address(token), address(this), tokenBalance);

        deal(address(helper), balance);
        deal(address(token), address(helper), tokenBalance);

        uint256 expected = getEthToTokenInputPrice(ethSold, address(token));
        uint256 actual = helper.getEthToTokenInputPrice(
            ethSold,
            address(token)
        );

        assertEq(actual, expected);
    }

    function test_fuzz_getEthToTokenInputPrice(
        uint256 balance,
        uint256 tokenBalance,
        uint256 ethSold
    ) external {
        vm.assume(balance != 0);
        vm.assume(tokenBalance != 0);
        vm.assume(ethSold != 0);

        deal(address(this), balance);
        deal(address(token), address(this), tokenBalance);

        deal(address(helper), balance);
        deal(address(token), address(helper), tokenBalance);

        uint256 expected = getTokenToEthInputPrice(ethSold, address(token));
        uint256 actual = helper.getTokenToEthInputPrice(
            ethSold,
            address(token)
        );
        assertEq(actual, expected);
    }

    function test_getTokenToEthInputPrice() external {
        uint256 balance = 10 ether;
        uint256 tokenBalance = 5 ether;
        uint256 tokensSold = 1 ether;

        deal(address(this), balance);
        deal(address(token), address(this), tokenBalance);

        deal(address(helper), balance);
        deal(address(token), address(helper), tokenBalance);

        uint256 expected = getTokenToEthInputPrice(tokensSold, address(token));
        uint256 actual = helper.getTokenToEthInputPrice(
            tokensSold,
            address(token)
        );

        assertEq(actual, expected);
    }

    function test_fuzz_getTokenToEthInputPrice(
        uint256 balance,
        uint256 tokenBalance,
        uint256 tokensSold
    ) external {
        vm.assume(balance != 0);
        vm.assume(tokenBalance != 0);
        vm.assume(tokensSold != 0);

        deal(address(this), balance);
        deal(address(token), address(this), tokenBalance);

        deal(address(helper), balance);
        deal(address(token), address(helper), tokenBalance);

        uint256 expected = getTokenToEthInputPrice(tokensSold, address(token));
        uint256 actual = helper.getTokenToEthInputPrice(
            tokensSold,
            address(token)
        );
        assertEq(actual, expected);
    }

    function test_getInputPrice() external {
        uint256 input_amount = 100;
        uint256 input_reserve = 999;
        uint256 output_reserve = 800;
        uint256 expected = getInputPrice(
            input_amount,
            input_reserve,
            output_reserve
        );

        uint256 actual = helper.getInputPrice(
            input_amount,
            input_reserve,
            output_reserve
        );
        assertEq(actual, expected);
    }

    function test_fuzz_getInputPrice(
        uint256 input_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) external {
        vm.assume(input_reserve != 0);
        uint256 expected = getInputPrice(
            input_amount,
            input_reserve,
            output_reserve
        );

        uint256 actual = helper.getInputPrice(
            input_amount,
            input_reserve,
            output_reserve
        );
        assertEq(actual, expected);
    }
}
