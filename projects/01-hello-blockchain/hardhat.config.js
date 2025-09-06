require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      // Built-in test network
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    // Add testnet configuration when needed
    // sepolia: {
    //   url: "https://sepolia.infura.io/v3/YOUR_INFURA_KEY",
    //   accounts: ["YOUR_PRIVATE_KEY"]
    // }
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
  },
  etherscan: {
    // Add API key for contract verification
    // apiKey: "YOUR_ETHERSCAN_API_KEY"
  }
};
