// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Counter {

    uint256 counter;

 
    function store(uint256 num) public {
        counter = num;
    }

    function get() public view returns (uint256){
        return counter;
    }
    function add(uint256 x) public returns (uint256){
        counter += x;
        return counter;
    }
}
