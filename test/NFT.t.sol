// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "src/NFT.sol";
import "forge-std/StdStorage.sol";

contract NFTTest is Test {
    using stdStorage for StdStorage;

    NFT private nft;
    string public constant BASE_URI = "https://example.com/";

    function setUp() public {
        nft = new NFT("MY NFT", "MNFT", BASE_URI);
    }

    function test_RevertMintWithoutValue() public {
        vm.expectRevert(MintPriceNotPaid.selector);

        nft.mintTo(address(1));
    }

    function test_MintPricePaid() public {
        nft.mintTo{value: 0.01 ether}(address(1));
    }

    function test_RevertMintMaxSupplyReached() public {
        uint256 slot = stdstore
            .target(address(nft))
            .sig(nft.currentTokenId.selector)
            .find();

        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10_000));
        vm.store(address(nft), loc, mockedCurrentTokenId);
        vm.expectRevert(MaxSupplyReached.selector);

        nft.mintTo{value: 0.01 ether}(address(1));
    }

    function test_RevertMintToZeroAddress() public {
        vm.expectRevert("INVALID_RECIPIENT");

        nft.mintTo{value: 0.01 ether}(address(0));
    }

    function test_NewMintOwnerRegistered() public {
        nft.mintTo{value: 0.08 ether}(address(1));
        uint256 slotOfNewOwner = stdstore
            .target(address(nft))
            .sig(nft.ownerOf.selector)
            .with_key(address(1))
            .find();

        uint160 ownerOfTokenIdOne = uint160(
            uint256(
                (vm.load(address(nft), bytes32(abi.encode(slotOfNewOwner))))
            )
        );
        assertEq(address(ownerOfTokenIdOne), address(1));
    }

    function test_BalanceIncremented() public {
        nft.mintTo{value: 0.08 ether}(address(1));
        uint256 slotBalance = stdstore
            .target(address(nft))
            .sig(nft.balanceOf.selector)
            .with_key(address(1))
            .find();

        uint256 balanceFirstMint = uint256(
            vm.load(address(nft), bytes32(slotBalance))
        );
        assertEq(balanceFirstMint, 1);

        nft.mintTo{value: 0.08 ether}(address(1));
        uint256 balanceSecondMint = uint256(
            vm.load(address(nft), bytes32(slotBalance))
        );
        assertEq(balanceSecondMint, 2);
    }

    function test_SafeContractReciver() public {
        Receiver receiver = new Receiver();
        nft.mintTo{value: 0.01 ether}(address(receiver));
        uint256 slot = stdstore
            .target(address(nft))
            .sig(nft.balanceOf.selector)
            .with_key(address(receiver))
            .find();

        uint256 balance = uint256(vm.load(address(nft), bytes32(slot)));
        assertEq(balance, 1);
    }

    function test_RevertUnsafeContractReciver() public {
        // Adress set to 11, because first 10 addresses are restricted for precompiles
        vm.etch(address(11), bytes("mock receiver"));
        vm.expectRevert(bytes(""));
        nft.mintTo{value: 0.01 ether}(address(11));
    }

    function test_WithdrawlWorksAsOwner() public {
        Receiver receiver = new Receiver();
        address payable payee = payable(address(0x1337));
        uint256 priorPayeeBalance = address(payee).balance;

        nft.mintTo{value: 0.01 ether}(address(receiver));

        // Check the balance of the contract is correct 0.01 ether
        uint256 nftBalance = address(nft).balance;
        assertEq(nftBalance, nft.MINT_PRICE());

        // Withdraw the balance to the payee and asset the balance is transferred
        nft.withdrawPayments(payee);

        assertEq(address(payee).balance, priorPayeeBalance + nft.MINT_PRICE());
    }

    function test_WithdrawlRevertIfNotOwner() public {
        Receiver receiver = new Receiver();
        nft.mintTo{value: 0.01 ether}(address(receiver));
        // Check the balance of the contract is correct 0.01 ether
        uint256 nftBalance = address(nft).balance;
        assertEq(nftBalance, nft.MINT_PRICE());

        // Withdraw the balance to the payee and asset the balance is transferred
        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(address(0xd3ad));
        nft.withdrawPayments(payable(address(0xd3ad))); // Not the owner
    }
}

contract Receiver is ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
