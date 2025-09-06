# Project 1: Hello Blockchain

Your first smart contract! This project will teach you the fundamentals of deploying and interacting with smart contracts.

## What You'll Learn

- Writing your first Solidity smart contract
- Deploying to a test network
- Interacting with contracts from a frontend
- Understanding gas fees and transactions

## Project Overview

We'll create a simple contract that:
- Stores a message on the blockchain
- Allows anyone to read the message
- Allows only the owner to update the message
- Emits events when the message changes

## Step 1: Smart Contract

Create `contracts/HelloBlockchain.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloBlockchain {
    // State variables
    string public message;
    address public owner;
    uint256 public updateCount;
    
    // Events
    event MessageUpdated(
        string newMessage, 
        address updatedBy, 
        uint256 timestamp
    );
    
    // Constructor - runs when contract is deployed
    constructor(string memory _initialMessage) {
        message = _initialMessage;
        owner = msg.sender;
        updateCount = 0;
        
        emit MessageUpdated(_initialMessage, msg.sender, block.timestamp);
    }
    
    // Modifier to check if caller is owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can update message");
        _;
    }
    
    // Function to update message (only owner)
    function updateMessage(string memory _newMessage) public onlyOwner {
        message = _newMessage;
        updateCount++;
        
        emit MessageUpdated(_newMessage, msg.sender, block.timestamp);
    }
    
    // Function to get message (anyone can call)
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    // Function to get contract info
    function getContractInfo() public view returns (
        string memory currentMessage,
        address contractOwner,
        uint256 totalUpdates
    ) {
        return (message, owner, updateCount);
    }
}
```

## Step 2: Deployment Script

Create `scripts/deploy.js`:

```javascript
const hre = require("hardhat");

async function main() {
    console.log("Deploying HelloBlockchain contract...");
    
    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    
    // Deploy the contract
    const HelloBlockchain = await hre.ethers.getContractFactory("HelloBlockchain");
    const helloBlockchain = await HelloBlockchain.deploy("Hello, Blockchain World!");
    
    await helloBlockchain.deployed();
    
    console.log("HelloBlockchain deployed to:", helloBlockchain.address);
    console.log("Transaction hash:", helloBlockchain.deployTransaction.hash);
    
    // Save contract info
    const contractInfo = {
        address: helloBlockchain.address,
        deployer: deployer.address,
        network: hre.network.name
    };
    
    console.log("Contract Info:", contractInfo);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

## Step 3: Test File

Create `test/HelloBlockchain.js`:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HelloBlockchain", function () {
    let HelloBlockchain, helloBlockchain, owner, addr1, addr2;
    
    beforeEach(async function () {
        // Get test accounts
        [owner, addr1, addr2] = await ethers.getSigners();
        
        // Deploy contract
        HelloBlockchain = await ethers.getContractFactory("HelloBlockchain");
        helloBlockchain = await HelloBlockchain.deploy("Initial message");
    });
    
    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await helloBlockchain.owner()).to.equal(owner.address);
        });
        
        it("Should set the initial message", async function () {
            expect(await helloBlockchain.message()).to.equal("Initial message");
        });
        
        it("Should initialize update count to 0", async function () {
            expect(await helloBlockchain.updateCount()).to.equal(0);
        });
    });
    
    describe("Message Updates", function () {
        it("Should allow owner to update message", async function () {
            await helloBlockchain.updateMessage("New message");
            expect(await helloBlockchain.message()).to.equal("New message");
            expect(await helloBlockchain.updateCount()).to.equal(1);
        });
        
        it("Should not allow non-owner to update message", async function () {
            await expect(
                helloBlockchain.connect(addr1).updateMessage("Hacker message")
            ).to.be.revertedWith("Only owner can update message");
        });
        
        it("Should emit MessageUpdated event", async function () {
            await expect(helloBlockchain.updateMessage("Event test"))
                .to.emit(helloBlockchain, "MessageUpdated")
                .withArgs("Event test", owner.address, await getBlockTimestamp());
        });
    });
    
    describe("View Functions", function () {
        it("Should return correct message", async function () {
            expect(await helloBlockchain.getMessage()).to.equal("Initial message");
        });
        
        it("Should return correct contract info", async function () {
            const info = await helloBlockchain.getContractInfo();
            expect(info.currentMessage).to.equal("Initial message");
            expect(info.contractOwner).to.equal(owner.address);
            expect(info.totalUpdates).to.equal(0);
        });
    });
});

async function getBlockTimestamp() {
    const blockNum = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(blockNum);
    return block.timestamp;
}
```

## Step 4: Frontend (Simple HTML)

Create `frontend/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Hello Blockchain</title>
    <script src="https://cdn.ethers.io/lib/ethers-5.7.2.umd.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        button { padding: 10px; margin: 5px; }
        input { padding: 8px; width: 300px; }
        .status { background: #f0f0f0; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>Hello Blockchain DApp</h1>
    
    <div class="status" id="status">Not connected</div>
    
    <button onclick="connectWallet()">Connect MetaMask</button>
    <button onclick="loadMessage()">Load Message</button>
    
    <h3>Current Message:</h3>
    <p id="currentMessage">-</p>
    
    <h3>Update Message (Owner Only):</h3>
    <input type="text" id="newMessage" placeholder="Enter new message">
    <button onclick="updateMessage()">Update</button>
    
    <h3>Contract Info:</h3>
    <p>Address: <span id="contractAddress">-</span></p>
    <p>Owner: <span id="contractOwner">-</span></p>
    <p>Updates: <span id="updateCount">-</span></p>
    
    <script>
        // Contract configuration
        const CONTRACT_ADDRESS = "YOUR_CONTRACT_ADDRESS_HERE";
        const CONTRACT_ABI = [
            // Add your contract ABI here
            // You can get this from artifacts/contracts/HelloBlockchain.sol/HelloBlockchain.json
        ];
        
        let provider, signer, contract;
        
        async function connectWallet() {
            try {
                if (!window.ethereum) {
                    alert("Please install MetaMask!");
                    return;
                }
                
                provider = new ethers.providers.Web3Provider(window.ethereum);
                await provider.send("eth_requestAccounts", []);
                signer = provider.getSigner();
                contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
                
                const address = await signer.getAddress();
                document.getElementById("status").innerText = `Connected: ${address}`;
                
                loadContractInfo();
            } catch (error) {
                console.error("Error connecting wallet:", error);
                document.getElementById("status").innerText = "Connection failed";
            }
        }
        
        async function loadMessage() {
            try {
                if (!contract) {
                    alert("Please connect wallet first!");
                    return;
                }
                
                const message = await contract.getMessage();
                document.getElementById("currentMessage").innerText = message;
            } catch (error) {
                console.error("Error loading message:", error);
            }
        }
        
        async function updateMessage() {
            try {
                if (!contract) {
                    alert("Please connect wallet first!");
                    return;
                }
                
                const newMessage = document.getElementById("newMessage").value;
                if (!newMessage) {
                    alert("Please enter a message!");
                    return;
                }
                
                const tx = await contract.updateMessage(newMessage);
                document.getElementById("status").innerText = "Transaction pending...";
                
                await tx.wait();
                document.getElementById("status").innerText = "Transaction confirmed!";
                
                loadMessage();
                loadContractInfo();
                document.getElementById("newMessage").value = "";
            } catch (error) {
                console.error("Error updating message:", error);
                document.getElementById("status").innerText = "Transaction failed";
            }
        }
        
        async function loadContractInfo() {
            try {
                const info = await contract.getContractInfo();
                document.getElementById("contractAddress").innerText = CONTRACT_ADDRESS;
                document.getElementById("contractOwner").innerText = info.contractOwner;
                document.getElementById("updateCount").innerText = info.totalUpdates.toString();
            } catch (error) {
                console.error("Error loading contract info:", error);
            }
        }
    </script>
</body>
</html>
```

## Step 5: Deployment Instructions

1. **Set up Hardhat project:**
```bash
mkdir hello-blockchain
cd hello-blockchain
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat
```

2. **Compile contract:**
```bash
npx hardhat compile
```

3. **Run tests:**
```bash
npx hardhat test
```

4. **Deploy to local network:**
```bash
npx hardhat node
# In another terminal:
npx hardhat run scripts/deploy.js --network localhost
```

5. **Deploy to testnet (Sepolia):**
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

## Understanding Gas Costs

- **Contract deployment**: ~200,000-500,000 gas
- **Message update**: ~30,000-50,000 gas
- **Reading message**: 0 gas (view function)

## Common Issues & Solutions

1. **"Insufficient funds"** - Get test ETH from faucet
2. **"Transaction reverted"** - Check if you're the owner
3. **"MetaMask not detected"** - Install MetaMask extension
4. **"Wrong network"** - Switch MetaMask to correct network

## What You've Learned

✅ Basic Solidity syntax and structure  
✅ State variables and functions  
✅ Events and modifiers  
✅ Contract deployment process  
✅ Frontend integration with ethers.js  
✅ MetaMask wallet connection  
✅ Transaction signing and confirmation  

---

**Next:** [Project 2 - Your Own Token (ERC-20)](./05-erc20-token.md)
