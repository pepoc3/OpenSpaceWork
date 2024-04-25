// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage {
    string private _baseTokenURI;
    uint256 private _tokenIdCounter;

    constructor() ERC721("MyNFT", "NFT") {}

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external {
        _baseTokenURI = baseURI;
    }

    function mint(address tokenOwner, string memory URI) public returns (uint256) {
        uint256 newTokenId = _getNextTokenId();
        _mint(tokenOwner, newTokenId);
        _setTokenURI(newTokenId, URI);
        _incrementTokenId();
        return newTokenId;
    }

    function _getNextTokenId() private view returns (uint256) {
        return _tokenIdCounter + 1;
    }

    function _incrementTokenId() private {
        _tokenIdCounter++;
    }
}
