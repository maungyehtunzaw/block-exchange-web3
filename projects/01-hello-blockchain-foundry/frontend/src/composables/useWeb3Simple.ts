import { ref, reactive, computed } from 'vue'
import { ethers } from 'ethers'
import { HELLO_BLOCKCHAIN_ABI } from '@/contracts/types'

interface WalletState {
  isConnected: boolean
  isConnecting: boolean
  account: string
  chainId: number
  balance: string
  error: string
}

interface ContractState {
  message: string
  owner: string
  updateCount: string
  contractBalance: string
  isOwner: boolean
  isLoading: boolean
}

const walletState = reactive<WalletState>({
  isConnected: false,
  isConnecting: false,
  account: '',
  chainId: 0,
  balance: '0',
  error: ''
})

const contractState = reactive<ContractState>({
  message: '',
  owner: '',
  updateCount: '0',
  contractBalance: '0',
  isOwner: false,
  isLoading: false
})

let provider: ethers.BrowserProvider | null = null
let signer: ethers.JsonRpcSigner | null = null
let contract: ethers.Contract | null = null

const CONTRACT_ADDRESS = ref<string>('')

export function useWeb3() {
  const setContractAddress = (address: string) => {
    CONTRACT_ADDRESS.value = address
    if (provider && signer) {
      contract = new ethers.Contract(address, HELLO_BLOCKCHAIN_ABI, signer)
    }
  }

  const connect = async () => {
    try {
      walletState.isConnecting = true
      walletState.error = ''

      if (!window.ethereum) {
        throw new Error('MetaMask not found. Please install MetaMask.')
      }

      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      }) as string[]

      if (!accounts || accounts.length === 0) {
        throw new Error('No accounts found')
      }

      provider = new ethers.BrowserProvider(window.ethereum)
      signer = await provider.getSigner()
      
      walletState.account = accounts[0]
      walletState.isConnected = true

      const network = await provider.getNetwork()
      walletState.chainId = Number(network.chainId)

      const balance = await provider.getBalance(walletState.account)
      walletState.balance = ethers.formatEther(balance)

      if (CONTRACT_ADDRESS.value) {
        contract = new ethers.Contract(CONTRACT_ADDRESS.value, HELLO_BLOCKCHAIN_ABI, signer)
        await loadContractData()
      }

    } catch (error) {
      const message = error instanceof Error ? error.message : 'Connection failed'
      walletState.error = message
    } finally {
      walletState.isConnecting = false
    }
  }

  const disconnect = () => {
    walletState.isConnected = false
    walletState.account = ''
    walletState.balance = '0'
    walletState.chainId = 0
    provider = null
    signer = null
    contract = null
    contractState.isOwner = false
  }

  const loadContractData = async () => {
    if (!contract) return

    try {
      contractState.isLoading = true

      const [message, owner, updateCount, contractBalance] = await Promise.all([
        contract.getMessage(),
        contract.owner(),
        contract.updateCount(),
        contract.getBalance()
      ])

      contractState.message = message
      contractState.owner = owner
      contractState.updateCount = updateCount.toString()
      contractState.contractBalance = ethers.formatEther(contractBalance)
      contractState.isOwner = walletState.account.toLowerCase() === owner.toLowerCase()

    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to load contract data'
      walletState.error = message
    } finally {
      contractState.isLoading = false
    }
  }

  const updateMessage = async (newMessage: string): Promise<string> => {
    if (!contract || !contractState.isOwner) {
      throw new Error('Only owner can update message')
    }

    if (!newMessage.trim()) {
      throw new Error('Message cannot be empty')
    }

    if (newMessage.length > 280) {
      throw new Error('Message too long (max 280 characters)')
    }

    const tx = await contract.updateMessage(newMessage)
    await tx.wait()
    await loadContractData()
    
    return tx.hash
  }

  const transferOwnership = async (newOwner: string): Promise<string> => {
    if (!contract || !contractState.isOwner) {
      throw new Error('Only owner can transfer ownership')
    }

    if (!ethers.isAddress(newOwner)) {
      throw new Error('Invalid address')
    }

    const tx = await contract.transferOwnership(newOwner)
    await tx.wait()
    await loadContractData()
    
    return tx.hash
  }

  const withdraw = async (): Promise<string> => {
    if (!contract || !contractState.isOwner) {
      throw new Error('Only owner can withdraw')
    }

    const tx = await contract.withdraw()
    await tx.wait()
    await loadContractData()
    
    return tx.hash
  }

  const sendEther = async (amount: string): Promise<string> => {
    if (!signer) {
      throw new Error('Wallet not connected')
    }

    const tx = await signer.sendTransaction({
      to: CONTRACT_ADDRESS.value,
      value: ethers.parseEther(amount)
    })

    await tx.wait()
    await loadContractData()

    const balance = await provider!.getBalance(walletState.account)
    walletState.balance = ethers.formatEther(balance)
    
    return tx.hash
  }

  // Computed properties
  const shortAddress = computed(() => {
    if (!walletState.account) return ''
    return `${walletState.account.slice(0, 6)}...${walletState.account.slice(-4)}`
  })

  const isLocalNetwork = computed(() => {
    return walletState.chainId === 31337 || walletState.chainId === 1337
  })

  return {
    // State
    walletState,
    contractState,
    
    // Computed
    shortAddress,
    isLocalNetwork,
    
    // Methods
    setContractAddress,
    connect,
    disconnect,
    loadContractData,
    updateMessage,
    transferOwnership,
    withdraw,
    sendEther
  }
}
