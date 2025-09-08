// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title YHZ Token
 * @dev ERC-20 token with premium value (1 YHZ = 1000 USDT equivalent)
 * @author YHZ Team
 */
contract YHZToken is ERC20, ERC20Burnable, Ownable {
    
    // Token Details
    uint8 private constant _DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10**_DECIMALS; // 1 Million YHZ
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**_DECIMALS;    // 10 Million YHZ max
    
    // Value Reference (for display purposes)
    uint256 public constant USDT_VALUE_PER_TOKEN = 1000; // 1 YHZ = 1000 USDT
    
    // Minting Control
    mapping(address => bool) public minters;
    
    // Events
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event TokensMinted(address indexed to, uint256 amount, string reason);
    event ValueUpdated(uint256 newValue);

    /**
     * @dev Constructor that gives msg.sender all of the initial tokens
     */
    constructor(address initialOwner) ERC20("YHZ Token", "YHZ") Ownable(initialOwner) {
        _mint(initialOwner, INITIAL_SUPPLY);
        minters[initialOwner] = true;
        emit MinterAdded(initialOwner);
        emit TokensMinted(initialOwner, INITIAL_SUPPLY, "Initial Supply");
    }

    /**
     * @dev Returns the number of decimals used by the token
     */
    function decimals() public pure override returns (uint8) {
        return _DECIMALS;
    }

    /**
     * @dev Add a new minter
     */
    function addMinter(address minter) external onlyOwner {
        require(minter != address(0), "YHZ: Cannot add zero address as minter");
        require(!minters[minter], "YHZ: Address is already a minter");
        
        minters[minter] = true;
        emit MinterAdded(minter);
    }

    /**
     * @dev Remove a minter
     */
    function removeMinter(address minter) external onlyOwner {
        require(minters[minter], "YHZ: Address is not a minter");
        
        minters[minter] = false;
        emit MinterRemoved(minter);
    }

    /**
     * @dev Mint new tokens (only by minters, respecting max supply)
     */
    function mint(address to, uint256 amount, string calldata reason) external {
        require(minters[msg.sender], "YHZ: Only minters can mint tokens");
        require(to != address(0), "YHZ: Cannot mint to zero address");
        require(amount > 0, "YHZ: Amount must be greater than zero");
        require(totalSupply() + amount <= MAX_SUPPLY, "YHZ: Minting would exceed max supply");

        _mint(to, amount);
        emit TokensMinted(to, amount, reason);
    }

    /**
     * @dev Mint tokens for multiple addresses at once (batch minting)
     */
    function batchMint(
        address[] calldata recipients,
        uint256[] calldata amounts,
        string calldata reason
    ) external {
        require(minters[msg.sender], "YHZ: Only minters can mint tokens");
        require(recipients.length == amounts.length, "YHZ: Arrays length mismatch");
        require(recipients.length > 0, "YHZ: Empty arrays");

        uint256 totalAmount = 0;
        
        // Calculate total amount first
        for (uint256 i = 0; i < amounts.length; i++) {
            require(recipients[i] != address(0), "YHZ: Cannot mint to zero address");
            require(amounts[i] > 0, "YHZ: Amount must be greater than zero");
            totalAmount += amounts[i];
        }
        
        require(totalSupply() + totalAmount <= MAX_SUPPLY, "YHZ: Batch minting would exceed max supply");

        // Mint to all recipients
        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amounts[i]);
            emit TokensMinted(recipients[i], amounts[i], reason);
        }
    }

    /**
     * @dev Get the theoretical USD value of a token amount
     * @param amount Amount of YHZ tokens
     * @return USD value (assuming 1 YHZ = 1000 USDT)
     */
    function getUSDValue(uint256 amount) external pure returns (uint256) {
        return (amount * USDT_VALUE_PER_TOKEN) / 10**_DECIMALS;
    }

    /**
     * @dev Get token amount for a given USD value
     * @param usdValue USD value
     * @return Token amount in YHZ
     */
    function getTokenAmount(uint256 usdValue) external pure returns (uint256) {
        return (usdValue * 10**_DECIMALS) / USDT_VALUE_PER_TOKEN;
    }

    /**
     * @dev Check if an address is a minter
     */
    function isMinter(address account) external view returns (bool) {
        return minters[account];
    }

    /**
     * @dev Get remaining supply that can be minted
     */
    function remainingSupply() external view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }

    /**
     * @dev Emergency function to pause transfers (inherited from OpenZeppelin if needed)
     * For now, we keep it simple without pause functionality
     */
    
    /**
     * @dev Override transfer to add custom logic if needed
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        require(to != address(0), "YHZ: Cannot transfer to zero address");
        require(amount > 0, "YHZ: Transfer amount must be greater than zero");
        
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev Override transferFrom to add custom logic if needed
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        require(to != address(0), "YHZ: Cannot transfer to zero address");
        require(amount > 0, "YHZ: Transfer amount must be greater than zero");
        
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
}
