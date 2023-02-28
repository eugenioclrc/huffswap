// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";
import {IExchange} from "src/interfaces/ExpectedInterfaceExchange.sol";
import {IUniswapFactory} from "src/interfaces/IUniswapFactory.sol";

// forge script ./script/DeployLocal.s.sol --tc DeployLocal --rpc-url http://localhost:8545  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

contract Token is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract DeployLocal is Script {
    function run() public {
        address _factory = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;
        address exchangeImplementation = HuffDeployer
            .config()
            .set_broadcast(true)
            .with_addr_constant("FACTORY_ADDRESS", _factory)
            .deploy("Exchange");

        HuffDeployer
            .config()
            .with_addr_constant(
                "EXCHANGE_IMPLEMENTATION",
                exchangeImplementation
            )
            .set_broadcast(true)
            .deploy("Factory");

        IUniswapFactory factory = IUniswapFactory(_factory);

        vm.label(address(this), "deployer");
        vm.label(msg.sender, "sender");

        vm.startBroadcast();
        address[6] memory tokens = [
            address(new Token("Dai Stablecoin", "DAI", 18)),
            address(new Token("USD//C", "USDC", 6)),
            address(new Token("Tether", "USDT", 6)),
            address(new Token("Matic", "MATIC", 18)),
            address(new Token("Wrapped BTC", "WBTC", 8)),
            address(new Token("Wrapped Ether", "WETH", 18))
        ];

        Token newToken = new Token("New Weird Token", "NTKN", 10);
        newToken.mint(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 100 ether);
        console.log("new token", address(newToken));

        for (uint256 i = 0; i < 6; i++) {
            Token token = Token(tokens[i]);
            vm.label(address(token), token.symbol());
            token.mint(msg.sender, 100 ether);
            token.mint(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 100 ether);
            IExchange exchange = IExchange(factory.createExchange(tokens[i]));
            vm.label(
                address(exchange),
                string(abi.encodePacked("exchange: ", token.symbol()))
            );
            token.approve(address(exchange), type(uint256).max);
            exchange.addLiquidity{value: 100 ether}(
                1,
                100 ether,
                block.timestamp + 1 days
            );
            console.log("token:", token.symbol(), address(token), token.name());
            console.log("exchange:", address(exchange));
        }
        vm.stopBroadcast();
    }
}

// token: DAI 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 Dai Stablecoin
//   exchange: 0x75537828f2ce51be7289709686A69CbFDbB714F1
//   token: USDC 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 USD//C
//   exchange: 0xE451980132E65465d0a498c53f0b5227326Dd73F
//   token: USDT 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707 Tether
//   exchange: 0x5392A33F7F677f59e833FEBF4016cDDD88fF9E67
//   token: MATIC 0x0165878A594ca255338adfa4d48449f69242Eb8F Matic
//   exchange: 0xa783CDc72e34a174CCa57a6d9a74904d0Bec05A9
//   token: MATIC 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853 Wrapped BTC
//   exchange: 0xB30dAf0240261Be564Cea33260F01213c47AAa0D
//   token: WETH 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6 Wrapped Ether
//   exchange: 0x61ef99673A65BeE0512b8d1eB1aA656866D24296
