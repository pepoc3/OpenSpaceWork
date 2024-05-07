// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ERC2612-NFT.sol";
import "./ERC2612.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";



contract NFTMarket {
    IERC721 public nftContract;
    IERC20 public tokenContract;
    struct  Listing {
        address seller;
        uint256 price;
    }
    //白名单
    address public alice;
    
    mapping(uint256 => uint256) prices;
    mapping(uint256 => address) sellers;
    mapping(uint256 => Listing) public listings;
    mapping(address => uint256) public userBalances;
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event Sold(address seller, address buyer, uint256 price);
    event Listed(address seller, uint256 price);

    constructor(address _nftContract, address _tokenContract) {
        nftContract = IERC721(_nftContract);
        tokenContract = IERC20(_tokenContract);
        alice = msg.sender;
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

    function buyNFT(uint256 _tokenId) internal {
        Listing memory listing = listings[_tokenId];
        require(listing.seller != address(0), "NFT is not listed for sale");

        uint256 price = listing.price;
        address seller = listing.seller;

        require(tokenContract.transferFrom(msg.sender, seller, price), "Token transfer failed");
        nftContract.safeTransferFrom(seller, msg.sender, _tokenId);

        delete listings[_tokenId];
        emit NFTSold(_tokenId, msg.sender, price);
    }

     function permitBuy(uint256 nonce, bytes calldata signature, uint256 tokenId) public {
        _useCheckedNonce(msg.sender, nonce);

        bytes32 hash = keccak256(abi.encodePacked(msg.sender, nonce));
        hash = hash.toEthSignedMessageHash();
        address signAddr = hash.recover(signature);
        require(signAddr == alice, "error signiture");

        _useNonce(msg.sender);

        buyNFT(tokenId);
    }
    


}