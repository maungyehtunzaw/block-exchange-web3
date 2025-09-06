# Smart Contracts

## What are Smart Contracts?

Smart contracts are **self-executing contracts** with terms directly written into code. They automatically execute when predetermined conditions are met, without intermediaries.

## Key Features

- **Autonomous** - Execute automatically
- **Trustless** - No need to trust other parties
- **Immutable** - Cannot be changed once deployed
- **Transparent** - Code is visible on blockchain
- **Decentralized** - Run on blockchain network

## Solidity Basics

Solidity is the most popular language for writing smart contracts on Ethereum.

### Basic Contract Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    // State variables
    string public message;
    address public owner;
    
    // Constructor - runs once when deployed
    constructor(string memory _message) {
        message = _message;
        owner = msg.sender;
    }
    
    // Function to update message
    function updateMessage(string memory _newMessage) public {
        require(msg.sender == owner, "Only owner can update");
        message = _newMessage;
    }
}
```

### Key Solidity Concepts

#### **Variables & Types**
```solidity
uint256 public count;        // Unsigned integer
string public name;          // String
bool public isActive;        // Boolean
address public owner;        // Ethereum address
mapping(address => uint256) public balances; // Key-value storage
```

#### **Functions**
```solidity
function myFunction(uint256 _param) public view returns (uint256) {
    return _param * 2;
}

// Function modifiers
// public - anyone can call
// private - only this contract
// internal - this contract and derived contracts
// external - only external calls

// State modifiers
// view - reads state but doesn't modify
// pure - doesn't read or modify state
// payable - can receive Ether
```

#### **Events**
```solidity
event MessageUpdated(string newMessage, address updatedBy);

function updateMessage(string memory _newMessage) public {
    message = _newMessage;
    emit MessageUpdated(_newMessage, msg.sender);
}
```

#### **Modifiers**
```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _;
}

function sensitiveFunction() public onlyOwner {
    // Only owner can execute this
}
```

## Common Patterns

### **Access Control**
```solidity
address public owner;

modifier onlyOwner() {
    require(msg.sender == owner, "Not authorized");
    _;
}
```

### **State Machine**
```solidity
enum State { Created, Locked, Inactive }
State public state;

modifier inState(State _state) {
    require(state == _state, "Invalid state");
    _;
}
```

### **Withdrawal Pattern**
```solidity
mapping(address => uint256) public pendingReturns;

function withdraw() public {
    uint256 amount = pendingReturns[msg.sender];
    require(amount > 0, "No funds to withdraw");
    
    pendingReturns[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
}
```

## Gas & Optimization

- **Gas** is the fee for executing operations
- Complex operations cost more gas
- Optimize for gas efficiency:
  - Use `uint256` instead of smaller uints
  - Pack structs efficiently
  - Use events for data that doesn't need to be accessed by contract

## Security Best Practices

1. **Check-Effects-Interactions** pattern
2. **Use modifiers** for access control
3. **Validate inputs** with `require()`
4. **Be careful with external calls**
5. **Test extensively** before mainnet deployment

---

**Next:** [Development Environment Setup](./03-development-setup.md)
