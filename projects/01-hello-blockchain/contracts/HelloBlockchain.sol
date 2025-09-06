// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title HelloBlockchain
 * @dev A simple smart contract to demonstrate blockchain basics
 * @author Your Name
 */
contract HelloBlockchain {
    // State variables stored permanently on the blockchain
    string public message;
    address public owner;
    uint256 public updateCount;
    
    // Events - logs that can be listened to by frontend applications
    event MessageUpdated(
        string newMessage, 
        address indexed updatedBy, 
        uint256 indexed timestamp
    );
    
    event OwnershipTransferred(
        address indexed previousOwner, 
        address indexed newOwner
    );
    
    /**
     * @dev Constructor runs once when contract is deployed
     * @param _initialMessage The first message to store
     */
    constructor(string memory _initialMessage) {
        message = _initialMessage;
        owner = msg.sender; // msg.sender is the address that deployed the contract
        updateCount = 0;
        
        emit MessageUpdated(_initialMessage, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Modifier to check if caller is the contract owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "HelloBlockchain: Only owner can call this function");
        _;
    }
    
    /**
     * @dev Update the stored message (only owner can do this)
     * @param _newMessage The new message to store
     */
    function updateMessage(string memory _newMessage) public onlyOwner {
        require(bytes(_newMessage).length > 0, "HelloBlockchain: Message cannot be empty");
        require(bytes(_newMessage).length <= 280, "HelloBlockchain: Message too long (max 280 chars)");
        
        message = _newMessage;
        updateCount++;
        
        emit MessageUpdated(_newMessage, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Get the current message (anyone can call this - it's a view function)
     * @return The current stored message
     */
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    /**
     * @dev Get comprehensive contract information
     * @return currentMessage The stored message
     * @return contractOwner The owner's address
     * @return totalUpdates Total number of updates made
     * @return contractBalance ETH balance of the contract
     */
    function getContractInfo() public view returns (
        string memory currentMessage,
        address contractOwner,
        uint256 totalUpdates,
        uint256 contractBalance
    ) {
        return (
            message, 
            owner, 
            updateCount,
            address(this).balance
        );
    }
    
    /**
     * @dev Transfer ownership to a new address
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "HelloBlockchain: New owner cannot be zero address");
        require(newOwner != owner, "HelloBlockchain: New owner must be different from current owner");
        
        address previousOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }
    
    /**
     * @dev Allow the contract to receive ETH
     */
    receive() external payable {
        // This function is called when ETH is sent to the contract
        // You could emit an event here if needed
    }
    
    /**
     * @dev Withdraw ETH from contract (only owner)
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "HelloBlockchain: No ETH to withdraw");
        
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "HelloBlockchain: Withdrawal failed");
    }
    
    /**
     * @dev Get the contract's ETH balance
     * @return The balance in wei
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
