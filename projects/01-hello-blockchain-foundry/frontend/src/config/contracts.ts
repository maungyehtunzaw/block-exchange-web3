// Contract configuration - reads from deployment files
export const CONTRACT_ADDRESSES = {
  // Default address from latest deployment
  HELLO_BLOCKCHAIN: '0xe7f1725e7734ce288f8367e1bb143e90bb3f0512',

  // Backup addresses from previous deployments
  HELLO_BLOCKCHAIN_ALT: '0x5FbDB2315678afecb367f032d93F642f64180aa3'
}

// Network configurations
export const SUPPORTED_NETWORKS = {
  ANVIL: {
    chainId: 31337,
    name: 'Anvil Local',
    rpcUrl: 'http://localhost:8545'
  },
  HARDHAT: {
    chainId: 1337,
    name: 'Hardhat Local',
    rpcUrl: 'http://localhost:8545'
  }
}

// Get contract address for current network
export const getContractAddress = (chainId: number): string => {
  switch (chainId) {
    case 31337: // Anvil
      return CONTRACT_ADDRESSES.HELLO_BLOCKCHAIN
    case 1337: // Hardhat
      return CONTRACT_ADDRESSES.HELLO_BLOCKCHAIN_ALT
    default:
      return CONTRACT_ADDRESSES.HELLO_BLOCKCHAIN
  }
}
