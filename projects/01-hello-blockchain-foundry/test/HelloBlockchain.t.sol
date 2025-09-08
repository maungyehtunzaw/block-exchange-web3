// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {HelloBlockchain} from "../src/HelloBlockchain.sol";

contract HelloBlockchainTest is Test {
    HelloBlockchain public helloBlockchain;
    address public owner;
    address public addr1;
    address public addr2;

    string constant INITIAL_MESSAGE = "Hello, Test World!";

    function setUp() public {
        owner = address(this);
        addr1 = address(0x1);
        addr2 = address(0x2);

        helloBlockchain = new HelloBlockchain(INITIAL_MESSAGE);
    }

    function test_Deployment() public {
        assertEq(helloBlockchain.owner(), owner);
        assertEq(helloBlockchain.message(), INITIAL_MESSAGE);
        assertEq(helloBlockchain.getMessage(), INITIAL_MESSAGE);
        assertEq(helloBlockchain.updateCount(), 0);
    }

    function test_UpdateMessage() public {
        string memory newMessage = "Updated message!";

        helloBlockchain.updateMessage(newMessage);

        assertEq(helloBlockchain.message(), newMessage);
        assertEq(helloBlockchain.updateCount(), 1);
    }

    function test_UpdateMessageMultiple() public {
        helloBlockchain.updateMessage("Message 1");
        assertEq(helloBlockchain.updateCount(), 1);

        helloBlockchain.updateMessage("Message 2");
        assertEq(helloBlockchain.updateCount(), 2);

        helloBlockchain.updateMessage("Message 3");
        assertEq(helloBlockchain.updateCount(), 3);
    }

    function test_RevertWhen_NonOwnerUpdatesMessage() public {
        vm.prank(addr1);
        vm.expectRevert("HelloBlockchain: Only owner can call this function");
        helloBlockchain.updateMessage("Hacker message");
    }

    function test_RevertWhen_EmptyMessage() public {
        vm.expectRevert("HelloBlockchain: Message cannot be empty");
        helloBlockchain.updateMessage("");
    }

    function test_RevertWhen_MessageTooLong() public {
        string memory longMessage = new string(281);
        // Fill with 'a' characters
        bytes memory longBytes = new bytes(281);
        for (uint256 i = 0; i < 281; i++) {
            longBytes[i] = "a";
        }

        vm.expectRevert("HelloBlockchain: Message too long (max 280 chars)");
        helloBlockchain.updateMessage(string(longBytes));
    }

    function test_MessageExactly280Characters() public {
        string memory maxMessage = new string(280);
        bytes memory maxBytes = new bytes(280);
        for (uint256 i = 0; i < 280; i++) {
            maxBytes[i] = "a";
        }

        helloBlockchain.updateMessage(string(maxBytes));
        assertEq(helloBlockchain.message(), string(maxBytes));
    }

    function test_MessageUpdatedEvent() public {
        string memory newMessage = "Event test message";

        vm.expectEmit(true, true, false, true);
        emit HelloBlockchain.MessageUpdated(newMessage, owner, block.timestamp);

        helloBlockchain.updateMessage(newMessage);
    }

    function test_GetContractInfo() public {
        (string memory currentMessage, address contractOwner, uint256 totalUpdates, uint256 contractBalance) =
            helloBlockchain.getContractInfo();

        assertEq(currentMessage, INITIAL_MESSAGE);
        assertEq(contractOwner, owner);
        assertEq(totalUpdates, 0);
        assertEq(contractBalance, 0);
    }

    function test_TransferOwnership() public {
        vm.expectEmit(true, true, false, false);
        emit HelloBlockchain.OwnershipTransferred(owner, addr1);

        helloBlockchain.transferOwnership(addr1);

        assertEq(helloBlockchain.owner(), addr1);
    }

    function test_NewOwnerCanUpdateMessage() public {
        helloBlockchain.transferOwnership(addr1);

        vm.prank(addr1);
        helloBlockchain.updateMessage("New owner message");

        assertEq(helloBlockchain.message(), "New owner message");
    }

    function test_RevertWhen_OldOwnerUpdatesAfterTransfer() public {
        helloBlockchain.transferOwnership(addr1);

        vm.expectRevert("HelloBlockchain: Only owner can call this function");
        helloBlockchain.updateMessage("Old owner message");
    }

    function test_RevertWhen_TransferToZeroAddress() public {
        vm.expectRevert("HelloBlockchain: New owner cannot be zero address");
        helloBlockchain.transferOwnership(address(0));
    }

    function test_RevertWhen_TransferToSameOwner() public {
        vm.expectRevert("HelloBlockchain: New owner must be different from current owner");
        helloBlockchain.transferOwnership(owner);
    }

    function test_AcceptETHDeposits() public {
        uint256 depositAmount = 1 ether;

        vm.deal(addr1, depositAmount);
        vm.prank(addr1);
        (bool success,) = address(helloBlockchain).call{value: depositAmount}("");

        assertTrue(success);
        assertEq(helloBlockchain.getBalance(), depositAmount);
        assertEq(address(helloBlockchain).balance, depositAmount);
    }

    function test_OwnerCanWithdrawETH() public {
        uint256 depositAmount = 2 ether;

        // Deposit ETH
        vm.deal(address(this), depositAmount);
        (bool success,) = address(helloBlockchain).call{value: depositAmount}("");
        assertTrue(success);

        // Record owner balance before withdrawal
        uint256 ownerBalanceBefore = address(this).balance;

        // Withdraw
        helloBlockchain.withdraw();

        // Check balances
        assertEq(helloBlockchain.getBalance(), 0);
        assertEq(address(this).balance, ownerBalanceBefore + depositAmount);
    }

    function test_RevertWhen_NonOwnerWithdraws() public {
        uint256 depositAmount = 1 ether;

        vm.deal(address(this), depositAmount);
        (bool success,) = address(helloBlockchain).call{value: depositAmount}("");
        assertTrue(success);

        vm.prank(addr1);
        vm.expectRevert("HelloBlockchain: Only owner can call this function");
        helloBlockchain.withdraw();
    }

    function test_RevertWhen_WithdrawZeroBalance() public {
        vm.expectRevert("HelloBlockchain: No ETH to withdraw");
        helloBlockchain.withdraw();
    }

    function test_FuzzUpdateMessage(string memory randomMessage) public {
        // Skip empty messages and messages that are too long
        vm.assume(bytes(randomMessage).length > 0);
        vm.assume(bytes(randomMessage).length <= 280);

        helloBlockchain.updateMessage(randomMessage);
        assertEq(helloBlockchain.message(), randomMessage);
        assertEq(helloBlockchain.updateCount(), 1);
    }

    function test_FuzzETHDeposit(uint256 amount) public {
        // Bound the amount to reasonable values
        amount = bound(amount, 1 wei, 100 ether);

        vm.deal(addr1, amount);
        vm.prank(addr1);
        (bool success,) = address(helloBlockchain).call{value: amount}("");

        assertTrue(success);
        assertEq(helloBlockchain.getBalance(), amount);
    }

    // Helper function to receive ETH
    receive() external payable {}
}
