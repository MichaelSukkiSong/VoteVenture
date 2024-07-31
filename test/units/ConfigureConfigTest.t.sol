// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ConfigureConfig} from "../../script/ConfigureConfig.s.sol";

contract ConfigureConfigTetst is Test {
    ConfigureConfig configureConfig;
    address MainnetETHUSDPriceFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address SepoliaTestnetETHUSDPriceFeed =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function setUp() public {
        configureConfig = new ConfigureConfig();
    }

    function test_ConfigFunctionIsCalledDependingOnChain() public {
        address expected;

        if (block.chainid == 1) {
            expected = MainnetETHUSDPriceFeed;
        } else if (block.chainid == 11133111) {
            expected = SepoliaTestnetETHUSDPriceFeed;
        } else {
            expected = configureConfig.getAnvilConfig().priceFeedAddress;
        }

        address actual = configureConfig.activeNetworkConfig();
        assertEq(actual, expected);
    }
}
