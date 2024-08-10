// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {Venture, VentureFactory} from "../src/Venture.sol";

contract CreateVenture is Script {
    function createVenture(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        VentureFactory(mostRecentlyDeployed).createVenture();
        vm.stopBroadcast();
        console.log("Created a new Venture");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "VentureFactory",
            block.chainid
        );

        createVenture(mostRecentlyDeployed);
    }
}

contract FundVenture is Script {
    uint256 public constant FUND_AMOUNT = 0.01 ether;

    function fundVenture(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Venture(VentureFactory(mostRecentlyDeployed).getDeployedVentures()[0])
            .fund{value: FUND_AMOUNT}();
        vm.stopBroadcast();
        console.log("Funded this Venture with %s", FUND_AMOUNT);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "VentureFactory",
            block.chainid
        );

        fundVenture(mostRecentlyDeployed);
    }
}

contract CreateRequestVenture is Script {
    string public constant REQUEST_DESCRIPTION = "Buy a new laptop";
    uint256 public constant REQUEST_AMOUNT = 0.005 ether;
    address public RECIPIENT = makeAddr("RECIPIENT");

    function createRequestVenture(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Venture(VentureFactory(mostRecentlyDeployed).getDeployedVentures()[0])
            .createRequest(
                REQUEST_DESCRIPTION,
                REQUEST_AMOUNT,
                payable(RECIPIENT)
            );
        vm.stopBroadcast();
        console.log(
            "Created a request to %s and pay %s to %s",
            REQUEST_DESCRIPTION,
            REQUEST_AMOUNT,
            RECIPIENT
        );
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "VentureFactory",
            block.chainid
        );

        createRequestVenture(mostRecentlyDeployed);
    }
}

contract ApproveRequestVenture is Script {
    function approveRequestVenture(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Venture(VentureFactory(mostRecentlyDeployed).getDeployedVentures()[0])
            .approveRequest(0);
        vm.stopBroadcast();
        console.log("Approved the request");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "VentureFactory",
            block.chainid
        );

        approveRequestVenture(mostRecentlyDeployed);
    }
}

contract FinalizeRequestVenture is Script {
    function finalizeRequestVenture(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Venture(VentureFactory(mostRecentlyDeployed).getDeployedVentures()[0])
            .finalizeRequest(0);
        vm.stopBroadcast();
        console.log("Finalized the request");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "VentureFactory",
            block.chainid
        );

        finalizeRequestVenture(mostRecentlyDeployed);
    }
}
