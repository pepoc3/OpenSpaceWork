// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721(unicode"MyNft", "NFT") {}

    function mint(address tokenOwner, string memory URI) public returns (uint256)
    {
        uint256 newTokenId = _tokenIds.current();
        _mint(tokenOwner, newTokenId);
        _setTokenURI(newTokenId, URI);
        _tokenIds.increment();
        return newTokenId;
    }
}
