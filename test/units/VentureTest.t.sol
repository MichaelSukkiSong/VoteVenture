// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployVenture} from "../../script/DeployVenture.s.sol";
import {Venture} from "../../src/Venture.sol";

contract VentureTest is Test {
    Venture venture;

    function setUp() public {
        DeployVenture deployer = new DeployVenture();
        venture = deployer.run();
    }

    function test_MinimumFundAmount() public view {
        uint256 expected = 5 * 10 ** 18;
        uint256 actual = venture.MINIMUM_FUND();
        assertEq(actual, expected);
    }

    function test_EntrepreneurIsSetToOwner() public view {
        address actual = venture.getEntrepreneur();

        assertEq(actual, msg.sender);
    }
}
