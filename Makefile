ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SETUP_IMAGE=$(shell docker images -q wintex/doton-setup)

KEYS_PATH=/keys
CONTRACTS_PATH=/contracts
SCRIPTS_PATH=/scripts

TON_URL=http://doton-ton-chain

INI_VALUE="5T"
PROPOSAL_VOTERS_AMOUNT=1
BLOCK_TIME=2

GIVER_ADDRESS=0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94
PUBLIC_KEY=0xebc77aae202a4f12237e10892f4fe0e44f8fb3dfc07008dcc12b37f8f70c1149
KEY=0:df22eba0b48020b70efa7a6e9d6360ed1dc20877250947470cc1289b14c9cc1e

.PHONY: run-chains
run-chains:
	docker-compose up -d

.PHONY: run-bridge
run-bridge:
	docker run -d \
		--name doton-bridge \
		--network doton-local-network_default \
		--link doton-sub-chain \
		--link doton-ton-chain \
		-v $(ROOT_DIR)/scripts:/scripts \
		-v $(ROOT_DIR)/contracts:/contracts \
		-v $(ROOT_DIR)/configs:/configs \
		-v $(ROOT_DIR)/keys:/keys \
		-e KEYSTORE_PASSWORD=123456 \
		wintex/doton-bridge \
		--config /configs/config.json

.PHONY: build-setup
build-setup:
	docker build . -t wintex/doton-setup

.PHONY: run-setup
run-setup:
	docker exec -it $(shell docker run -d \
		--name doton-setup \
		--network doton-local-network_default \
		--entrypoint make \
		--link doton-sub-chain \
		--link doton-ton-chain \
		-v $(ROOT_DIR)/scripts:/scripts \
		-v $(ROOT_DIR)/contracts:/contracts \
		-v $(ROOT_DIR)/configs:/configs \
		-v $(ROOT_DIR)/keys:/keys \
		wintex/doton-setup \
		--file /scripts/Makefile init \
			KEYS_PATH=$(KEYS_PATH) \
			CONTRACTS_PATH=$(CONTRACTS_PATH) \
			SCRIPTS_PATH=$(SCRIPTS_PATH) \
			TON_URL=$(TON_URL) \
			INI_VALUE=$(INI_VALUE) \
			PROPOSAL_VOTERS_AMOUNT=$(PROPOSAL_VOTERS_AMOUNT) \
			BLOCK_TIME=$(PROPOSAL_VOTERS_AMOUNT) \
			GIVER_ADDRESS=$(GIVER_ADDRESS) \
			PUBLIC_KEY=$(PUBLIC_KEY) \
			KEY=$(KEY) \
	) /bin/bash;
