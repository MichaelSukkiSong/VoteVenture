// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockAggregator {
    int256 public s_answer;

    constructor(int256 _answer) {
        s_answer = _answer;
    }

    function setLatestAnswer(int256 answer) public {
        s_answer = answer;
    }

    function latestRoundData() public view returns (int256) {
        return s_answer;
    }
}
