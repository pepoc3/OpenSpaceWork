// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ESRNT is ERC20Permit("RenftToken") {
    IERC20 public immutable RNT;
    uint256 mintTime;
     
    constructor(IERC20 RNT_)ERC20("Renft token","ESRNT"){
        RNT = RNT_;
    }

    function mint(uint256 amount) external {
        IERC20(RNT).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
        mintTime = block.timestamp;
    }

    function ConvertToRNT(uint256 amount) public {
        require(block.timestamp >= mintTime + 30 days, "not enoungh 30days");
        IERC20(RNT).transfer(msg.sender, amount);
        _burn(msg.sender, amount);
    }
    //不用授权的方式
    // uint256 public lastBalance = 1000;
    // function mint() external {
    //     uint256 balance = IERC20(rnt).balance0f(address(this));   
    //     uint256 added = balance - lastBalance;

    //     _mint(msg.sender, added);
    // }
}