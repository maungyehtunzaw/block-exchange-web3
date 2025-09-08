// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {YHZToken} from "../src/YHZToken.sol";

contract DeployYHZToken is Script {
    function run() external returns (YHZToken) {
        // Get the deployer from environment or use default
        address deployer = vm.envOr("DEPLOYER_ADDRESS", msg.sender);
        
        console.log("Deploying YHZ Token...");
        console.log("Deployer:", deployer);
        
        vm.startBroadcast();
        
        YHZToken token = new YHZToken(deployer);
        
        vm.stopBroadcast();
        
        console.log("YHZ Token deployed at:", address(token));
        console.log("Token Details:");
        console.log("- Name:", token.name());
        console.log("- Symbol:", token.symbol());
        console.log("- Decimals:", token.decimals());
        console.log("- Initial Supply:", token.totalSupply() / 10**18, "YHZ");
        console.log("- Max Supply:", token.MAX_SUPPLY() / 10**18, "YHZ");
        console.log("- Value per Token:", token.USDT_VALUE_PER_TOKEN(), "USDT");
        console.log("- Owner:", token.owner());
        console.log("- Total USD Value:", token.getUSDValue(token.totalSupply()), "USDT");
        
        return token;
    }
}
