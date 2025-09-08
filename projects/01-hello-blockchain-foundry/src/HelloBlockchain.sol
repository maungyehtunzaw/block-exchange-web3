// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title HelloBlockchain
 * @dev A simple smart contract to demonstrate blockchain basics with Foundry
 */
contract HelloBlockchain {
    string public message;
    address public owner;
    uint256 public updateCount;

    event MessageUpdated(string newMessage, address indexed updatedBy, uint256 indexed timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(string memory _initialMessage) {
        message = _initialMessage;
        owner = msg.sender;
        updateCount = 0;

        emit MessageUpdated(_initialMessage, msg.sender, block.timestamp);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "HelloBlockchain: Only owner can call this function");
        _;
    }

    function updateMessage(string memory _newMessage) public onlyOwner {
        require(bytes(_newMessage).length > 0, "HelloBlockchain: Message cannot be empty");
        require(bytes(_newMessage).length <= 280, "HelloBlockchain: Message too long (max 280 chars)");

        message = _newMessage;
        updateCount++;

        emit MessageUpdated(_newMessage, msg.sender, block.timestamp);
    }

    function getMessage() public view returns (string memory) {
        return message;
    }

    function getContractInfo()
        public
        view
        returns (string memory currentMessage, address contractOwner, uint256 totalUpdates, uint256 contractBalance)
    {
        return (message, owner, updateCount, address(this).balance);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "HelloBlockchain: New owner cannot be zero address");
        require(newOwner != owner, "HelloBlockchain: New owner must be different from current owner");

        address previousOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(previousOwner, newOwner);
    }

    receive() external payable {}

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "HelloBlockchain: No ETH to withdraw");

        (bool success,) = payable(owner).call{value: balance}("");
        require(success, "HelloBlockchain: Withdrawal failed");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
