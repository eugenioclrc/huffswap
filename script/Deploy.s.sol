// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

contract Deploy is Script {
    function run() public returns (address factory, address exchange) {
        address _factory = 0xa6b091D1DBA5a3F672D3e4e4D1B6Bd9F53FcD1b6;
        exchange =
            HuffDeployer.config()
            .set_broadcast(true)
            .with_addr_constant("FACTORY_ADDRESS", _factory)
            // Huffswap V1
            .with_constant("META_NAME", "0x4875666673776170205631000000000000000000000000000000000000000000")
            // 11
            .with_constant("META_NAME_LENGTH", "0x0b")
            // "UNI-V1"
            .with_constant("META_SYMBOL", "0x554e492d56310000000000000000000000000000000000000000000000000000")
            .with_constant("META_SYMBOL_LENGTH", "0x06")
            .deploy("Exchange");

        factory = HuffDeployer.config().with_addr_constant("EXCHANGE_IMPLEMENTATION", exchange)
          .set_broadcast(true)
          .deploy("Factory");
        console.log("factory", factory);
    }
}
