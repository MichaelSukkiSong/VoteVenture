// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract Venture {
    uint256 public constant MINIMUM_FUND = 5 * 10 ** 18;
    address private immutable i_entrepreneur;
    address[] private funders;
    mapping(address funder => uint256 amount) private funderAmount;
    Request[] private requests;

    struct Request {
        string description;
        uint256 amount;
        address payable recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    constructor() {
        i_entrepreneur = msg.sender;
    }

    function fund() public payable {
        if (msg.value < MINIMUM_FUND) {
            revert("You need to fund more than the minimum fund");
        }

        funders.push(msg.sender);
        funderAmount[msg.sender] += msg.value;
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

        Request storage newRequest = requests.push();
        newRequest.description = description;
        newRequest.amount = amount;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint256 _index) public {
        Request storage request = requests[_index];

        require(funderAmount[msg.sender] > 0, "You are not a funder");
        require(!request.approvals[msg.sender], "You have already approved");

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 _index) public {
        Request storage request = requests[_index];

        require(
            request.approvalCount > (funders.length / 2),
            "Not enough approvals"
        );
        require(!request.complete, "Request already completed");

        (bool success, ) = request.recipient.call{value: request.amount}("");

        require(success, "Transfer failed");

        request.complete = true;
    }

    /* getter functions */
    function getEntrepreneur() public view returns (address) {
        return i_entrepreneur;
    }

    function getFunders() public view returns (address[] memory) {
        return funders;
    }

    function getFunderAmount(address _funder) public view returns (uint256) {
        return funderAmount[_funder];
    }

    function getRequests() internal view returns (Request[] storage) {
        return requests;
    }
}
