// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {HelloBlockchain} from "../src/HelloBlockchain.sol";

contract DeployHelloBlockchain is Script {
    HelloBlockchain public helloBlockchain;

    function setUp() public {}

    function run() public {
        console.log("Deploying HelloBlockchain contract...");
        console.log("Deploying with account:", msg.sender);

        vm.startBroadcast();

        helloBlockchain = new HelloBlockchain("Hello, Blockchain World from Foundry!");

        vm.stopBroadcast();

        console.log("HelloBlockchain deployed to:", address(helloBlockchain));

        // Verify the deployment
        console.log("Verifying deployment...");
        console.log("Initial message:", helloBlockchain.getMessage());
        console.log("Contract owner:", helloBlockchain.owner());
        console.log("Update count:", helloBlockchain.updateCount());

        console.log("Deployment successful!");
    }
}
