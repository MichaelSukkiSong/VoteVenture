// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {VentureFactory} from "../src/Venture.sol";
import {ConfigureConfig} from "./ConfigureConfig.s.sol";

contract DeployVentureFactory is Script {
    function run() external returns (VentureFactory) {
        ConfigureConfig configureConfig = new ConfigureConfig();
        address priceFeedAddress = configureConfig.activeNetworkConfig();

        vm.startBroadcast();
        VentureFactory ventureFactory = new VentureFactory(priceFeedAddress);
        vm.stopBroadcast();

        return ventureFactory;
    }
}
