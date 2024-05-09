// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract S2NFT is ERC721Enumerable {
  string private _BASE_URI;

  uint256 private _nextTokenId = 0;
  uint256 public immutable MAX_SUPPLY;

  constructor(string memory name_, string memory symbol_, string memory baseURI_, uint256 maxSupply_)
    ERC721(name_, symbol_)
  {
    _BASE_URI = baseURI_;
    MAX_SUPPLY = maxSupply_;
  }

  function _baseURI() internal view override returns (string memory) {
    return _BASE_URI;
  }

  function freeMint(uint256 amount) external {
    require(amount <= 5, "You can mint up to 5 tokens at a time");
    uint256 nextTokenId = _nextTokenId;
    for (uint256 i = 0; i < amount; i++) {
      _safeMint(msg.sender, nextTokenId);
      nextTokenId++;
    }
    _nextTokenId = nextTokenId;
    require(_nextTokenId <= MAX_SUPPLY, "All tokens have been minted");
  }
}

contract NFTFactory is Ownable(msg.sender) {
  event NFTCreated(address nftCA);
  event NFTRegesitered(address nftCA);

  mapping(address => bool) regesiteredNFTs;

  function deployNFT(string memory name, string memory symbol, string memory baseURI, uint256 maxSupply)
    external
    returns (address)
  {
    S2NFT nft = new S2NFT(name, symbol, baseURI, maxSupply);
    regesiteredNFTs[address(nft)] = true;
    emit NFTCreated(address(nft));
    return address(nft);
  }

  function regesiterNFT(address nftCA) external onlyOwner {
    require(!regesiteredNFTs[nftCA], "NFT already regesitered");
    regesiteredNFTs[nftCA] = true;
    emit NFTRegesitered(nftCA);
  }
}
