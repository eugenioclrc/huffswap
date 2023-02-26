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
        address _factory = 0x9aCe4Afab142FbCBc90e317977a6800076bD64bA;

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

        vm.expectRevert();
        IExchange(_exchange).addLiquidity{value: 1000}(1, 1010, block.timestamp + 99); 

        token.approve(_exchange, 1010);
        IExchange(_exchange).addLiquidity{value: 1000}(1, 1010, block.timestamp + 99); 

    }
}
