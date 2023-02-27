// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExchange {
    function factory() external view returns (address);
    function tokenAddress() external view returns (address);
    function initialize() external;
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline)
        external
        payable
        returns (uint256 liquidity_minted);
}
