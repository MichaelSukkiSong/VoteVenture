// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {DeployVenture} from "../../script/DeployVenture.s.sol";
import {Venture} from "../../src/Venture.sol";
import {FundVenture, CreateRequestVenture, ApproveRequestVenture, FinalizeRequestVenture} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    Venture venture;

    function setUp() public {
        DeployVenture deployVenture = new DeployVenture();
        venture = deployVenture.run();
    }

    function test_UserCanFundVenture() public {
        FundVenture fundVenture = new FundVenture();
        fundVenture.fundVenture(address(venture));

        assertEq(address(venture).balance, fundVenture.FUND_AMOUNT());
    }

    modifier funded() {
        FundVenture fundVenture = new FundVenture();
        fundVenture.fundVenture(address(venture));
        _;
    }

    function test_OwnerCanCreateRequest() public funded {
        CreateRequestVenture createRequestVenture = new CreateRequestVenture();
        createRequestVenture.createRequestVenture(address(venture));

        assertEq(
            venture.getRequestDescription(0),
            createRequestVenture.REQUEST_DESCRIPTION()
        );
        assertEq(
            venture.getRequestAmount(0),
            createRequestVenture.REQUEST_AMOUNT()
        );
        assertEq(
            venture.getRequestRecipient(0),
            createRequestVenture.RECIPIENT()
        );
    }

    modifier fundedAndCreatedRequest() {
        FundVenture fundVenture = new FundVenture();
        fundVenture.fundVenture(address(venture));

        CreateRequestVenture createRequestVenture = new CreateRequestVenture();
        createRequestVenture.createRequestVenture(address(venture));
        _;
    }

    function test_UserCanApproveRequest() public fundedAndCreatedRequest {
        uint256 countBeforeApproval = venture.getRequestApprovalCount(0);
        ApproveRequestVenture approveRequestVenture = new ApproveRequestVenture();
        approveRequestVenture.approveRequestVenture(address(venture));
        uint256 countAfterApproval = venture.getRequestApprovalCount(0);

        assertEq(countAfterApproval, countBeforeApproval + 1);
    }

    modifier fundedAndCreatedRequestAndApprovedRequest() {
        FundVenture fundVenture = new FundVenture();
        fundVenture.fundVenture(address(venture));

        CreateRequestVenture createRequestVenture = new CreateRequestVenture();
        createRequestVenture.createRequestVenture(address(venture));

        ApproveRequestVenture approveRequestVenture = new ApproveRequestVenture();
        approveRequestVenture.approveRequestVenture(address(venture));
        _;
    }

    function test_OwnerCanFinalizeRequest()
        public
        fundedAndCreatedRequestAndApprovedRequest
    {
        FinalizeRequestVenture finalizeRequestVenture = new FinalizeRequestVenture();
        finalizeRequestVenture.finalizeRequestVenture(address(venture));

        assert(venture.getRequestComplete(0));
    }
}
