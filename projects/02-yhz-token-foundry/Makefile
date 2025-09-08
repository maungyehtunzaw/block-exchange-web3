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

.PHONY: run-blockchain deploy test test-gas build clean format lint coverage snapshot
