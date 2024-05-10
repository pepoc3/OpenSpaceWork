// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    // using Counters for Counters.Counter;
    // Counters.Counter private _tokenIds;
    bytes32 public DOMAIN_SEPARATER;
    mapping(address => uint) public nounces;
    uint256 tokenId = 0;

    constructor() ERC721(unicode"MyNft", "NFT") {}

    function mint(address user) external returns (bool) {
        _mint(user, tokenId);
        tokenId += 1;
        return true;
    }
    function permit(
        address from,
        address to,
        uint nftId,
        uint price,
        uint nounce,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = keccak256(
            abi.encodePacked(
                hex"1901",
                DOMAIN_SEPARATER,
                keccak256(
                    abi.encode(
                        keccak256(
                            "Permit(address from,address to,uint256 nftId,uint256 nonce,uint256 deadline)"
                        ),
                        from,
                        to,
                        nftId,
                        price,
                        nounce,
                        deadline
                    )
                )
            )
        );
        require(from != address(0), "invalid owner address");
        require(from == ecrecover(digest, v, r, s));
        require(nounce == nounces[from], "invalid nounce");
        require(deadline == 0 || deadline >= block.timestamp);
        nounces[from] ++;
        _transfer(from, to, nftId);
    }
}