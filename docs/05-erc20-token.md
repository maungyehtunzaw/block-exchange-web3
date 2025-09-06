# Project 2: Your Own Token (ERC-20)

Create your own cryptocurrency token! This project teaches you about the ERC-20 standard, token economics, and advanced Solidity features.

## What You'll Learn

- ERC-20 token standard
- Token minting and burning
- Allowances and transfers
- Access control patterns
- Token economics basics

## ERC-20 Standard Overview

The ERC-20 standard defines a common interface for tokens on Ethereum:

### Required Functions
- `totalSupply()` - Total number of tokens
- `balanceOf(address)` - Balance of specific address
- `transfer(to, amount)` - Transfer tokens
- `approve(spender, amount)` - Approve spending
- `transferFrom(from, to, amount)` - Transfer on behalf
- `allowance(owner, spender)` - Check approved amount

### Required Events
- `Transfer(from, to, value)`
- `Approval(owner, spender, value)`

## Step 1: Basic ERC-20 Token

Create `contracts/MyToken.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MyToken is IERC20 {
    // Token metadata
    string public name;
    string public symbol;
    uint8 public decimals;
    
    // Token state
    uint256 private _totalSupply;
    address public owner;
    
    // Balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Events
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        
        // Mint initial supply to deployer
        _totalSupply = _initialSupply * 10**_decimals;
        _balances[msg.sender] = _totalSupply;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
        emit Mint(msg.sender, _totalSupply);
    }
    
    // ERC-20 Functions
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public override returns (bool) {
        address from = msg.sender;
        _transfer(from, to, amount);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public view override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = msg.sender;
        
        // Check allowance
        uint256 currentAllowance = allowance(from, spender);
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        
        // Update allowance
        _approve(from, spender, currentAllowance - amount);
        
        // Transfer tokens
        _transfer(from, to, amount);
        
        return true;
    }
    
    // Additional Functions
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "ERC20: mint to zero address");
        
        _totalSupply += amount;
        _balances[to] += amount;
        
        emit Transfer(address(0), to, amount);
        emit Mint(to, amount);
    }
    
    function burn(uint256 amount) public {
        address from = msg.sender;
        require(_balances[from] >= amount, "ERC20: burn amount exceeds balance");
        
        _balances[from] -= amount;
        _totalSupply -= amount;
        
        emit Transfer(from, address(0), amount);
        emit Burn(from, amount);
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        
        address previousOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }
    
    // Internal functions
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
        
        _balances[from] -= amount;
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }
    
    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");
        
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }
}
```

## Step 2: Advanced Token with Features

Create `contracts/AdvancedToken.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyToken.sol";

contract AdvancedToken is MyToken {
    // Advanced features
    bool public paused = false;
    mapping(address => bool) public blacklisted;
    uint256 public maxTransactionAmount;
    uint256 public maxWalletAmount;
    
    // Tax system
    uint256 public taxRate = 100; // 1% (100 / 10000)
    address public taxRecipient;
    
    // Events
    event Paused();
    event Unpaused();
    event Blacklisted(address indexed account);
    event RemovedFromBlacklist(address indexed account);
    event TaxCollected(address indexed from, address indexed to, uint256 amount);
    
    // Modifiers
    modifier whenNotPaused() {
        require(!paused, "Token transfers are paused");
        _;
    }
    
    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "Account is blacklisted");
        _;
    }
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        uint256 _maxTransactionAmount,
        uint256 _maxWalletAmount,
        address _taxRecipient
    ) MyToken(_name, _symbol, _decimals, _initialSupply) {
        maxTransactionAmount = _maxTransactionAmount * 10**_decimals;
        maxWalletAmount = _maxWalletAmount * 10**_decimals;
        taxRecipient = _taxRecipient;
    }
    
    // Override transfer functions to add features
    function transfer(address to, uint256 amount) 
        public 
        override 
        whenNotPaused 
        notBlacklisted(msg.sender) 
        notBlacklisted(to) 
        returns (bool) 
    {
        _checkTransactionLimits(to, amount);
        _transferWithTax(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) 
        public 
        override 
        whenNotPaused 
        notBlacklisted(from) 
        notBlacklisted(to) 
        returns (bool) 
    {
        address spender = msg.sender;
        
        // Check allowance
        uint256 currentAllowance = allowance(from, spender);
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        
        // Update allowance
        _approve(from, spender, currentAllowance - amount);
        
        // Transfer with limits and tax
        _checkTransactionLimits(to, amount);
        _transferWithTax(from, to, amount);
        
        return true;
    }
    
    // Admin functions
    function pause() public onlyOwner {
        paused = true;
        emit Paused();
    }
    
    function unpause() public onlyOwner {
        paused = false;
        emit Unpaused();
    }
    
    function addToBlacklist(address account) public onlyOwner {
        blacklisted[account] = true;
        emit Blacklisted(account);
    }
    
    function removeFromBlacklist(address account) public onlyOwner {
        blacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }
    
    function setTaxRate(uint256 _taxRate) public onlyOwner {
        require(_taxRate <= 1000, "Tax rate cannot exceed 10%"); // Max 10%
        taxRate = _taxRate;
    }
    
    function setTaxRecipient(address _taxRecipient) public onlyOwner {
        require(_taxRecipient != address(0), "Tax recipient cannot be zero address");
        taxRecipient = _taxRecipient;
    }
    
    function setTransactionLimits(
        uint256 _maxTransactionAmount, 
        uint256 _maxWalletAmount
    ) public onlyOwner {
        maxTransactionAmount = _maxTransactionAmount * 10**decimals;
        maxWalletAmount = _maxWalletAmount * 10**decimals;
    }
    
    // Internal functions
    function _transferWithTax(address from, address to, uint256 amount) internal {
        uint256 taxAmount = (amount * taxRate) / 10000;
        uint256 transferAmount = amount - taxAmount;
        
        // Transfer main amount
        _transfer(from, to, transferAmount);
        
        // Transfer tax if applicable
        if (taxAmount > 0 && taxRecipient != address(0)) {
            _transfer(from, taxRecipient, taxAmount);
            emit TaxCollected(from, taxRecipient, taxAmount);
        }
    }
    
    function _checkTransactionLimits(address to, uint256 amount) internal view {
        // Check max transaction amount
        require(amount <= maxTransactionAmount, "Transfer amount exceeds maximum");
        
        // Check max wallet amount (don't apply to owner or tax recipient)
        if (to != owner && to != taxRecipient) {
            require(
                balanceOf(to) + amount <= maxWalletAmount, 
                "Recipient wallet would exceed maximum"
            );
        }
    }
}
```

## Step 3: Deployment Script

Create `scripts/deploy-token.js`:

```javascript
const hre = require("hardhat");

async function main() {
    console.log("Deploying Token contracts...");
    
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying with account:", deployer.address);
    
    // Token parameters
    const TOKEN_NAME = "YourToken";
    const TOKEN_SYMBOL = "YTK";
    const TOKEN_DECIMALS = 18;
    const INITIAL_SUPPLY = 1000000; // 1 million tokens
    
    // Deploy basic token
    console.log("\n1. Deploying Basic Token...");
    const MyToken = await hre.ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy(
        TOKEN_NAME,
        TOKEN_SYMBOL,
        TOKEN_DECIMALS,
        INITIAL_SUPPLY
    );
    await myToken.deployed();
    console.log("Basic Token deployed to:", myToken.address);
    
    // Deploy advanced token
    console.log("\n2. Deploying Advanced Token...");
    const AdvancedToken = await hre.ethers.getContractFactory("AdvancedToken");
    const advancedToken = await AdvancedToken.deploy(
        TOKEN_NAME + " Advanced",
        TOKEN_SYMBOL + "A",
        TOKEN_DECIMALS,
        INITIAL_SUPPLY,
        10000,  // Max transaction: 10,000 tokens
        100000, // Max wallet: 100,000 tokens
        deployer.address // Tax recipient
    );
    await advancedToken.deployed();
    console.log("Advanced Token deployed to:", advancedToken.address);
    
    // Display token information
    console.log("\n=== TOKEN INFORMATION ===");
    console.log("Basic Token:");
    console.log("- Address:", myToken.address);
    console.log("- Name:", await myToken.name());
    console.log("- Symbol:", await myToken.symbol());
    console.log("- Decimals:", await myToken.decimals());
    console.log("- Total Supply:", (await myToken.totalSupply()).toString());
    
    console.log("\nAdvanced Token:");
    console.log("- Address:", advancedToken.address);
    console.log("- Name:", await advancedToken.name());
    console.log("- Symbol:", await advancedToken.symbol());
    console.log("- Max Transaction:", (await advancedToken.maxTransactionAmount()).toString());
    console.log("- Max Wallet:", (await advancedToken.maxWalletAmount()).toString());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

## Step 4: Comprehensive Tests

Create `test/Token.js`:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token Contracts", function () {
    let MyToken, myToken, AdvancedToken, advancedToken;
    let owner, addr1, addr2, addr3;
    
    const TOKEN_NAME = "TestToken";
    const TOKEN_SYMBOL = "TST";
    const TOKEN_DECIMALS = 18;
    const INITIAL_SUPPLY = 1000000;
    
    beforeEach(async function () {
        [owner, addr1, addr2, addr3] = await ethers.getSigners();
        
        // Deploy basic token
        MyToken = await ethers.getContractFactory("MyToken");
        myToken = await MyToken.deploy(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, INITIAL_SUPPLY);
        
        // Deploy advanced token
        AdvancedToken = await ethers.getContractFactory("AdvancedToken");
        advancedToken = await AdvancedToken.deploy(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            TOKEN_DECIMALS,
            INITIAL_SUPPLY,
            10000,  // Max transaction
            50000,  // Max wallet
            addr3.address // Tax recipient
        );
    });
    
    describe("Basic Token", function () {
        it("Should have correct initial values", async function () {
            expect(await myToken.name()).to.equal(TOKEN_NAME);
            expect(await myToken.symbol()).to.equal(TOKEN_SYMBOL);
            expect(await myToken.decimals()).to.equal(TOKEN_DECIMALS);
            expect(await myToken.owner()).to.equal(owner.address);
        });
        
        it("Should mint initial supply to deployer", async function () {
            const expectedSupply = ethers.utils.parseUnits(INITIAL_SUPPLY.toString(), TOKEN_DECIMALS);
            expect(await myToken.totalSupply()).to.equal(expectedSupply);
            expect(await myToken.balanceOf(owner.address)).to.equal(expectedSupply);
        });
        
        it("Should transfer tokens correctly", async function () {
            const amount = ethers.utils.parseUnits("100", TOKEN_DECIMALS);
            
            await myToken.transfer(addr1.address, amount);
            
            expect(await myToken.balanceOf(addr1.address)).to.equal(amount);
        });
        
        it("Should handle approvals and allowances", async function () {
            const amount = ethers.utils.parseUnits("100", TOKEN_DECIMALS);
            
            await myToken.approve(addr1.address, amount);
            expect(await myToken.allowance(owner.address, addr1.address)).to.equal(amount);
            
            await myToken.connect(addr1).transferFrom(owner.address, addr2.address, amount);
            expect(await myToken.balanceOf(addr2.address)).to.equal(amount);
        });
        
        it("Should mint new tokens (owner only)", async function () {
            const mintAmount = ethers.utils.parseUnits("1000", TOKEN_DECIMALS);
            const initialSupply = await myToken.totalSupply();
            
            await myToken.mint(addr1.address, mintAmount);
            
            expect(await myToken.totalSupply()).to.equal(initialSupply.add(mintAmount));
            expect(await myToken.balanceOf(addr1.address)).to.equal(mintAmount);
        });
        
        it("Should burn tokens", async function () {
            const burnAmount = ethers.utils.parseUnits("1000", TOKEN_DECIMALS);
            const initialSupply = await myToken.totalSupply();
            const initialBalance = await myToken.balanceOf(owner.address);
            
            await myToken.burn(burnAmount);
            
            expect(await myToken.totalSupply()).to.equal(initialSupply.sub(burnAmount));
            expect(await myToken.balanceOf(owner.address)).to.equal(initialBalance.sub(burnAmount));
        });
    });
    
    describe("Advanced Token", function () {
        it("Should enforce transaction limits", async function () {
            const maxAmount = await advancedToken.maxTransactionAmount();
            const overLimit = maxAmount.add(1);
            
            await expect(
                advancedToken.transfer(addr1.address, overLimit)
            ).to.be.revertedWith("Transfer amount exceeds maximum");
        });
        
        it("Should enforce wallet limits", async function () {
            const maxWallet = await advancedToken.maxWalletAmount();
            const overLimit = maxWallet.add(1);
            
            await expect(
                advancedToken.transfer(addr1.address, overLimit)
            ).to.be.revertedWith("Recipient wallet would exceed maximum");
        });
        
        it("Should collect tax on transfers", async function () {
            const amount = ethers.utils.parseUnits("1000", TOKEN_DECIMALS);
            const taxRate = await advancedToken.taxRate();
            const expectedTax = amount.mul(taxRate).div(10000);
            const expectedTransfer = amount.sub(expectedTax);
            
            const initialTaxBalance = await advancedToken.balanceOf(addr3.address);
            
            await advancedToken.transfer(addr1.address, amount);
            
            expect(await advancedToken.balanceOf(addr1.address)).to.equal(expectedTransfer);
            expect(await advancedToken.balanceOf(addr3.address)).to.equal(
                initialTaxBalance.add(expectedTax)
            );
        });
        
        it("Should pause and unpause transfers", async function () {
            await advancedToken.pause();
            
            await expect(
                advancedToken.transfer(addr1.address, 100)
            ).to.be.revertedWith("Token transfers are paused");
            
            await advancedToken.unpause();
            await advancedToken.transfer(addr1.address, 100); // Should work now
        });
        
        it("Should blacklist addresses", async function () {
            await advancedToken.addToBlacklist(addr1.address);
            
            await expect(
                advancedToken.transfer(addr1.address, 100)
            ).to.be.revertedWith("Account is blacklisted");
            
            await advancedToken.removeFromBlacklist(addr1.address);
            await advancedToken.transfer(addr1.address, 100); // Should work now
        });
    });
});
```

## Step 5: Token Economics Dashboard

Create `frontend/token-dashboard.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Token Dashboard</title>
    <script src="https://cdn.ethers.io/lib/ethers-5.7.2.umd.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .card { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .stat { text-align: center; padding: 15px; background: #f8f9fa; border-radius: 6px; margin: 10px 0; }
        .stat-value { font-size: 24px; font-weight: bold; color: #2c3e50; }
        .stat-label { font-size: 14px; color: #7f8c8d; }
        input, select { padding: 10px; border: 1px solid #ddd; border-radius: 4px; width: 200px; margin: 5px; }
        button { background: #3498db; color: white; padding: 12px 20px; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }
        button:hover { background: #2980b9; }
        button:disabled { background: #bdc3c7; cursor: not-allowed; }
        .success { color: #27ae60; background: #d5f4e6; padding: 10px; border-radius: 4px; margin: 10px 0; }
        .error { color: #e74c3c; background: #fadbd8; padding: 10px; border-radius: 4px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🪙 Token Dashboard</h1>
        
        <div class="card">
            <h3>Connection Status</h3>
            <div id="status">Not connected</div>
            <button onclick="connectWallet()">Connect MetaMask</button>
        </div>
        
        <div class="grid">
            <div class="card">
                <h3>Token Information</h3>
                <div class="stat">
                    <div class="stat-value" id="tokenName">-</div>
                    <div class="stat-label">Token Name</div>
                </div>
                <div class="stat">
                    <div class="stat-value" id="tokenSymbol">-</div>
                    <div class="stat-label">Symbol</div>
                </div>
                <div class="stat">
                    <div class="stat-value" id="totalSupply">-</div>
                    <div class="stat-label">Total Supply</div>
                </div>
                <div class="stat">
                    <div class="stat-value" id="userBalance">-</div>
                    <div class="stat-label">Your Balance</div>
                </div>
            </div>
            
            <div class="card">
                <h3>Transfer Tokens</h3>
                <input type="text" id="transferTo" placeholder="Recipient Address">
                <input type="number" id="transferAmount" placeholder="Amount">
                <button onclick="transferTokens()">Transfer</button>
                
                <h4>Approve & Transfer From</h4>
                <input type="text" id="approveSpender" placeholder="Spender Address">
                <input type="number" id="approveAmount" placeholder="Approval Amount">
                <button onclick="approveTokens()">Approve</button>
                
                <input type="text" id="transferFromAddress" placeholder="From Address">
                <input type="text" id="transferFromTo" placeholder="To Address">
                <input type="number" id="transferFromAmount" placeholder="Amount">
                <button onclick="transferFromTokens()">Transfer From</button>
            </div>
        </div>
        
        <div class="grid">
            <div class="card">
                <h3>Owner Functions</h3>
                <div id="ownerSection">
                    <h4>Mint Tokens</h4>
                    <input type="text" id="mintTo" placeholder="Mint To Address">
                    <input type="number" id="mintAmount" placeholder="Mint Amount">
                    <button onclick="mintTokens()">Mint</button>
                    
                    <h4>Burn Tokens</h4>
                    <input type="number" id="burnAmount" placeholder="Burn Amount">
                    <button onclick="burnTokens()">Burn</button>
                </div>
            </div>
            
            <div class="card">
                <h3>Advanced Features</h3>
                <div id="advancedSection">
                    <div class="stat">
                        <div class="stat-value" id="maxTxAmount">-</div>
                        <div class="stat-label">Max Transaction</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" id="maxWalletAmount">-</div>
                        <div class="stat-label">Max Wallet</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" id="taxRate">-</div>
                        <div class="stat-label">Tax Rate (%)</div>
                    </div>
                    
                    <h4>Admin Controls</h4>
                    <button onclick="pauseToken()">Pause</button>
                    <button onclick="unpauseToken()">Unpause</button>
                    
                    <input type="text" id="blacklistAddress" placeholder="Address to Blacklist">
                    <button onclick="addToBlacklist()">Blacklist</button>
                    <button onclick="removeFromBlacklist()">Remove from Blacklist</button>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h3>Transaction History</h3>
            <div id="transactionHistory"></div>
        </div>
    </div>
    
    <script>
        // Contract configuration - Update these with your deployed contract details
        const BASIC_TOKEN_ADDRESS = "YOUR_BASIC_TOKEN_ADDRESS";
        const ADVANCED_TOKEN_ADDRESS = "YOUR_ADVANCED_TOKEN_ADDRESS";
        const TOKEN_ABI = [
            // Add your contract ABI here
        ];
        
        let provider, signer, basicToken, advancedToken, userAddress;
        let currentToken = 'basic'; // 'basic' or 'advanced'
        
        async function connectWallet() {
            try {
                if (!window.ethereum) {
                    alert("Please install MetaMask!");
                    return;
                }
                
                provider = new ethers.providers.Web3Provider(window.ethereum);
                await provider.send("eth_requestAccounts", []);
                signer = provider.getSigner();
                userAddress = await signer.getAddress();
                
                // Initialize contracts
                basicToken = new ethers.Contract(BASIC_TOKEN_ADDRESS, TOKEN_ABI, signer);
                advancedToken = new ethers.Contract(ADVANCED_TOKEN_ADDRESS, TOKEN_ABI, signer);
                
                document.getElementById("status").innerHTML = `✅ Connected: ${userAddress}`;
                
                await loadTokenData();
            } catch (error) {
                console.error("Connection error:", error);
                document.getElementById("status").innerHTML = "❌ Connection failed";
            }
        }
        
        async function loadTokenData() {
            try {
                const token = currentToken === 'basic' ? basicToken : advancedToken;
                
                // Basic token info
                const name = await token.name();
                const symbol = await token.symbol();
                const totalSupply = await token.totalSupply();
                const userBalance = await token.balanceOf(userAddress);
                const decimals = await token.decimals();
                
                document.getElementById("tokenName").textContent = name;
                document.getElementById("tokenSymbol").textContent = symbol;
                document.getElementById("totalSupply").textContent = 
                    parseFloat(ethers.utils.formatUnits(totalSupply, decimals)).toLocaleString();
                document.getElementById("userBalance").textContent = 
                    parseFloat(ethers.utils.formatUnits(userBalance, decimals)).toLocaleString();
                
                // Advanced features (if available)
                if (currentToken === 'advanced') {
                    try {
                        const maxTx = await token.maxTransactionAmount();
                        const maxWallet = await token.maxWalletAmount();
                        const taxRate = await token.taxRate();
                        
                        document.getElementById("maxTxAmount").textContent = 
                            parseFloat(ethers.utils.formatUnits(maxTx, decimals)).toLocaleString();
                        document.getElementById("maxWalletAmount").textContent = 
                            parseFloat(ethers.utils.formatUnits(maxWallet, decimals)).toLocaleString();
                        document.getElementById("taxRate").textContent = 
                            (taxRate.toNumber() / 100).toFixed(2);
                        
                        document.getElementById("advancedSection").style.display = "block";
                    } catch (e) {
                        document.getElementById("advancedSection").style.display = "none";
                    }
                }
                
                // Check if user is owner
                try {
                    const owner = await token.owner();
                    const isOwner = owner.toLowerCase() === userAddress.toLowerCase();
                    document.getElementById("ownerSection").style.display = isOwner ? "block" : "none";
                } catch (e) {
                    document.getElementById("ownerSection").style.display = "none";
                }
                
            } catch (error) {
                console.error("Error loading token data:", error);
            }
        }
        
        async function transferTokens() {
            try {
                const token = currentToken === 'basic' ? basicToken : advancedToken;
                const to = document.getElementById("transferTo").value;
                const amount = document.getElementById("transferAmount").value;
                const decimals = await token.decimals();
                
                if (!to || !amount) {
                    alert("Please fill in all fields");
                    return;
                }
                
                const amountWei = ethers.utils.parseUnits(amount, decimals);
                const tx = await token.transfer(to, amountWei);
                
                showMessage(`Transaction sent: ${tx.hash}`, 'success');
                await tx.wait();
                showMessage("Transfer completed!", 'success');
                
                document.getElementById("transferTo").value = "";
                document.getElementById("transferAmount").value = "";
                await loadTokenData();
                
            } catch (error) {
                showMessage(`Transfer failed: ${error.message}`, 'error');
            }
        }
        
        async function approveTokens() {
            try {
                const token = currentToken === 'basic' ? basicToken : advancedToken;
                const spender = document.getElementById("approveSpender").value;
                const amount = document.getElementById("approveAmount").value;
                const decimals = await token.decimals();
                
                if (!spender || !amount) {
                    alert("Please fill in all fields");
                    return;
                }
                
                const amountWei = ethers.utils.parseUnits(amount, decimals);
                const tx = await token.approve(spender, amountWei);
                
                showMessage(`Approval sent: ${tx.hash}`, 'success');
                await tx.wait();
                showMessage("Approval completed!", 'success');
                
                document.getElementById("approveSpender").value = "";
                document.getElementById("approveAmount").value = "";
                
            } catch (error) {
                showMessage(`Approval failed: ${error.message}`, 'error');
            }
        }
        
        async function mintTokens() {
            try {
                const token = currentToken === 'basic' ? basicToken : advancedToken;
                const to = document.getElementById("mintTo").value;
                const amount = document.getElementById("mintAmount").value;
                const decimals = await token.decimals();
                
                if (!to || !amount) {
                    alert("Please fill in all fields");
                    return;
                }
                
                const amountWei = ethers.utils.parseUnits(amount, decimals);
                const tx = await token.mint(to, amountWei);
                
                showMessage(`Mint transaction sent: ${tx.hash}`, 'success');
                await tx.wait();
                showMessage("Tokens minted successfully!", 'success');
                
                document.getElementById("mintTo").value = "";
                document.getElementById("mintAmount").value = "";
                await loadTokenData();
                
            } catch (error) {
                showMessage(`Mint failed: ${error.message}`, 'error');
            }
        }
        
        async function burnTokens() {
            try {
                const token = currentToken === 'basic' ? basicToken : advancedToken;
                const amount = document.getElementById("burnAmount").value;
                const decimals = await token.decimals();
                
                if (!amount) {
                    alert("Please enter burn amount");
                    return;
                }
                
                const amountWei = ethers.utils.parseUnits(amount, decimals);
                const tx = await token.burn(amountWei);
                
                showMessage(`Burn transaction sent: ${tx.hash}`, 'success');
                await tx.wait();
                showMessage("Tokens burned successfully!", 'success');
                
                document.getElementById("burnAmount").value = "";
                await loadTokenData();
                
            } catch (error) {
                showMessage(`Burn failed: ${error.message}`, 'error');
            }
        }
        
        function showMessage(message, type) {
            const messageDiv = document.createElement('div');
            messageDiv.className = type;
            messageDiv.textContent = message;
            
            const container = document.querySelector('.container');
            container.insertBefore(messageDiv, container.children[1]);
            
            setTimeout(() => messageDiv.remove(), 5000);
        }
        
        // Auto-refresh data every 30 seconds
        setInterval(async () => {
            if (provider && signer) {
                await loadTokenData();
            }
        }, 30000);
    </script>
</body>
</html>
```

## What You've Learned

✅ **ERC-20 standard** implementation  
✅ **Token economics** concepts  
✅ **Advanced features** (pause, blacklist, tax)  
✅ **Access control** patterns  
✅ **Gas optimization** techniques  
✅ **Comprehensive testing** strategies  
✅ **Real-world token** considerations  

## Common Token Use Cases

- **Utility tokens** - Access to services
- **Governance tokens** - Voting rights
- **Reward tokens** - Incentive systems  
- **Stablecoins** - Price-stable assets
- **Security tokens** - Asset representation

---

**Next:** [Project 3 - NFT Minting App (ERC-721)](./06-nft-minting.md)
