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

contract FactoryTest is Test {
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

    function testImmutables() external {
        assertEq(IExchange(exchange).factory(), factory, "Factory address should be the same");
        assertEq(IFactory(factory).IMPLEMENTATION(), exchange, "Exchange address should be the same");
    }

    function testImplementation() public {
        IFactory _factory = IFactory(factory);
        assertEq(_factory.IMPLEMENTATION(), exchange);

        (bool sucess,) = factory.call("notImplemented");
        assertFalse(sucess);

        (sucess,) = factory.call(abi.encodeWithSignature("IMPLEMENTATION()"));
        assertTrue(sucess);

        assertEq(IExchange(exchange).factory(), factory, "Factory address should be the same");
    }

    function testAddress0() public {
        IFactory _factory = IFactory(factory);
        vm.expectRevert();
        _factory.createExchange(address(0));
        vm.expectRevert();
        _factory.createExchange(makeAddr("not a Contract"));
    }

    function testCreateExchange() public {
        IFactory _factory = IFactory(factory);

        assertEq(_factory.tokenCount(), 0);

        address rnd = makeAddr("no Contract");
        vm.expectRevert();
        _factory.createExchange(rnd);
    }

    // event created for the test
    event NewExchange(address indexed token, address indexed exchange);

    function testCreateExchangeEvent() public {
        IFactory _factory = IFactory(factory);
        address _token = address(token);
        
        vm.expectEmit(true, true, false, false, factory);
        emit NewExchange(_token, 0xa036a61eC2e3b2270F301D465Eae92D8b3B24f81);
        _factory.createExchange(_token);
        
    }

     function testAddLiquidity() public {
        IFactory _factory = IFactory(factory);
        address _token = address(token);
        
        address _exchange = _factory.createExchange(_token);
        IExchange(_exchange).addLiquidity{value: 1000}(1, 1000, block.timestamp + 100);


        
    }
        

    function testSetAndGetValueAdr() public {
        console.log("Factory", factory);
        console.log("Exchange", exchange);
        console.log("Token", address(token));
        console.log("Token2", address(token2));

        IFactory _factory = IFactory(factory);
        address _token = address(token);

        assertEq(_factory.getExchange(_token), address(0));

        assertEq(_factory.getToken(_token), address(0), "Token should be 0 because its not added yet");
        assertEq(_factory.getTokenWithId(1), address(0), "Token should be 0 because its not added yet");

        assertEq(_factory.tokenCount(), 0, "Token count should be 0, not token has been added yet");

        address newExchange = _factory.createExchange(_token);
        assertFalse(newExchange == address(0), "Exchange should be created and cant be address(0)");

        assertEq(IExchange(newExchange).tokenAddress(), _token, "Token address should be the same as the one added");

        assertEq(_factory.tokenCount(), 1, "Token count should be 1, 1 token has been added");

        assertEq(_factory.getTokenWithId(1), _token, "Token should be the same as the one added");

        assertEq(newExchange, _factory.createExchange(_token), "Exchange shouldnt be created cant be address(0)");
        assertEq(_factory.tokenCount(), 1);

        assertFalse(_factory.createExchange(address(token2)) == address(0));
        assertEq(_factory.tokenCount(), 2);
    }


     function testCreate() external {
        address t = address(token);
        uint256 g = gasleft();
        address e = IFactory(factory).createExchange(t);
console.log("totalgas",g - gasleft());
        assertEq(IExchange(e).factory(), factory, "Factory address should be the same");
    

        // shouldnt reinitialize
        vm.expectRevert();
        IExchange(e).initialize();

    }

    function testCantInitialize() external {
        vm.expectRevert();
        IExchange(exchange).initialize();

    }
}
