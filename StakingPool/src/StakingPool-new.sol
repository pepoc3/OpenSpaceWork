// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "./ERC20.sol";
import { SafeTransferLib } from "./SafeTransferLib.sol";
import { IToken } from "./IToken.sol";
import { IStaking } from "./IStaking.sol";

contract StakingPool is IStaking {
    using SafeTransferLib for ERC20;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);

    IToken public immutable kkToken;
    uint256 public totalStaked;
    uint256 public lastRewardBlock;
    uint256 public rewardPerTokenStored;
    uint256 public constant REWARD_RATE = 10 ether; // 每个区块产出10个 KK Token

    mapping(address => uint256) public userStake;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    constructor(IToken _kkToken) {
        kkToken = _kkToken;
        lastRewardBlock = block.number;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastRewardBlock = block.number;
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            ((block.number - lastRewardBlock) * REWARD_RATE * 1e18) /
            totalStaked;
    }

    function earned(address account) public view override returns (uint256) {
        return
            (userStake[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) /
            1e18 +
            rewards[account];
    }

    function stake() external payable override updateReward(msg.sender) {
        require(msg.value > 0, "Cannot stake 0");
        totalStaked += msg.value;
        userStake[msg.sender] += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    function unstake(uint256 amount) external override updateReward(msg.sender) {
        require(amount > 0, "Cannot unstake 0");
        require(userStake[msg.sender] >= amount, "Insufficient staked amount");
        totalStaked -= amount;
        userStake[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Unstaked(msg.sender, amount);
    }

    function claim() external override updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            // kkToken.mint(msg.sender, reward);
            // kkToken.safeTransfer(msg.sender, reward);
            ERC20(address(kkToken)).safeTransfer(msg.sender, reward);
            emit Claimed(msg.sender, reward);
        }
    }

    function balanceOf(address account) external view override returns (uint256) {
        return userStake[account];
    }
}
