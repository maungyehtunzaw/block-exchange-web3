<template>
  <div class="home">
    <div class="hero">
      <h1>Welcome to Hello Blockchain! 🎉</h1>
      <p class="hero-description">
        Your first smart contract deployed on the blockchain. Connect your wallet to interact with it!
      </p>
    </div>

    <!-- Contract Setup -->
    <div v-if="!contractAddress" class="setup-section">
      <div class="card">
        <h2>📋 Contract Setup</h2>
        <p>Enter your deployed contract address to get started:</p>
        
        <div class="input-group">
          <input 
            v-model="contractAddressInput"
            type="text"
            placeholder="0x..."
            class="address-input"
            @keyup.enter="handleSetContract"
          />
          <button 
            @click="handleSetContract"
            :disabled="!contractAddressInput"
            class="btn-primary"
          >
            Set Address
          </button>
        </div>

        <div class="deployment-help">
          <h3>Need to deploy? Run these commands:</h3>
          <div class="code-block">
            <pre><code># Start local blockchain (in one terminal)
anvil

# Deploy contract (in another terminal)  
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80</code></pre>
          </div>
        </div>
      </div>
    </div>

    <!-- Contract Interface -->
    <div v-else class="contract-section">
      <!-- Connection Status -->
      <div class="status-card">
        <h2>📊 Status</h2>
        <div class="status-grid">
          <div class="status-item">
            <span class="label">Contract:</span>
            <span class="value">{{ contractAddressShort }}</span>
          </div>
          <div class="status-item">
            <span class="label">Connected:</span>
            <span class="value" :class="{ 'success': walletState.isConnected, 'error': !walletState.isConnected }">
              {{ walletState.isConnected ? 'Yes' : 'No' }}
            </span>
          </div>
        </div>
      </div>

      <!-- Contract Info -->
      <div v-if="walletState.isConnected" class="card">
        <div class="card-header">
          <h2>📄 Contract Information</h2>
          <button @click="loadContractData" :disabled="contractState.isLoading" class="btn-secondary">
            {{ contractState.isLoading ? 'Loading...' : '🔄 Refresh' }}
          </button>
        </div>

        <div class="info-grid">
          <div class="info-item">
            <h3>Current Message</h3>
            <p class="message">{{ contractState.message || 'No message set' }}</p>
          </div>
          
          <div class="info-item">
            <h3>Owner</h3>
            <p class="address">{{ formatAddress(contractState.owner) }}</p>
            <span v-if="contractState.isOwner" class="owner-badge">👑 You are the owner!</span>
          </div>
          
          <div class="info-item">
            <h3>Update Count</h3>
            <p class="count">{{ contractState.updateCount }}</p>
          </div>
          
          <div class="info-item">
            <h3>Contract Balance</h3>
            <p class="balance">{{ contractState.contractBalance }} ETH</p>
          </div>
        </div>
      </div>

      <!-- Message Update (Owner Only) -->
      <div v-if="walletState.isConnected && contractState.isOwner" class="card">
        <h2>✏️ Update Message (Owner Only)</h2>
        <div class="update-form">
          <div class="input-group">
            <input 
              v-model="newMessage"
              type="text"
              placeholder="Enter new message..."
              maxlength="280"
              class="message-input"
              @keyup.enter="handleUpdateMessage"
            />
            <div class="char-counter">{{ newMessage.length }}/280</div>
          </div>
          
          <button 
            @click="handleUpdateMessage"
            :disabled="!newMessage.trim() || isLoading"
            class="btn-primary"
          >
            {{ isLoading ? 'Updating...' : 'Update Message' }}
          </button>
        </div>
      </div>

      <!-- Send ETH -->
      <div v-if="walletState.isConnected" class="card">
        <h2>💰 Send ETH to Contract</h2>
        <div class="send-form">
          <div class="input-group">
            <input 
              v-model="ethAmount"
              type="number"
              step="0.001"
              min="0"
              placeholder="0.1"
              class="eth-input"
            />
            <span class="unit">ETH</span>
          </div>
          
          <button 
            @click="handleSendEther"
            :disabled="!ethAmount || parseFloat(ethAmount) <= 0 || isLoading"
            class="btn-primary"
          >
            {{ isLoading ? 'Sending...' : 'Send ETH' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useWeb3 } from '@/composables/useWeb3Simple'
import { ethers } from 'ethers'

const {
  walletState,
  contractState,
  isLocalNetwork,
  setContractAddress,
  loadContractData,
  updateMessage,
  sendEther
} = useWeb3()

// Reactive data
const contractAddressInput = ref('')
const contractAddress = ref('')
const newMessage = ref('')
const ethAmount = ref('')
const isLoading = ref(false)

// Computed
const contractAddressShort = computed(() => {
  if (!contractAddress.value) return ''
  return `${contractAddress.value.slice(0, 6)}...${contractAddress.value.slice(-4)}`
})

// Methods
const handleSetContract = () => {
  if (isValidAddress(contractAddressInput.value)) {
    contractAddress.value = contractAddressInput.value
    setContractAddress(contractAddressInput.value)
    loadContractData()
  } else {
    alert('Please enter a valid Ethereum address')
  }
}

const isValidAddress = (address: string): boolean => {
  return ethers.isAddress(address)
}

const formatAddress = (address: string): string => {
  if (!address) return ''
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}

const handleUpdateMessage = async () => {
  if (!newMessage.value.trim()) return
  
  try {
    isLoading.value = true
    await updateMessage(newMessage.value)
    newMessage.value = ''
  } catch (error) {
    console.error('Update failed:', error)
    alert(error instanceof Error ? error.message : 'Update failed')
  } finally {
    isLoading.value = false
  }
}

const handleSendEther = async () => {
  if (!ethAmount.value) return
  
  try {
    isLoading.value = true
    await sendEther(ethAmount.value)
    ethAmount.value = ''
  } catch (error) {
    console.error('Send failed:', error)
    alert(error instanceof Error ? error.message : 'Send failed')
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped>
.home {
  max-width: 1000px;
  margin: 0 auto;
}

.hero {
  text-align: center;
  margin-bottom: 3rem;
  color: white;
}

.hero h1 {
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: 1rem;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.hero-description {
  font-size: 1.25rem;
  opacity: 0.9;
  max-width: 600px;
  margin: 0 auto;
}

.card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 1rem;
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.card h2 {
  margin-top: 0;
  color: #1e293b;
  font-size: 1.5rem;
  font-weight: 700;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.status-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 1rem;
  padding: 1.5rem;
  margin-bottom: 2rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.status-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.status-item {
  display: flex;
  justify-content: space-between;
  padding: 0.75rem;
  background: rgba(248, 250, 252, 0.8);
  border-radius: 0.5rem;
}

.status-item .label {
  font-weight: 600;
  color: #64748b;
}

.status-item .value {
  font-weight: 700;
}

.status-item .value.success {
  color: #16a34a;
}

.status-item .value.error {
  color: #dc2626;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.info-item {
  padding: 1rem;
  background: rgba(248, 250, 252, 0.8);
  border-radius: 0.75rem;
  border-left: 4px solid #667eea;
}

.info-item h3 {
  margin: 0 0 0.5rem 0;
  font-size: 0.875rem;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-item p {
  margin: 0;
  font-size: 1.125rem;
  font-weight: 700;
  color: #1e293b;
}

.message {
  font-style: italic;
  word-break: break-word;
}

.owner-badge {
  display: inline-block;
  background: linear-gradient(45deg, #fbbf24, #f59e0b);
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  font-size: 0.75rem;
  font-weight: 600;
  margin-top: 0.5rem;
}

.input-group {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  align-items: center;
}

.address-input,
.message-input,
.eth-input {
  flex: 1;
  padding: 1rem;
  border: 2px solid #e2e8f0;
  border-radius: 0.75rem;
  font-size: 1rem;
  transition: all 0.2s;
}

.address-input:focus,
.message-input:focus,
.eth-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.char-counter {
  font-size: 0.875rem;
  color: #64748b;
  min-width: 60px;
}

.unit {
  font-weight: 600;
  color: #64748b;
  min-width: 40px;
}

.btn-primary,
.btn-secondary,
.btn-danger {
  padding: 1rem 1.5rem;
  border: none;
  border-radius: 0.75rem;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s;
  min-width: 120px;
}

.btn-primary {
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 4px 14px rgba(102, 126, 234, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
  background: #f8fafc;
  color: #64748b;
  border: 2px solid #e2e8f0;
}

.btn-secondary:hover:not(:disabled) {
  background: #f1f5f9;
  border-color: #cbd5e1;
}

.btn-danger {
  background: linear-gradient(45deg, #ef4444, #dc2626);
  color: white;
  box-shadow: 0 4px 14px rgba(239, 68, 68, 0.3);
}

.btn-danger:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
}

.btn-primary:disabled,
.btn-secondary:disabled,
.btn-danger:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.code-block {
  background: #1e293b;
  color: #e2e8f0;
  padding: 1.5rem;
  border-radius: 0.75rem;
  margin-top: 1rem;
  overflow-x: auto;
}

.code-block pre {
  margin: 0;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
  font-size: 0.875rem;
  line-height: 1.5;
}

.deployment-help h3 {
  color: #64748b;
  font-size: 1rem;
  margin-top: 1.5rem;
  margin-bottom: 0.5rem;
}

@media (max-width: 768px) {
  .hero h1 {
    font-size: 2rem;
  }
  
  .hero-description {
    font-size: 1rem;
  }
  
  .card {
    padding: 1.5rem;
  }
  
  .input-group {
    flex-direction: column;
    align-items: stretch;
  }
  
  .info-grid {
    grid-template-columns: 1fr;
  }
  
  .status-grid {
    grid-template-columns: 1fr;
  }
}
</style>
