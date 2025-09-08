// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {YHZToken} from "../src/YHZToken.sol";

contract YHZTokenTest is Test {
    YHZToken public token;
    address public owner;
    address public alice;
    address public bob;
    address public charlie;
    
    // Events to test
    event Transfer(address indexed from, address indexed to, uint256 value);
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event TokensMinted(address indexed to, uint256 amount, string reason);

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
        
        token = new YHZToken(owner);
    }

    function testInitialState() public {
        // Check basic token properties
        assertEq(token.name(), "YHZ Token");
        assertEq(token.symbol(), "YHZ");
        assertEq(token.decimals(), 18);
        
        // Check initial supply
        assertEq(token.totalSupply(), 1_000_000 * 10**18);
        assertEq(token.balanceOf(owner), 1_000_000 * 10**18);
        
        // Check constants
        assertEq(token.INITIAL_SUPPLY(), 1_000_000 * 10**18);
        assertEq(token.MAX_SUPPLY(), 10_000_000 * 10**18);
        assertEq(token.USDT_VALUE_PER_TOKEN(), 1000);
        
        // Check owner is a minter
        assertTrue(token.isMinter(owner));
        assertTrue(token.minters(owner));
    }

    function testOwnership() public {
        assertEq(token.owner(), owner);
    }

    function testTransfer() public {
        uint256 transferAmount = 1000 * 10**18;
        
        // Test successful transfer
        assertTrue(token.transfer(alice, transferAmount));
        assertEq(token.balanceOf(alice), transferAmount);
        assertEq(token.balanceOf(owner), token.INITIAL_SUPPLY() - transferAmount);
    }

    function testTransferFailures() public {
        uint256 transferAmount = 1000 * 10**18;
        
        // Test transfer to zero address
        vm.expectRevert("YHZ: Cannot transfer to zero address");
        token.transfer(address(0), transferAmount);
        
        // Test transfer zero amount
        vm.expectRevert("YHZ: Transfer amount must be greater than zero");
        token.transfer(alice, 0);
        
        // Test insufficient balance
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(bob, transferAmount);
    }

    function testApproveAndTransferFrom() public {
        uint256 allowanceAmount = 5000 * 10**18;
        uint256 transferAmount = 2000 * 10**18;
        
        // Owner approves Alice to spend tokens
        assertTrue(token.approve(alice, allowanceAmount));
        assertEq(token.allowance(owner, alice), allowanceAmount);
        
        // Alice transfers tokens from owner to Bob
        vm.prank(alice);
        assertTrue(token.transferFrom(owner, bob, transferAmount));
        
        assertEq(token.balanceOf(bob), transferAmount);
        assertEq(token.allowance(owner, alice), allowanceAmount - transferAmount);
    }

    function testMinterManagement() public {
        // Initially only owner is minter
        assertTrue(token.isMinter(owner));
        assertFalse(token.isMinter(alice));
        
        // Add Alice as minter
        vm.expectEmit(true, false, false, false);
        emit MinterAdded(alice);
        token.addMinter(alice);
        
        assertTrue(token.isMinter(alice));
        
        // Remove Alice as minter
        vm.expectEmit(true, false, false, false);
        emit MinterRemoved(alice);
        token.removeMinter(alice);
        
        assertFalse(token.isMinter(alice));
    }

    function testMinterManagementFailures() public {
        // Only owner can add minters
        vm.prank(alice);
        vm.expectRevert();
        token.addMinter(bob);
        
        // Cannot add zero address as minter
        vm.expectRevert("YHZ: Cannot add zero address as minter");
        token.addMinter(address(0));
        
        // Cannot add existing minter
        vm.expectRevert("YHZ: Address is already a minter");
        token.addMinter(owner);
        
        // Cannot remove non-minter
        vm.expectRevert("YHZ: Address is not a minter");
        token.removeMinter(alice);
    }

    function testMinting() public {
        uint256 mintAmount = 50000 * 10**18;
        string memory reason = "Community Rewards";
        
        vm.expectEmit(true, false, false, true);
        emit TokensMinted(alice, mintAmount, reason);
        token.mint(alice, mintAmount, reason);
        
        assertEq(token.balanceOf(alice), mintAmount);
        assertEq(token.totalSupply(), token.INITIAL_SUPPLY() + mintAmount);
    }

    function testMintingFailures() public {
        uint256 mintAmount = 50000 * 10**18;
        
        // Only minters can mint
        vm.prank(alice);
        vm.expectRevert("YHZ: Only minters can mint tokens");
        token.mint(bob, mintAmount, "test");
        
        // Cannot mint to zero address
        vm.expectRevert("YHZ: Cannot mint to zero address");
        token.mint(address(0), mintAmount, "test");
        
        // Cannot mint zero amount
        vm.expectRevert("YHZ: Amount must be greater than zero");
        token.mint(alice, 0, "test");
        
        // Cannot exceed max supply
        uint256 excessiveAmount = token.MAX_SUPPLY() - token.totalSupply() + 1;
        vm.expectRevert("YHZ: Minting would exceed max supply");
        token.mint(alice, excessiveAmount, "test");
    }

    function testBatchMinting() public {
        address[] memory recipients = new address[](3);
        uint256[] memory amounts = new uint256[](3);
        string memory reason = "Batch Airdrop";
        
        recipients[0] = alice;
        recipients[1] = bob;
        recipients[2] = charlie;
        amounts[0] = 1000 * 10**18;
        amounts[1] = 2000 * 10**18;
        amounts[2] = 3000 * 10**18;
        
        uint256 totalAmount = amounts[0] + amounts[1] + amounts[2];
        uint256 initialSupply = token.totalSupply();
        
        token.batchMint(recipients, amounts, reason);
        
        assertEq(token.balanceOf(alice), amounts[0]);
        assertEq(token.balanceOf(bob), amounts[1]);
        assertEq(token.balanceOf(charlie), amounts[2]);
        assertEq(token.totalSupply(), initialSupply + totalAmount);
    }

    function testBatchMintingFailures() public {
        address[] memory recipients = new address[](2);
        uint256[] memory amounts = new uint256[](1); // Mismatched arrays
        
        recipients[0] = alice;
        recipients[1] = bob;
        amounts[0] = 1000 * 10**18;
        
        // Arrays length mismatch
        vm.expectRevert("YHZ: Arrays length mismatch");
        token.batchMint(recipients, amounts, "test");
        
        // Empty arrays
        address[] memory emptyAddresses = new address[](0);
        uint256[] memory emptyAmounts = new uint256[](0);
        vm.expectRevert("YHZ: Empty arrays");
        token.batchMint(emptyAddresses, emptyAmounts, "test");
    }

    function testUSDValueCalculations() public {
        uint256 tokenAmount = 5 * 10**18; // 5 YHZ tokens
        uint256 expectedUSDValue = 5000; // 5 * 1000 USDT
        
        assertEq(token.getUSDValue(tokenAmount), expectedUSDValue);
        
        uint256 usdValue = 3500; // 3500 USDT
        uint256 expectedTokenAmount = 3.5 * 10**18; // 3.5 YHZ tokens
        
        assertEq(token.getTokenAmount(usdValue), expectedTokenAmount);
    }

    function testRemainingSupply() public {
        uint256 initialRemaining = token.remainingSupply();
        assertEq(initialRemaining, token.MAX_SUPPLY() - token.INITIAL_SUPPLY());
        
        uint256 mintAmount = 100000 * 10**18;
        token.mint(alice, mintAmount, "test");
        
        assertEq(token.remainingSupply(), initialRemaining - mintAmount);
    }

    function testBurning() public {
        uint256 burnAmount = 50000 * 10**18;
        uint256 initialSupply = token.totalSupply();
        uint256 initialBalance = token.balanceOf(owner);
        
        token.burn(burnAmount);
        
        assertEq(token.totalSupply(), initialSupply - burnAmount);
        assertEq(token.balanceOf(owner), initialBalance - burnAmount);
    }

    function testBurnFrom() public {
        uint256 burnAmount = 30000 * 10**18;
        uint256 allowanceAmount = 50000 * 10**18;
        
        // Transfer some tokens to Alice
        token.transfer(alice, 100000 * 10**18);
        
        // Alice approves owner to burn her tokens
        vm.prank(alice);
        token.approve(owner, allowanceAmount);
        
        uint256 aliceInitialBalance = token.balanceOf(alice);
        uint256 initialSupply = token.totalSupply();
        
        token.burnFrom(alice, burnAmount);
        
        assertEq(token.balanceOf(alice), aliceInitialBalance - burnAmount);
        assertEq(token.totalSupply(), initialSupply - burnAmount);
        assertEq(token.allowance(alice, owner), allowanceAmount - burnAmount);
    }

    // Fuzz testing
    function testFuzzTransfer(uint256 amount) public {
        amount = bound(amount, 1, token.balanceOf(owner));
        
        uint256 ownerInitialBalance = token.balanceOf(owner);
        uint256 aliceInitialBalance = token.balanceOf(alice);
        
        assertTrue(token.transfer(alice, amount));
        
        assertEq(token.balanceOf(owner), ownerInitialBalance - amount);
        assertEq(token.balanceOf(alice), aliceInitialBalance + amount);
    }

    function testFuzzMint(uint256 amount) public {
        amount = bound(amount, 1, token.remainingSupply());
        
        uint256 initialSupply = token.totalSupply();
        uint256 aliceInitialBalance = token.balanceOf(alice);
        
        token.mint(alice, amount, "fuzz test");
        
        assertEq(token.totalSupply(), initialSupply + amount);
        assertEq(token.balanceOf(alice), aliceInitialBalance + amount);
    }

    function testFuzzUSDCalculationsLarge(uint256 tokenAmount) public {
        // Test only with larger amounts to avoid precision issues
        tokenAmount = bound(tokenAmount, 1 ether, 1000000 ether); // 1 to 1M YHZ tokens
        
        uint256 usdValue = token.getUSDValue(tokenAmount);
        uint256 backToTokens = token.getTokenAmount(usdValue);
        
        // For larger amounts, precision should be exact
        assertEq(backToTokens, tokenAmount);
    }
}
