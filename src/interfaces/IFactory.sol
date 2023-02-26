// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
    function IMPLEMENTATION() external view returns (address exchangeImplementation);

    function tokenCount() external view returns (uint256);

    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);

    event NewExchange(address indexed token, address indexed exchange);

    function createExchange(address token) external returns (address payable exchange);
}
