// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract ConfigureConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == 1) {
            activeNetworkConfig = getEthereumMainnetConfig();
        } else if (block.chainid == 11133111) {
            activeNetworkConfig = getSepoliaTestnetConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getEthereumMainnetConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory EthereumMainnetConfig = NetworkConfig({
            priceFeedAddress: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return EthereumMainnetConfig;
    }

    function getSepoliaTestnetConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory sepoliaTestnetConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaTestnetConfig;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }

        // deploy a mock price feed in anvil
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeedAddress: address(mockV3Aggregator)
        });

        return anvilConfig;
    }
}
