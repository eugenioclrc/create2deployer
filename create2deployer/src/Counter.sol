// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}

contract CounterWithCondition {
    uint256 public number;
    constructor(uint256 _number) {
        require(_number > 0, "not greater than 0");
        number = _number;
    }
}