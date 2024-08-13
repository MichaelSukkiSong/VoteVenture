// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {DeployVentureFactory} from "../../script/DeployVentureFactory.s.sol";
import {VentureFactory, Venture} from "../../src/Venture.sol";
import {CreateVenture, FundVenture, CreateRequestVenture, ApproveRequestVenture, FinalizeRequestVenture} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    VentureFactory ventureFactory;
    DeployVentureFactory deployVentureFactory;

    function setUp() public {
        deployVentureFactory = new DeployVentureFactory();
        ventureFactory = deployVentureFactory.run();

        // address[] memory deployedVentures = ventureFactory
        //     .getDeployedVentures();
        // venture = Venture(deployedVentures[0]);
    }

    function test_CreateVenture() public {
        CreateVenture createVenture = new CreateVenture();
        createVenture.createVenture(address(ventureFactory));

        assertEq(ventureFactory.getDeployedVentures().length, 1);
    }

    modifier createdVenture() {
        CreateVenture createVenture = new CreateVenture();
        createVenture.createVenture(address(ventureFactory));
        _;
    }

    function test_UserCanFundVenture() public createdVenture {
        FundVenture fundVenture = new FundVenture();
        fundVenture.fundVenture(address(ventureFactory));

        assertEq(
            ventureFactory.getDeployedVentures()[0].balance,
            fundVenture.FUND_AMOUNT()
        );
    }

    modifier funded() {
        FundVenture fundVenture = new FundVenture();
        fundVenture.fundVenture(address(ventureFactory));
        _;
    }

    function test_OwnerCanCreateRequest() public createdVenture funded {
        CreateRequestVenture createRequestVenture = new CreateRequestVenture();
        createRequestVenture.createRequestVenture(address(ventureFactory));

        assertEq(
            Venture(ventureFactory.getDeployedVentures()[0])
                .getRequestDescription(0),
            createRequestVenture.REQUEST_DESCRIPTION()
        );
        assertEq(
            Venture(ventureFactory.getDeployedVentures()[0]).getRequestAmount(
                0
            ),
            createRequestVenture.REQUEST_AMOUNT()
        );
        assertEq(
            Venture(ventureFactory.getDeployedVentures()[0])
                .getRequestRecipient(0),
            createRequestVenture.RECIPIENT()
        );
    }

    modifier createdRequest() {
        CreateRequestVenture createRequestVenture = new CreateRequestVenture();
        createRequestVenture.createRequestVenture(address(ventureFactory));
        _;
    }

    function test_UserCanApproveRequest()
        public
        createdVenture
        funded
        createdRequest
    {
        uint256 countBeforeApproval = Venture(
            ventureFactory.getDeployedVentures()[0]
        ).getRequestApprovalCount(0);
        ApproveRequestVenture approveRequestVenture = new ApproveRequestVenture();
        approveRequestVenture.approveRequestVenture(address(ventureFactory));
        uint256 countAfterApproval = Venture(
            ventureFactory.getDeployedVentures()[0]
        ).getRequestApprovalCount(0);

        assertEq(countAfterApproval, countBeforeApproval + 1);
    }

    modifier approvedRequest() {
        ApproveRequestVenture approveRequestVenture = new ApproveRequestVenture();
        approveRequestVenture.approveRequestVenture(address(ventureFactory));
        _;
    }

    function test_OwnerCanFinalizeRequest()
        public
        createdVenture
        funded
        createdRequest
        approvedRequest
    {
        FinalizeRequestVenture finalizeRequestVenture = new FinalizeRequestVenture();
        finalizeRequestVenture.finalizeRequestVenture(address(ventureFactory));

        assert(
            Venture(ventureFactory.getDeployedVentures()[0]).getRequestComplete(
                0
            )
        );
    }
}
