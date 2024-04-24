// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract NFTMarket {
    IERC721 public nftContract;
    IERC20 public tokenContract;

    struct  Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;
    mapping(address => uint256) public userBalances;
    address _erc20addr=0xb7bb1792BBfabbA361c46DC5860940e0E1bFb4b9;  
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

    constructor(address _nftContract, address _tokenContract) {
        nftContract = IERC721(_nftContract);
        tokenContract = IERC20(_tokenContract);
    }

    function getTokenPrice(uint256 _tokenId)  public view returns (uint256) {
        Listing memory listing = listings[_tokenId];
        return listing.price;
    }

    function list(uint256 _tokenId, uint256 _price) external {
        require(nftContract.ownerOf(_tokenId) == msg.sender, "You are not the owner of this NFT");
        require(_price > 0, "Price must be greater than zero");

        listings[_tokenId] = Listing(msg.sender, _price);
        emit NFTListed(_tokenId, msg.sender, _price);
    }

    function buyNFT(uint256 _tokenId) external {
        Listing memory listing = listings[_tokenId];
        require(listing.seller != address(0), "NFT is not listed for sale");

        uint256 price = listing.price;
        address seller = listing.seller;

        require(tokenContract.transferFrom(msg.sender, seller, price), "Token transfer failed");
        nftContract.safeTransferFrom(seller, msg.sender, _tokenId);

        delete listings[_tokenId];
        emit NFTSold(_tokenId, msg.sender, price);
    }
    

    //拓展token回调
    function tokensReceived(address buyer, uint256 amount, bytes memory ExtraData) public returns (bool) {
        require(msg.sender == _erc20addr, "buyNFT_callback function should be called by ERC20 contract!");
        uint256 tokenId = abi.decode(ExtraData, (uint256));
        Listing memory listing = listings[tokenId];
        require(listing.seller != address(0), "NFT is not listed for sale");
        require(amount == listing.price, "Amount must equal token price!");
        uint256 price = listing.price;
        address seller = listing.seller;
        nftContract.safeTransferFrom(seller, buyer, tokenId);
        tokenContract.transfer(seller, amount);
        delete listings[tokenId];
        emit NFTSold(tokenId, msg.sender, price);
        return true;
    }
}
