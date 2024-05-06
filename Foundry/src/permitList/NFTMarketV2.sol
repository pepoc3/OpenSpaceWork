// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./NFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
/// @custom:oz-upgrades-from NFTMarketV1
contract NFTMarketV2 {
    address tokenAddress;
    address nftAddress;

    mapping(uint256 => uint256) prices;
    mapping(uint256 => address) seller;

    event Listed(address seller, uint256 price);
    event Sold(address seller, address buyer, uint256 price);

    // _disableInitializers()确保初始化方法只运行一次，以防止意外重新初始化
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        
        _disableInitializers();
    }

    function initialize(address _tokenAddress, address _nftAddress) initializer public {
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
    }

    function tokenReceived(address sender, uint256 amount, bytes calldata data) external returns (bool) {
        uint256 nftId = abi.decode(data, (uint256));
        require(prices[nftId] <= amount, "payment value is less than list price");
        IERC20(tokenAddress).transfer(seller[nftId], prices[nftId]);
        IERC721(nftAddress).safeTransferFrom(address(this), sender, nftId);
        emit Sold(seller[nftId], sender, prices[nftId]);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }

    function permitlist(uint256 nftId, 
        uint256 price, 
        uint nonce, 
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s ) external returns (bool) {
        IERC721(nftAddress).permit(msg.sender, address(this), nftId, price, nonce, deadline, v, r, s);
        IERC721(nftAddress).transferFrom(msg.sender, address(this), nftId);
        prices[nftId] = price;
        seller[nftId] = msg.sender;
        emit Listed(msg.sender, price);
        return true;
    }

    function buyNFT(uint256 nftId) external returns (bool) {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), prices[nftId]);
        IERC20(tokenAddress).transfer(seller[nftId], prices[nftId]);
        IERC721(nftAddress).safeTransferFrom(address(this), msg.sender, nftId);
        emit Sold(seller[nftId], msg.sender, prices[nftId]);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }

    // 确保了安全的合约升级，只允许所有者授权新的合约版本
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}