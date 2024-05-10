// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

import "./ESRNT.sol";

contract RNTStake {
    IERC20 public immutable RNT;
    ESRNT public immutable esRNT;
    uint256 public constant mintSeedPersecond = 11_574_074_074_074;//uint256( 1e18 / 1 days) ;

    constructor(IERC20 RNT_, ESRNT ESRNT_){
        RNT = RNT_;
        esRNT = ESRNT_;
        
    }
    mapping(address => Stake) public stakes;
    
    struct Stake {
        uint256 amount;
        uint256 lastUpdate;
        uint256 debt;
    }
    function stake(uint256 amount) external before() {
        Stake storage s = stakes[msg.sender];
        require(amount > 0, "invalid amount");
        require(RNT.transferFrom(msg.sender, address(this),amount), "RNT transfer failed");
        s.amount += amount;

    }
    function unstake(uint256 amount) external before() {
        Stake storage s = stakes[msg.sender];
        require(s.amount >= amount,"nothing to unstake");
        s.amount -= amount;
        require(RNT.transfer(msg.sender,amount), "RNT transfer failed");

    }
    function claim() external before() {
        Stake storage s = stakes[msg.sender];
        uint256 claimAmount = s.debt;
        require(claimAmount>0,"nothing to claim");
        s.debt = 0;
        // RNT.transfer(address(ESRNT), claimAmount);
        // ESRNT.mint();
        esRNT.mint(claimAmount);
        require(RNT.transfer(msg.sender,claimAmount),"RNT transfer failed");
        
    }

    modifier before() {
        Stake storage s = stakes[msg.sender];
        uint256 duration = block.timestamp - s.lastUpdate;
        uint256 interest =s.amount * duration * mintSeedPersecond;
        s.debt += interest;
        s.lastUpdate = block.timestamp;
        // s.amount += amount;

        _;
    }
}

