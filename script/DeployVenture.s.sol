// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {Venture} from "../src/Venture.sol";
import {NetworkConfig} from "./NetworkConfig.s.sol";

contract DeployVenture is Script {
    function run() external returns (Venture) {
        NetworkConfig networkConfig = new NetworkConfig();
        address priceFeedAddress = networkConfig.activeNetworkConfig();

        vm.startBroadcast();
        Venture venture = new Venture(priceFeedAddress);
        vm.stopBroadcast();

        return venture;
    }
}
