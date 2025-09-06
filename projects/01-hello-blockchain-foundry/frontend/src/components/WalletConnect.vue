<template>
  <div class="wallet-connect">
    <div v-if="!walletState.isConnected" class="disconnected">
      <button 
        @click="connect" 
        :disabled="walletState.isConnecting"
        class="connect-btn"
      >
        {{ walletState.isConnecting ? 'Connecting...' : 'Connect Wallet' }}
      </button>
    </div>

    <div v-else class="connected">
      <div class="wallet-info">
        <div class="address">{{ shortAddress }}</div>
        <div class="balance">{{ parseFloat(walletState.balance).toFixed(4) }} ETH</div>
        <div class="network" :class="{ 'local': isLocalNetwork }">
          {{ getNetworkName(walletState.chainId) }}
        </div>
      </div>
      
      <button @click="disconnect" class="disconnect-btn">
        Disconnect
      </button>
    </div>

    <div v-if="walletState.error" class="error">
      {{ walletState.error }}
      <button @click="clearError" class="error-close">×</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useWeb3 } from '@/composables/useWeb3Simple'

const { 
  walletState, 
  shortAddress, 
  isLocalNetwork, 
  connect, 
  disconnect 
} = useWeb3()

const getNetworkName = (chainId: number): string => {
  const networks: Record<number, string> = {
    1: 'Ethereum',
    5: 'Goerli',
    11155111: 'Sepolia',
    137: 'Polygon',
    80001: 'Mumbai',
    31337: 'Localhost',
    1337: 'Localhost'
  }
  return networks[chainId] || `Chain ${chainId}`
}

const clearError = () => {
  walletState.error = ''
}
</script>

<style scoped>
.wallet-connect {
  position: relative;
}

.connect-btn {
  background: linear-gradient(45deg, #667eea, #764ba2);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 0.75rem;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 14px rgba(102, 126, 234, 0.3);
}

.connect-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.connect-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

.connected {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: rgba(255, 255, 255, 0.9);
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  border: 1px solid rgba(102, 126, 234, 0.2);
}

.wallet-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.address {
  font-weight: 600;
  font-size: 0.875rem;
  color: #1e293b;
}

.balance {
  font-size: 0.75rem;
  color: #64748b;
}

.network {
  font-size: 0.75rem;
  color: #64748b;
  padding: 0.125rem 0.5rem;
  background: rgba(102, 126, 234, 0.1);
  border-radius: 0.25rem;
  text-align: center;
}

.network.local {
  background: rgba(34, 197, 94, 0.1);
  color: #16a34a;
}

.disconnect-btn {
  background: #ef4444;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  font-size: 0.75rem;
  cursor: pointer;
  transition: all 0.2s;
}

.disconnect-btn:hover {
  background: #dc2626;
  transform: translateY(-1px);
}

.error {
  position: absolute;
  top: 100%;
  right: 0;
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #dc2626;
  padding: 0.75rem;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  max-width: 300px;
  margin-top: 0.5rem;
  box-shadow: 0 4px 14px rgba(239, 68, 68, 0.1);
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  z-index: 10;
}

.error-close {
  background: none;
  border: none;
  color: #dc2626;
  cursor: pointer;
  font-size: 1.25rem;
  line-height: 1;
  padding: 0;
  margin-left: auto;
}

@media (max-width: 768px) {
  .connected {
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem;
  }
  
  .error {
    position: fixed;
    top: 1rem;
    right: 1rem;
    left: 1rem;
    max-width: none;
  }
}
</style>
