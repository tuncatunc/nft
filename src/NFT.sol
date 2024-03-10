// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

error MintPriceNotPaid();
error MaxSupplyReached();
error NonExistingTokenURI();
error WithdrawTransfer();


contract NFT is ERC721 {
    uint256 public currentTokenId;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    }

    function mintTo(address recipient) public payable returns (uint256){
        uint256 tokenId = currentTokenId;
        currentTokenId += 1;
        _mint(recipient, tokenId);
        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked("https://my-json-server.typicode.com/andrewsantarin/nft-tutorial/tokens/", Strings.toString(tokenId)));
    }
}
