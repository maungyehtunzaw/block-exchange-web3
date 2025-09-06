// Global type declarations for MetaMask
interface EthereumProvider {
  request: (args: { method: string; params?: unknown[] }) => Promise<unknown>
  on: (event: string, callback: (data: unknown) => void) => void
  removeListener: (event: string, callback: (data: unknown) => void) => void
  isMetaMask?: boolean
}

declare global {
  interface Window {
    ethereum?: EthereumProvider
  }
}

export {}
