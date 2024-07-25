// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Venture} from "../src/Venture.sol";

contract DeployVenture is Script {
    function run() external returns (Venture) {
        vm.startBroadcast();
        Venture venture = new Venture();
        vm.stopBroadcast();

        return venture;
    }
}
