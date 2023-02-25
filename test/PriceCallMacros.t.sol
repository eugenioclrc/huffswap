// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

contract PriceCallMacros {
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
}

contract PriceCallMacrosTest is Test, PriceCallMacros {
    PriceCallMacros public getInputPriceHelper;

    function setUp() public {
        getInputPriceHelper = PriceCallMacros(
            HuffDeployer.config().deploy("mocks/TestGetInputPriceHelp")
        );
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

        uint256 actual = getInputPriceHelper.getInputPrice(
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

        uint256 actual = getInputPriceHelper.getInputPrice(
            input_amount,
            input_reserve,
            output_reserve
        );
        assertEq(actual, expected);
    }
}
