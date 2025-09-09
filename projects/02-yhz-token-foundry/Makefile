run-blockchain:
	anvil

deploy:
	forge script script/Deploy.s.sol:DeployYHZToken --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

test:
	forge test -vv

test-gas:
	forge test --gas-report

build:
	forge build

clean:
	forge clean

format:
	forge fmt

lint:
	forge lint

coverage:
	forge coverage

snapshot:
	forge snapshot

# Token Testing Commands
check-balance:
	cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url http://localhost:8545

transfer-tokens:
	cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "transfer(address,uint256)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 1000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url http://localhost:8545

token-info:
	@echo "=== YHZ Token Information ==="
	@echo "Name:"
	@cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "name()" --rpc-url http://localhost:8545 | cast --to-ascii
	@echo "Symbol:"  
	@cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "symbol()" --rpc-url http://localhost:8545 | cast --to-ascii
	@echo "Total Supply:"
	@cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "totalSupply()" --rpc-url http://localhost:8545 | cast --to-dec
	@echo "Your Balance:"
	@cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url http://localhost:8545 | cast --to-dec

.PHONY: run-blockchain deploy test test-gas build clean format lint coverage snapshot check-balance transfer-tokens token-info
