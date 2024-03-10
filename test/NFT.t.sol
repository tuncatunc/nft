// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "src/NFT.sol";

contract NFTTest is Test {
    NFT public nft;

    function setUp() public {
        nft = new NFT("MY NFT", "MNFT");
    }
}
