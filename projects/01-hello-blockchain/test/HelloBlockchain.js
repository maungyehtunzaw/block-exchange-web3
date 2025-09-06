const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HelloBlockchain", function () {
    let HelloBlockchain, helloBlockchain, owner, addr1, addr2;
    const INITIAL_MESSAGE = "Hello, Test World!";
    
    // Deploy a fresh contract before each test
    beforeEach(async function () {
        // Get test accounts
        [owner, addr1, addr2] = await ethers.getSigners();
        
        // Deploy contract
        HelloBlockchain = await ethers.getContractFactory("HelloBlockchain");
        helloBlockchain = await HelloBlockchain.deploy(INITIAL_MESSAGE);
        await helloBlockchain.deployed();
    });
    
    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await helloBlockchain.owner()).to.equal(owner.address);
        });
        
        it("Should set the initial message", async function () {
            expect(await helloBlockchain.message()).to.equal(INITIAL_MESSAGE);
            expect(await helloBlockchain.getMessage()).to.equal(INITIAL_MESSAGE);
        });
        
        it("Should initialize update count to 0", async function () {
            expect(await helloBlockchain.updateCount()).to.equal(0);
        });
        
        it("Should emit MessageUpdated event on deployment", async function () {
            // We need to deploy again to check the event
            const HelloBlockchainFactory = await ethers.getContractFactory("HelloBlockchain");
            
            await expect(HelloBlockchainFactory.deploy("Test Message"))
                .to.emit(HelloBlockchainFactory, "MessageUpdated")
                .withArgs("Test Message", owner.address, await getBlockTimestamp());
        });
    });
    
    describe("Message Updates", function () {
        it("Should allow owner to update message", async function () {
            const newMessage = "Updated message!";
            
            await helloBlockchain.updateMessage(newMessage);
            
            expect(await helloBlockchain.message()).to.equal(newMessage);
            expect(await helloBlockchain.updateCount()).to.equal(1);
        });
        
        it("Should increment update count correctly", async function () {
            await helloBlockchain.updateMessage("Message 1");
            expect(await helloBlockchain.updateCount()).to.equal(1);
            
            await helloBlockchain.updateMessage("Message 2");
            expect(await helloBlockchain.updateCount()).to.equal(2);
            
            await helloBlockchain.updateMessage("Message 3");
            expect(await helloBlockchain.updateCount()).to.equal(3);
        });
        
        it("Should not allow non-owner to update message", async function () {
            await expect(
                helloBlockchain.connect(addr1).updateMessage("Hacker message")
            ).to.be.revertedWith("HelloBlockchain: Only owner can call this function");
        });
        
        it("Should not allow empty message", async function () {
            await expect(
                helloBlockchain.updateMessage("")
            ).to.be.revertedWith("HelloBlockchain: Message cannot be empty");
        });
        
        it("Should not allow message longer than 280 characters", async function () {
            const longMessage = "a".repeat(281);
            
            await expect(
                helloBlockchain.updateMessage(longMessage)
            ).to.be.revertedWith("HelloBlockchain: Message too long (max 280 chars)");
        });
        
        it("Should allow exactly 280 character message", async function () {
            const maxMessage = "a".repeat(280);
            
            await expect(helloBlockchain.updateMessage(maxMessage))
                .to.not.be.reverted;
            
            expect(await helloBlockchain.message()).to.equal(maxMessage);
        });
        
        it("Should emit MessageUpdated event", async function () {
            const newMessage = "Event test message";
            const blockTimestamp = await getNextBlockTimestamp();
            
            await expect(helloBlockchain.updateMessage(newMessage))
                .to.emit(helloBlockchain, "MessageUpdated")
                .withArgs(newMessage, owner.address, blockTimestamp);
        });
    });
    
    describe("View Functions", function () {
        it("Should return correct message via getMessage()", async function () {
            expect(await helloBlockchain.getMessage()).to.equal(INITIAL_MESSAGE);
            
            const newMessage = "New message for testing";
            await helloBlockchain.updateMessage(newMessage);
            
            expect(await helloBlockchain.getMessage()).to.equal(newMessage);
        });
        
        it("Should return correct contract info", async function () {
            const info = await helloBlockchain.getContractInfo();
            
            expect(info.currentMessage).to.equal(INITIAL_MESSAGE);
            expect(info.contractOwner).to.equal(owner.address);
            expect(info.totalUpdates).to.equal(0);
            expect(info.contractBalance).to.equal(0);
        });
        
        it("Should update contract info after message updates", async function () {
            await helloBlockchain.updateMessage("Updated message");
            
            const info = await helloBlockchain.getContractInfo();
            expect(info.currentMessage).to.equal("Updated message");
            expect(info.totalUpdates).to.equal(1);
        });
    });
    
    describe("Ownership", function () {
        it("Should transfer ownership correctly", async function () {
            await helloBlockchain.transferOwnership(addr1.address);
            
            expect(await helloBlockchain.owner()).to.equal(addr1.address);
        });
        
        it("Should emit OwnershipTransferred event", async function () {
            await expect(helloBlockchain.transferOwnership(addr1.address))
                .to.emit(helloBlockchain, "OwnershipTransferred")
                .withArgs(owner.address, addr1.address);
        });
        
        it("Should allow new owner to update message", async function () {
            await helloBlockchain.transferOwnership(addr1.address);
            
            await expect(helloBlockchain.connect(addr1).updateMessage("New owner message"))
                .to.not.be.reverted;
            
            expect(await helloBlockchain.message()).to.equal("New owner message");
        });
        
        it("Should not allow old owner to update message after transfer", async function () {
            await helloBlockchain.transferOwnership(addr1.address);
            
            await expect(
                helloBlockchain.connect(owner).updateMessage("Old owner message")
            ).to.be.revertedWith("HelloBlockchain: Only owner can call this function");
        });
        
        it("Should not allow non-owner to transfer ownership", async function () {
            await expect(
                helloBlockchain.connect(addr1).transferOwnership(addr2.address)
            ).to.be.revertedWith("HelloBlockchain: Only owner can call this function");
        });
        
        it("Should not allow transfer to zero address", async function () {
            await expect(
                helloBlockchain.transferOwnership(ethers.constants.AddressZero)
            ).to.be.revertedWith("HelloBlockchain: New owner cannot be zero address");
        });
        
        it("Should not allow transfer to same owner", async function () {
            await expect(
                helloBlockchain.transferOwnership(owner.address)
            ).to.be.revertedWith("HelloBlockchain: New owner must be different from current owner");
        });
    });
    
    describe("ETH Handling", function () {
        it("Should accept ETH deposits", async function () {
            const depositAmount = ethers.utils.parseEther("1.0");
            
            await owner.sendTransaction({
                to: helloBlockchain.address,
                value: depositAmount
            });
            
            expect(await helloBlockchain.getBalance()).to.equal(depositAmount);
        });
        
        it("Should allow owner to withdraw ETH", async function () {
            const depositAmount = ethers.utils.parseEther("1.0");
            
            // Deposit ETH
            await owner.sendTransaction({
                to: helloBlockchain.address,
                value: depositAmount
            });
            
            // Record owner balance before withdrawal
            const ownerBalanceBefore = await owner.getBalance();
            
            // Withdraw (note: we need to account for gas costs)
            const tx = await helloBlockchain.withdraw();
            const receipt = await tx.wait();
            const gasUsed = receipt.gasUsed.mul(receipt.effectiveGasPrice);
            
            // Check balances
            const ownerBalanceAfter = await owner.getBalance();
            const contractBalance = await helloBlockchain.getBalance();
            
            expect(contractBalance).to.equal(0);
            expect(ownerBalanceAfter).to.equal(
                ownerBalanceBefore.add(depositAmount).sub(gasUsed)
            );
        });
        
        it("Should not allow non-owner to withdraw ETH", async function () {
            const depositAmount = ethers.utils.parseEther("1.0");
            
            await owner.sendTransaction({
                to: helloBlockchain.address,
                value: depositAmount
            });
            
            await expect(
                helloBlockchain.connect(addr1).withdraw()
            ).to.be.revertedWith("HelloBlockchain: Only owner can call this function");
        });
        
        it("Should not allow withdrawal when balance is zero", async function () {
            await expect(
                helloBlockchain.withdraw()
            ).to.be.revertedWith("HelloBlockchain: No ETH to withdraw");
        });
        
        it("Should update contract info with correct balance", async function () {
            const depositAmount = ethers.utils.parseEther("2.5");
            
            await owner.sendTransaction({
                to: helloBlockchain.address,
                value: depositAmount
            });
            
            const info = await helloBlockchain.getContractInfo();
            expect(info.contractBalance).to.equal(depositAmount);
        });
    });
    
    describe("Edge Cases and Security", function () {
        it("Should handle multiple rapid updates", async function () {
            const messages = ["Message 1", "Message 2", "Message 3", "Message 4", "Message 5"];
            
            for (let i = 0; i < messages.length; i++) {
                await helloBlockchain.updateMessage(messages[i]);
                expect(await helloBlockchain.message()).to.equal(messages[i]);
                expect(await helloBlockchain.updateCount()).to.equal(i + 1);
            }
        });
        
        it("Should handle special characters in messages", async function () {
            const specialMessage = "Hello! 🌍 Special chars: @#$%^&*()_+-=[]{}|;':\",./<>?";
            
            await helloBlockchain.updateMessage(specialMessage);
            expect(await helloBlockchain.message()).to.equal(specialMessage);
        });
        
        it("Should handle Unicode characters", async function () {
            const unicodeMessage = "Hello 世界! 🚀 Тест العالم";
            
            await helloBlockchain.updateMessage(unicodeMessage);
            expect(await helloBlockchain.message()).to.equal(unicodeMessage);
        });
        
        it("Should maintain state across multiple calls", async function () {
            // Update message
            await helloBlockchain.updateMessage("Test message 1");
            
            // Transfer ownership
            await helloBlockchain.transferOwnership(addr1.address);
            
            // New owner updates message
            await helloBlockchain.connect(addr1).updateMessage("Test message 2");
            
            // Check final state
            expect(await helloBlockchain.message()).to.equal("Test message 2");
            expect(await helloBlockchain.owner()).to.equal(addr1.address);
            expect(await helloBlockchain.updateCount()).to.equal(2);
        });
    });
    
    // Helper function to get the timestamp of the next block
    async function getNextBlockTimestamp() {
        const blockNum = await ethers.provider.getBlockNumber();
        const block = await ethers.provider.getBlock(blockNum);
        return block.timestamp + 1;
    }
    
    // Helper function to get current block timestamp
    async function getBlockTimestamp() {
        const blockNum = await ethers.provider.getBlockNumber();
        const block = await ethers.provider.getBlock(blockNum);
        return block.timestamp;
    }
});
