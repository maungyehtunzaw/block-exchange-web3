import { ref, computed, reactive } from 'vue'
import { ethers } from 'ethers'
import { HELLO_BLOCKCHAIN_ABI, type ContractInfo } from '@/contracts/types'
import { getContractAddress } from '@/config/contracts'

// Contract address - automatically uses latest deployment, but can be overridden
const CONTRACT_ADDRESS = ref<string>('')

// Reactive state
const state = reactive({
  isConnected: false,
  isConnecting: false,
  account: '',
  chainId: 0,
  balance: '0',
  error: '',
  provider: null as ethers.BrowserProvider | null,
  signer: null as ethers.JsonRpcSigner | null,
  contract: null as ethers.Contract | null
})

// Contract state
const contractState = reactive({
  message: '',
  owner: '',
  updateCount: 0n,
  contractBalance: 0n,
  isOwner: false,
  isLoading: false
})

export function useWeb3() {
  // Set contract address (call this after deployment)
  const setContractAddress = (address: string) => {
    CONTRACT_ADDRESS.value = address
    if (state.provider && state.signer) {
      state.contract = new ethers.Contract(address, HELLO_BLOCKCHAIN_ABI, state.signer)
    }
  }

  // Connect to MetaMask
  const connect = async () => {
    try {
      state.isConnecting = true
      state.error = ''

      if (!window.ethereum) {
        throw new Error('MetaMask is not installed. Please install MetaMask to continue.')
      }

      // Request account access
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      }) as string[]

      if (accounts.length === 0) {
        throw new Error('No accounts found. Please make sure MetaMask is unlocked.')
      }

      // Create provider and signer
      state.provider = new ethers.BrowserProvider(window.ethereum)
      state.signer = await state.provider.getSigner()
      state.account = accounts[0]
      state.isConnected = true

      // Get network info
      const network = await state.provider.getNetwork()
      state.chainId = Number(network.chainId)

      // Auto-set contract address based on network
      if (!CONTRACT_ADDRESS.value) {
        CONTRACT_ADDRESS.value = getContractAddress(state.chainId)
      }

      // Get balance
      const balance = await state.provider.getBalance(state.account)
      state.balance = ethers.formatEther(balance)

      // Create contract instance if address is available
      if (CONTRACT_ADDRESS.value) {
        state.contract = new ethers.Contract(
          CONTRACT_ADDRESS.value,
          HELLO_BLOCKCHAIN_ABI,
          state.signer
        )
        await loadContractData()
      }

      // Listen for account changes
      window.ethereum.on('accountsChanged', handleAccountsChanged)
      window.ethereum.on('chainChanged', handleChainChanged)

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Failed to connect to wallet'
      state.error = errorMessage
      console.error('Connection error:', error)
    } finally {
      state.isConnecting = false
    }
  }

  // Disconnect wallet
  const disconnect = () => {
    state.isConnected = false
    state.account = ''
    state.balance = '0'
    state.provider = null
    state.signer = null
    state.contract = null
    state.chainId = 0
    contractState.isOwner = false

    // Remove event listeners
    if (window.ethereum) {
      window.ethereum.removeListener('accountsChanged', handleAccountsChanged)
      window.ethereum.removeListener('chainChanged', handleChainChanged)
    }
  }

  // Load contract data
  const loadContractData = async () => {
    if (!state.contract) return

    try {
      contractState.isLoading = true

      // Get contract info
      const contractInfo: ContractInfo = await state.contract.getContractInfo()

      contractState.message = contractInfo.currentMessage
      contractState.owner = contractInfo.contractOwner
      contractState.updateCount = contractInfo.totalUpdates
      contractState.contractBalance = contractInfo.contractBalance

      // Check if current user is owner
      contractState.isOwner = state.account.toLowerCase() === contractState.owner.toLowerCase()

    } catch (error: any) {
      state.error = error.message || 'Failed to load contract data'
      console.error('Contract data loading error:', error)
    } finally {
      contractState.isLoading = false
    }
  }

  // Update message (owner only)
  const updateMessage = async (newMessage: string) => {
    if (!state.contract || !contractState.isOwner) {
      throw new Error('Only the owner can update the message')
    }

    if (!newMessage.trim()) {
      throw new Error('Message cannot be empty')
    }

    if (newMessage.length > 280) {
      throw new Error('Message too long (max 280 characters)')
    }

    try {
      const tx = await state.contract.updateMessage(newMessage)

      // Wait for transaction to be mined
      const receipt = await tx.wait()

      // Reload contract data
      await loadContractData()

      return {
        hash: tx.hash,
        gasUsed: receipt.gasUsed.toString()
      }
    } catch (error: any) {
      if (error.code === 'ACTION_REJECTED') {
        throw new Error('Transaction was rejected by user')
      }
      throw new Error(error.reason || error.message || 'Failed to update message')
    }
  }

  // Transfer ownership
  const transferOwnership = async (newOwner: string) => {
    if (!state.contract || !contractState.isOwner) {
      throw new Error('Only the owner can transfer ownership')
    }

    if (!ethers.isAddress(newOwner)) {
      throw new Error('Invalid address format')
    }

    try {
      const tx = await state.contract.transferOwnership(newOwner)
      const receipt = await tx.wait()

      await loadContractData()

      return {
        hash: tx.hash,
        gasUsed: receipt.gasUsed.toString()
      }
    } catch (error: any) {
      if (error.code === 'ACTION_REJECTED') {
        throw new Error('Transaction was rejected by user')
      }
      throw new Error(error.reason || error.message || 'Failed to transfer ownership')
    }
  }

  // Withdraw contract balance (owner only)
  const withdraw = async () => {
    if (!state.contract || !contractState.isOwner) {
      throw new Error('Only the owner can withdraw funds')
    }

    try {
      const tx = await state.contract.withdraw()
      const receipt = await tx.wait()

      await loadContractData()

      return {
        hash: tx.hash,
        gasUsed: receipt.gasUsed.toString()
      }
    } catch (error: any) {
      if (error.code === 'ACTION_REJECTED') {
        throw new Error('Transaction was rejected by user')
      }
      throw new Error(error.reason || error.message || 'Failed to withdraw funds')
    }
  }

  // Send ETH to contract
  const sendEther = async (amount: string) => {
    if (!state.signer) {
      throw new Error('Please connect your wallet first')
    }

    try {
      const tx = await state.signer.sendTransaction({
        to: CONTRACT_ADDRESS.value,
        value: ethers.parseEther(amount)
      })

      const receipt = await tx.wait()

      await loadContractData()

      // Update user balance
      const balance = await state.provider!.getBalance(state.account)
      state.balance = ethers.formatEther(balance)

      return {
        hash: tx.hash,
        gasUsed: receipt.gasUsed.toString()
      }
    } catch (error: any) {
      if (error.code === 'ACTION_REJECTED') {
        throw new Error('Transaction was rejected by user')
      }
      throw new Error(error.reason || error.message || 'Failed to send Ether')
    }
  }

  // Event handlers
  const handleAccountsChanged = (accounts: string[]) => {
    if (accounts.length === 0) {
      disconnect()
    } else {
      state.account = accounts[0]
      loadContractData()
    }
  }

  const handleChainChanged = () => {
    // Reload the page when chain changes for simplicity
    window.location.reload()
  }

  // Check if already connected on load
  const checkConnection = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_accounts' })
        if (accounts.length > 0) {
          await connect()
        }
      } catch (error) {
        console.error('Failed to check existing connection:', error)
      }
    }
  }

  // Computed properties
  const isLocalNetwork = computed(() => state.chainId === 31337 || state.chainId === 1337)
  const shortAddress = computed(() => {
    if (!state.account) return ''
    return `${state.account.slice(0, 6)}...${state.account.slice(-4)}`
  })

  const contractAddressShort = computed(() => {
    if (!CONTRACT_ADDRESS.value) return ''
    return `${CONTRACT_ADDRESS.value.slice(0, 6)}...${CONTRACT_ADDRESS.value.slice(-4)}`
  })

  return {
    // State
    state,
    contractState,
    CONTRACT_ADDRESS: CONTRACT_ADDRESS.value,

    // Computed
    isLocalNetwork,
    shortAddress,
    contractAddressShort,

    // Methods
    setContractAddress,
    connect,
    disconnect,
    loadContractData,
    updateMessage,
    transferOwnership,
    withdraw,
    sendEther,
    checkConnection
  }
}
