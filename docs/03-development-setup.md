# Development Environment Setup

This guide will help you set up everything needed to start building blockchain applications.

## Prerequisites

- Node.js (v16 or higher)
- Git
- A text editor (VS Code recommended)
- MetaMask browser extension

## Option 1: Hardhat (Recommended for Beginners)

### Installation

```bash
# Create new project directory
mkdir my-blockchain-project
cd my-blockchain-project

# Initialize npm project
npm init -y

# Install Hardhat
npm install --save-dev hardhat

# Initialize Hardhat project
npx hardhat
```

### Project Structure
```
my-blockchain-project/
├── contracts/          # Solidity smart contracts
├── scripts/           # Deployment scripts
├── test/             # Test files
├── hardhat.config.js # Hardhat configuration
└── package.json
```

### Basic Configuration

```javascript
// hardhat.config.js
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      // Built-in test network
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/YOUR_INFURA_KEY",
      accounts: ["YOUR_PRIVATE_KEY"]
    }
  }
};
```

### Essential Commands

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Start local blockchain
npx hardhat node

# Deploy to local network
npx hardhat run scripts/deploy.js --network localhost

# Deploy to testnet
npx hardhat run scripts/deploy.js --network sepolia
```

## Option 2: Foundry (Advanced)

Foundry is a fast, portable toolkit for Ethereum development.

### Installation

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Create new project
forge init my-project
cd my-project
```

### Project Structure
```
my-project/
├── src/              # Solidity contracts
├── test/             # Solidity tests
├── script/           # Deployment scripts
└── foundry.toml      # Configuration
```

### Essential Commands

```bash
# Build contracts
forge build

# Run tests
forge test

# Deploy contract
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## Frontend Development

### Web3 Libraries

**ethers.js** (Recommended)
```bash
npm install ethers
```

**web3.js** (Alternative)
```bash
npm install web3
```

### Basic Frontend Setup

```javascript
// Using ethers.js
import { ethers } from 'ethers';

// Connect to MetaMask
const provider = new ethers.providers.Web3Provider(window.ethereum);
await provider.send("eth_requestAccounts", []);
const signer = provider.getSigner();

// Contract interaction
const contract = new ethers.Contract(contractAddress, abi, signer);
const result = await contract.someFunction();
```

## Testing Networks

### Local Networks
- **Hardhat Network** - Built into Hardhat
- **Ganache** - Standalone local blockchain
- **Anvil** - Part of Foundry

### Testnets (Free Test ETH)
- **Sepolia** - Ethereum testnet
- **Goerli** - Ethereum testnet (being deprecated)
- **Mumbai** - Polygon testnet

### Getting Test ETH
- [Sepolia Faucet](https://sepoliafaucet.com/)
- [Goerli Faucet](https://goerlifaucet.com/)
- [Mumbai Faucet](https://faucet.polygon.technology/)

## Essential Tools

### Development
- **Remix IDE** - Browser-based Solidity IDE
- **VS Code** with Solidity extension
- **Hardhat** - Development framework
- **Foundry** - Advanced toolkit

### Testing & Debugging
- **Hardhat Console** - Interactive debugging
- **Tenderly** - Smart contract monitoring
- **OpenZeppelin Defender** - Operations platform

### Frontend
- **MetaMask** - Wallet connection
- **WalletConnect** - Multi-wallet support
- **Rainbow Kit** - React wallet connection
- **Web3Modal** - Universal wallet connection

## Security Tools

- **Slither** - Static analysis
- **MythX** - Security analysis platform
- **OpenZeppelin Contracts** - Secure contract library

## Next Steps

1. **Set up your development environment**
2. **Create your first "Hello World" contract**
3. **Deploy to a testnet**
4. **Build a simple frontend**

---

**Next:** [Project 1 - Hello Blockchain](./04-hello-blockchain.md)
