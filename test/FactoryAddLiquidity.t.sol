// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {IFactory} from "src/IFactory.sol";
import {IExchange} from "src/IExchange.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";


contract ERC20Mock is ERC20("Mock", "MOCK", 18) {
    constructor() {
        _mint(msg.sender, 1000000000000000000000000);
    }
}


interface IExchange2 {
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable 
    // 0 mstore // tokens_to_transfer
    // 0x20 mstore // liquidity_to_mint
    // 0x40 mstore // address
    // 0x60 mstore // max_tokens
    // 0x80 mstore // min_liquidity
    returns (uint256 tokens_to_transfer, uint256 liquiditytomint, address, uint256 max_tokensr2, uint256 min_liquidityr);
}

contract FactoryAddTest is Test {
    /// @dev Address of the SimpleStore contract.
    //SimpleStore public simpleStore;

    /// @dev Setup the testing environment.

    address internal factory;
    address internal exchange;
    address solExchange;

    ERC20Mock internal token = new ERC20Mock();
    ERC20Mock internal token2 = new ERC20Mock();

    function setUp() public {
        //address _factory = 0x4cf7fafd89861de660f7ebbe75033ab9ed31867b;

        //solExchange = address(new SolExchange(_factory));
        
        // address _factory = HuffDeployer.creation_code('Exchange').get_config_with_create_2(2);
        address _factory = 0x9aCe4Afab142FbCBc90e317977a6800076bD64bA;
        // address _exchange = HuffDeployer.get_config_with_create_2(1);

        exchange =
         HuffDeployer.config().with_addr_constant("FACTORY_ADDRESS", _factory).deploy("Exchange");

        factory = HuffDeployer.config().with_addr_constant("EXCHANGE_IMPLEMENTATION", exchange).deploy(
            "Factory"
        );

        vm.label(factory, "factory");
        vm.label(exchange, "exchange");
        vm.label(address(token), "token");
        vm.label(address(token2), "token2");
        
        assertEq(factory, _factory, "Factory address should be the same");
    }
    function testAddLiquidity() public {
        IFactory _factory = IFactory(factory);
        address _token = address(token);
        
        address _exchange = _factory.createExchange(_token);
        (uint256 tokens_to_transfer, uint256 liquiditytomint, address t, uint256 max_tokensr2, uint256 min_liquidityr)
        =IExchange2(_exchange).addLiquidity{value: 1000}(1, 1000, block.timestamp + 100); 

        console.log("tokens_to_transfer", tokens_to_transfer);
        console.log("liquiditytomint", liquiditytomint);
        console.log("token", t);
        console.log("max_tokensr2", max_tokensr2);
        console.log("min_liquidityr", min_liquidityr);
    }
}