
run-blockchain:
	anvil

run-forge:
	forge script script/Deploy.s.sol:DeployHelloBlockchain --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

test:
	forge test

build:
	forge build

clean:
	forge clean

format:
	forge fmt

lint:
	forge lint

frontend:
	cd frontend && npm run dev

.PHONY: run-blockchain run-forge test build clean format lint frontend