// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "chainlink-brownie-contracts/shared/interfaces/AggregatorV3Interface.sol";

contract VentureFactory {
    address[] private s_deployedVentures;
    address s_priceFeedAddress;

    constructor(address _priceFeedAddress) {
        s_priceFeedAddress = _priceFeedAddress;
    }

    function createVenture() public returns (Venture) {
        Venture newVenture = new Venture(s_priceFeedAddress, msg.sender);
        s_deployedVentures.push(address(newVenture));

        return newVenture;
    }

    function getDeployedVentures() public view returns (address[] memory) {
        return s_deployedVentures;
    }
}

contract Venture {
    uint256 public constant MINIMUM_FUND = 5 * 10 ** 18;
    address private immutable i_entrepreneur;
    address[] private s_funders;
    mapping(address funder => uint256 amount) private s_funderAmount;
    Request[] private s_requests;
    AggregatorV3Interface private s_priceFeed;

    struct Request {
        string description;
        uint256 amount;
        address payable recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    constructor(address priceFeedAddress, address _entrepreneur) {
        i_entrepreneur = _entrepreneur;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        int256 answer = getPriceFeedLatestRoundData();

        if (answer == 0) {
            revert("Price feed is not available");
        }

        if ((msg.value * uint256(answer * 1e10)) / 1e18 < MINIMUM_FUND) {
            revert("You need to fund more than the minimum fund");
        }

        s_funders.push(msg.sender);
        s_funderAmount[msg.sender] += msg.value;
    }

    modifier onlyEntrepreneur() {
        require(msg.sender == i_entrepreneur, "You have to be an entrepreneur");
        _;
    }

    function createRequest(
        string memory description,
        uint256 amount,
        address payable recipient
    ) public onlyEntrepreneur {
        require(
            amount < address(this).balance,
            "Amount should be less than the total fund"
        );

        Request storage newRequest = s_requests.push();
        newRequest.description = description;
        newRequest.amount = amount;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint256 _index) public {
        Request storage request = s_requests[_index];

        require(s_funderAmount[msg.sender] > 0, "You are not a funder");
        require(!request.approvals[msg.sender], "You have already approved");

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 _index) public {
        Request storage request = s_requests[_index];

        require(
            request.approvalCount > (s_funders.length / 2),
            "Not enough approvals"
        );
        require(!request.complete, "Request already completed");

        (bool success, ) = request.recipient.call{value: request.amount}("");

        require(success, "Transfer failed");

        request.complete = true;
    }

    /****************** */
    /* getter functions */
    /****************** */

    function getEntrepreneur() public view returns (address) {
        return i_entrepreneur;
    }

    /* funder getters */

    function getFunders() public view returns (address[] memory) {
        return s_funders;
    }

    function getFunder(uint256 _index) public view returns (address) {
        return s_funders[_index];
    }

    function getFunderAmount(address _funder) public view returns (uint256) {
        return s_funderAmount[_funder];
    }

    /* request getters */

    function getRequestCount() public view returns (uint256) {
        return s_requests.length;
    }

    function getRequestDescription(
        uint256 _index
    ) public view returns (string memory) {
        return s_requests[_index].description;
    }

    function getRequestAmount(uint256 _index) public view returns (uint256) {
        return s_requests[_index].amount;
    }

    function getRequestRecipient(uint256 _index) public view returns (address) {
        return s_requests[_index].recipient;
    }

    function getRequestApprovals(
        uint256 _index,
        address _funder
    ) public view returns (bool) {
        return s_requests[_index].approvals[_funder];
    }

    function getRequestApprovalCount(
        uint256 _index
    ) public view returns (uint256) {
        return s_requests[_index].approvalCount;
    }

    function getRequestComplete(uint256 _index) public view returns (bool) {
        return s_requests[_index].complete;
    }

    /* price feed getters */

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getDecimals() public view returns (uint8) {
        return s_priceFeed.decimals();
    }

    function getPriceFeedLatestRoundData() public view returns (int256) {
        (, int256 answer, , , ) = s_priceFeed.latestRoundData();
        return answer;
    }
}
