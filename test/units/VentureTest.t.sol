// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployVenture} from "../../script/DeployVenture.s.sol";
import {Venture} from "../../src/Venture.sol";

contract VentureTest is Test {
    Venture venture;

    address USER = makeAddr("USER");
    address USER_WHO_DID_NOT_FUND = makeAddr("USER_WHO_DID_NOT_FUND");
    address RECIPIENT = makeAddr("RECIPIENT");
    uint256 public constant INITIAL_BALANCE = 100 ether;
    uint256 public constant FUND_AMOUNT = 10 ether;
    uint256 public constant REQUEST_AMOUNT = 5 ether;
    string public constant REQUEST_DESCRIPTION = "some description";

    function setUp() public {
        DeployVenture deployer = new DeployVenture();
        venture = deployer.run();
        vm.deal(USER, INITIAL_BALANCE);
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

    /* fund function */

    function test_ShouldRevertIfLessThanMinimumFund() public {
        vm.prank(USER);
        vm.expectRevert();
        venture.fund();
    }

    function test_FundDataStructureShouldBeUpdatedAfterFunding() public {
        vm.prank(USER);
        venture.fund{value: 10 ether}();

        // check funders array
        address[] memory funders = venture.getFunders();

        address funder;
        for (uint256 i = 0; i < funders.length; i++) {
            funder = funders[i];
        }

        // check funderAmount mapping
        uint256 amount = venture.getFunderAmount(USER);

        assertEq(funder, USER);
        assertEq(amount, 10 ether);
    }

    modifier funded() {
        vm.prank(USER);
        venture.fund{value: FUND_AMOUNT}();
        _;
    }

    /* createRequest function */

    function test_OnlyEntrepreneurCanCreateRequest() public funded {
        vm.prank(USER);
        vm.expectRevert();
        venture.createRequest(
            REQUEST_DESCRIPTION,
            REQUEST_AMOUNT,
            payable(RECIPIENT)
        );
    }

    function test_RequestHasValidPropertiesAfterCreation() public funded {
        vm.prank(venture.getEntrepreneur());
        venture.createRequest(
            REQUEST_DESCRIPTION,
            REQUEST_AMOUNT,
            payable(RECIPIENT)
        );

        string memory actualDescription = venture.getRequestDescription(0);
        uint256 actualAmount = venture.getRequestAmount(0);
        address actualAddress = venture.getRequestRecipient(0);

        assertEq(actualDescription, REQUEST_DESCRIPTION);
        assertEq(actualAmount, REQUEST_AMOUNT);
        assertEq(actualAddress, RECIPIENT);
    }

    function test_RequestAmountShouldNotExceedTotalFundedAmount()
        public
        funded
    {
        vm.prank(venture.getEntrepreneur());
        vm.expectRevert();
        venture.createRequest(
            REQUEST_DESCRIPTION,
            20 ether,
            payable(RECIPIENT)
        );
    }

    function test_RequestsDataStructureShouldBeUpdatedAfterCreation()
        public
        funded
    {
        uint256 lengthBeforeRequestCreation = venture.getRequestCount();
        vm.prank(venture.getEntrepreneur());
        venture.createRequest(
            REQUEST_DESCRIPTION,
            REQUEST_AMOUNT,
            payable(RECIPIENT)
        );

        uint256 lengthAfterRequestCreation = venture.getRequestCount();

        assertEq(lengthAfterRequestCreation - lengthBeforeRequestCreation, 1);
    }

    modifier createdRequest() {
        vm.prank(venture.getEntrepreneur());
        venture.createRequest(
            REQUEST_DESCRIPTION,
            REQUEST_AMOUNT,
            payable(RECIPIENT)
        );

        _;
    }

    /* approveRequest function */

    function test_MustBeFunderToApproveRequest() public funded createdRequest {
        vm.prank(USER_WHO_DID_NOT_FUND);
        vm.expectRevert();
        venture.approveRequest(0);
    }

    function test_CannotApproveTwice() public funded createdRequest {
        vm.prank(USER);
        venture.approveRequest(0);

        vm.prank(USER);
        vm.expectRevert();
        venture.approveRequest(0);
    }

    function test_RequestShouldBeFinalizedAfterApproval()
        public
        funded
        createdRequest
    {
        vm.prank(USER);
        venture.approveRequest(0);

        bool actualApproval = venture.getRequestApprovals(0, USER);
        assertEq(actualApproval, true);
    }

    function test_RequestApprovalCountShouldIncreaseAfterApproval()
        public
        funded
        createdRequest
    {
        vm.prank(USER);
        venture.approveRequest(0);

        uint256 actualApprovalCount = venture.getRequestApprovalCount(0);
        assertEq(actualApprovalCount, 1);
    }

    modifier approvedRequest() {
        vm.prank(USER);
        venture.approveRequest(0);

        _;
    }

    /* finalizeRequest function */

    modifier fundedWithAdditionalFunders(uint160 _additionalNumberOfFunders) {
        for (uint160 i = 0; i < _additionalNumberOfFunders; i++) {
            hoax(address(i), INITIAL_BALANCE);
            venture.fund{value: FUND_AMOUNT}();
        }

        _;
    }

    function test_RevertIfApprovalCountIsLessThanHalfOfFunders()
        public
        funded
        fundedWithAdditionalFunders(10)
        createdRequest
        approvedRequest
    {
        vm.prank(venture.getEntrepreneur());
        vm.expectRevert();
        venture.finalizeRequest(0);
    }

    function test_RevertIfRequestIsAlreadyCompleted()
        public
        funded
        createdRequest
        approvedRequest
    {
        vm.prank(venture.getEntrepreneur());
        venture.finalizeRequest(0);

        vm.prank(venture.getEntrepreneur());
        vm.expectRevert();
        venture.finalizeRequest(0);
    }

    function test_RequestIsSetToTrueAfterFinalization()
        public
        funded
        createdRequest
        approvedRequest
    {
        vm.prank(venture.getEntrepreneur());
        venture.finalizeRequest(0);

        bool actualComplete = venture.getRequestComplete(0);
        assertEq(actualComplete, true);
    }

    function test_RequestAmountIsSentToRecipientAfterFinalization()
        public
        funded
        createdRequest
        approvedRequest
    {
        uint256 initialReceipientBalance = RECIPIENT.balance;
        vm.prank(venture.getEntrepreneur());
        venture.finalizeRequest(0);

        uint256 finalReceipientBalance = RECIPIENT.balance;

        assertEq(
            finalReceipientBalance - initialReceipientBalance,
            REQUEST_AMOUNT
        );
    }
}
