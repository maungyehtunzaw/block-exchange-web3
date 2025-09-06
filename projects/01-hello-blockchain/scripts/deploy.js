const hre = require("hardhat");

async function main() {
    console.log("🚀 Deploying HelloBlockchain contract...\n");
    
    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("📝 Deploying with account:", deployer.address);
    
    // Check deployer balance
    const balance = await deployer.getBalance();
    console.log("💰 Account balance:", hre.ethers.utils.formatEther(balance), "ETH\n");
    
    // Deploy the contract
    console.log("⏳ Deploying contract...");
    const HelloBlockchain = await hre.ethers.getContractFactory("HelloBlockchain");
    const helloBlockchain = await HelloBlockchain.deploy("Hello, Blockchain World! 🌍");
    
    await helloBlockchain.deployed();
    
    console.log("✅ HelloBlockchain deployed to:", helloBlockchain.address);
    console.log("📋 Transaction hash:", helloBlockchain.deployTransaction.hash);
    console.log("⛽ Gas used:", helloBlockchain.deployTransaction.gasLimit.toString());
    
    // Wait for a few block confirmations
    console.log("\n⏳ Waiting for block confirmations...");
    await helloBlockchain.deployTransaction.wait(1);
    
    // Verify the deployment by calling contract functions
    console.log("\n🔍 Verifying deployment...");
    const message = await helloBlockchain.getMessage();
    const owner = await helloBlockchain.owner();
    const updateCount = await helloBlockchain.updateCount();
    
    console.log("📄 Initial message:", message);
    console.log("👤 Contract owner:", owner);
    console.log("🔢 Update count:", updateCount.toString());
    
    // Save deployment information
    const deploymentInfo = {
        contractAddress: helloBlockchain.address,
        deployerAddress: deployer.address,
        network: hre.network.name,
        transactionHash: helloBlockchain.deployTransaction.hash,
        blockNumber: helloBlockchain.deployTransaction.blockNumber,
        gasUsed: helloBlockchain.deployTransaction.gasLimit.toString(),
        deploymentTime: new Date().toISOString()
    };
    
    console.log("\n📊 Deployment Summary:");
    console.table(deploymentInfo);
    
    // Instructions for next steps
    console.log("\n🎉 Deployment successful!");
    console.log("\n📚 Next steps:");
    console.log("1. Run tests: npx hardhat test");
    console.log("2. Verify on explorer (for testnets)");
    console.log("3. Interact with the contract using the frontend");
    console.log("4. Try updating the message (only owner can do this)");
    
    if (hre.network.name === "localhost") {
        console.log("\n💡 Local deployment notes:");
        console.log("- Contract is deployed on local Hardhat network");
        console.log("- Make sure Hardhat node is running: npx hardhat node");
        console.log("- Use this address in your frontend:", helloBlockchain.address);
    }
    
    return helloBlockchain.address;
}

// Execute deployment
main()
    .then((address) => {
        console.log(`\n✨ Contract deployed at: ${address}`);
        process.exit(0);
    })
    .catch((error) => {
        console.error("❌ Deployment failed:");
        console.error(error);
        process.exit(1);
    });
