// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RNTIDO {
    event Presale(address indexed user, uint256 amount);
    uint256 public constant PRICE = 0.0001 ether;
    uint256 public constant SOFTCAP = 10 ether;  //最低募资额
    uint256 public constant HARDCAP = 100 ether; //最高募资额
    uint256 public immutable END_AT; //7天后结束
    IERC20 public immutable RNT;
    uint256 public constant TOTAL_SUPPLY = PRICE*SOFTCAP; 
    uint256 public totalSold;
    uint256 public totalRaised;
    mapping(address => uint256) public balances;

    constructor(IERC20 RNT_){
        END_AT = block.timestamp +7 days;// 7 天后结束
        RNT=RNT_;
    }

    //预售
    function presale(uint256 amount) external payable {
        require(block.timestamp <= END_AT, "not in presale time");
        require(msg.value == amount * PRICE, "invalid amount");
        require(totalRaised + msg.value <= HARDCAP, "hardcap reached");

        totalSold += amount;
        totalRaised += msg.value;
        balances[msg.sender] += amount;

        emit Presale(msg.sender, amount);
    }

    function claim()external {
        require(block.timestamp > END_AT, "Not in claim time");
        require(totalRaised>=SOFTCAP,"softcap not reached");
        uint256 amount = balances [msg.sender];
        require(amount >0,"nothing to claim");

        uint256 share = totalSold / TOTAL_SUPPLY;
        uint256 claimAmount =amount * share;
        balances[msg.sender] = 0;
        require(RNT.transfer(msg.sender, claimAmount), "RNT transfer failed");

    }

    //募集失败退还投资者资金
    function refund() external {
        require(block.timestamp >END_AT, "not in claim time");
        require(totalRaised<SOFTCAP,"softcap reached");

        uint256 amount = balances[msg.sender];
        require(amount >0,"nothing to refund");

        balances[msg.sender]= 0;
        uint256 refundAmount = amount * PRICE;
        (bool ok,)= msg.sender.call{ value: refundAmount }("");
        require(ok,"refund failed");
    }

    //募集成功项目方取走资金
    function withdraw()external {
        require(block.timestamp >END_AT, "not in claim time");
        require(totalRaised >= SOFTCAP,"softcap not reached");
        (bool ok,)= msg.sender.call{ value: totalRaised }("");
        require(ok,"withdraw failed");
    }

}