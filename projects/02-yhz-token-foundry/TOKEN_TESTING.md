# 🪙 YHZ Token Testing Guide

## Token Details
- **Name:** YHZ Token
- **Symbol:** YHZ
- **Contract:** `0x5FbDB2315678afecb367f032d93F642f64180aa3`
- **Decimals:** 18
- **Total Supply:** 1,000,000 YHZ
- **Value:** 1 YHZ = 1000 USDT
- **Icon:** `assets/yhz-token-icon.svg`

## 🧪 How to Test Your YHZ Token

### 1. **Add YHZ Token to MetaMask**

**Step 1:** Open MetaMask and make sure you're connected to localhost:8545

**Step 2:** Add Local Network (if not already added):
- Network Name: `Localhost 8545`
- RPC URL: `http://localhost:8545`
- Chain ID: `31337`
- Currency Symbol: `ETH`

**Step 3:** Import the test account:
- Private Key: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

**Step 4:** Add YHZ Token:
- Go to "Import tokens"
- Contract Address: `0x5FbDB2315678afecb367f032d93F642f64180aa3`
- Token Symbol: `YHZ`
- Decimals: `18`

### 2. **Test Token Functions via Command Line**

```bash
# 1. Check your YHZ balance
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
  --rpc-url http://localhost:8545

# 2. Check token name
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  "name()" --rpc-url http://localhost:8545

# 3. Check token symbol
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  "symbol()" --rpc-url http://localhost:8545

# 4. Transfer 1 YHZ to another address
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  "transfer(address,uint256)" \
  0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
  1000000000000000000 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://localhost:8545

# 5. Check balance of the recipient
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  "balanceOf(address)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
  --rpc-url http://localhost:8545
```

### 3. **Test Token Functions via Makefile**

```bash
# Check your YHZ balance
make check-balance

# Transfer tokens
make transfer-tokens

# Check all token info
make token-info
```

### 4. **Expected Results**

- **Your Balance:** Should show 1,000,000 YHZ (as you're the owner)
- **Name:** Should return "YHZ Token" 
- **Symbol:** Should return "YHZ"
- **Transfer:** Should successfully move tokens between accounts
- **MetaMask:** Should display YHZ tokens with the custom icon

### 5. **Token Economics Test**

Since 1 YHZ = 1000 USDT:
- Transferring 1 YHZ = Moving $1000 worth of value
- Your 1M YHZ = $1 Billion total value! 💰

### 6. **Advanced Testing**

```bash
# Approve spending allowance
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  "approve(address,uint256)" \
  0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
  500000000000000000000 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --rpc-url http://localhost:8545

# Check allowance
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  "allowance(address,address)" \
  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
  0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
  --rpc-url http://localhost:8545
```

## 🎯 What You're Learning

- ✅ **ERC-20 Standards:** How tokens work on Ethereum
- ✅ **Token Economics:** Understanding value and supply
- ✅ **Gas Fees:** Every transaction costs gas
- ✅ **Wallet Integration:** How MetaMask displays tokens
- ✅ **Transfer Functions:** Moving value between addresses
- ✅ **Allowances:** How DEXs and DeFi protocols work

🎉 **Congratulations!** You now own a premium cryptocurrency worth $1 Billion! 🚀
