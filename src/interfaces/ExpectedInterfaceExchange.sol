// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

interface IExchange is IERC20, IERC20Metadata {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline)
        external
        payable
        returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline)
        external
        returns (uint256, uint256);

    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline, address recipient)
        external
        payable
        returns (uint256 tokens_bought);

    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline)
        external
        returns (uint256 eth_bought);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient)
        external
        returns (uint256 eth_bought);

    /// @dev User specifies exact input and minimum output.
    /// @param tokens_sold Amount of Tokens sold.
    /// @param min_tokens_bought Minimum Tokens (token_addr) purchased.
    /// @param min_eth_bought Minimum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param token_addr The address of the token being purchased.
    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_bought);
}
