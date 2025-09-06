# Blockchain Basics

## What is a Blockchain?

A blockchain is a **distributed ledger** that maintains a continuously growing list of records (blocks) that are linked and secured using cryptography.

### Key Concepts

#### 1. **Blocks**
- Container for transactions
- Contains previous block's hash (creates the "chain")
- Has a timestamp and merkle root

#### 2. **Decentralization**
- No single point of control
- Network of nodes validate transactions
- Consensus mechanisms ensure agreement

#### 3. **Immutability**
- Once data is recorded, it's extremely difficult to change
- Cryptographic hashing ensures data integrity

#### 4. **Transparency**
- All transactions are visible on the network
- Public ledger anyone can verify

## How Blockchain Works

```
[Block 1] → [Block 2] → [Block 3] → [Block 4] → ...
    ↓           ↓           ↓           ↓
  Hash        Hash        Hash        Hash
```

1. **Transaction initiated** - User wants to send cryptocurrency
2. **Transaction broadcast** - Sent to the network
3. **Validation** - Network nodes verify the transaction
4. **Block creation** - Valid transactions grouped into a block
5. **Mining/Consensus** - Miners compete to solve cryptographic puzzle
6. **Block added** - Winning miner adds block to chain
7. **Distribution** - New block distributed across network

## Key Technologies

- **Cryptographic Hashing** (SHA-256)
- **Digital Signatures** (Public/Private Keys)
- **Merkle Trees** (Efficient data verification)
- **Consensus Algorithms** (Proof of Work, Proof of Stake)

## Why Blockchain Matters

- **Trust without intermediaries**
- **Global accessibility**
- **Programmable money** (Smart Contracts)
- **Financial inclusion**
- **Transparent governance**

---

**Next:** [Smart Contracts](./02-smart-contracts.md)
