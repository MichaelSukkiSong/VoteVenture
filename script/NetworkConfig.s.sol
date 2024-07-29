// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract NetworkConfig {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == 1) {
            activeNetworkConfig = getEthereumMainnetConfig();
        } else if (block.chainid == 11133111) {
            activeNetworkConfig = getSepoliaTestnetConfig();
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
}
