// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./NFT.sol";
import "./Token.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/// @custom:oz-upgrades-from NFTMarketV1
contract NftMarketV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    address tokenAddress;
    address nftAddress;

    mapping(uint256 => uint256) prices;
    mapping(uint256 => address) seller;

    event Listed(address seller, uint256 price);
    event Sold(address seller, address buyer, uint256 price);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    function initialize(
        address _tokenAddress,
        address _nftAddress,
        address initialOwner
    ) initializer public {
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

     function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

      function list(uint256 nftId, uint256 price) external returns (bool) {
        // NewNft(nftAddress).safeTransferFrom(msg.sender, address(this), nftId);
        NFT(nftAddress).transferFrom(msg.sender, address(this), nftId);

        prices[nftId] = price;
        seller[nftId] = msg.sender;
        emit Listed(msg.sender, price);
        return true;
    }
    function permitList(
        address from,
        address to,
        uint256 nftId, 
        uint256 price, 
        uint nonce, 
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s ) external returns (bool) {
        NFT(nftAddress).permit(from, to, nftId, price, nonce, deadline, v, r, s);
        NFT(nftAddress).transferFrom(msg.sender, address(this), nftId);
        prices[nftId] = price;
        seller[nftId] = from;
        emit Listed(msg.sender, price);
        return true;
    }


    function buyNFT(uint256 nftId) external returns (bool) {
        Token(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            prices[nftId]
        );
        Token(tokenAddress).transfer(seller[nftId], prices[nftId]);
        NFT(nftAddress).safeTransferFrom(address(this), msg.sender, nftId);
        emit Sold(seller[nftId], msg.sender, prices[nftId]);
        delete prices[nftId];
        delete seller[nftId];
        return true;
    }


}
