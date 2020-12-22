ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SETUP_IMAGE=$(shell docker images -q wintex/doton-setup)

KEYS_PATH=/keys
CONTRACTS_PATH=/contracts
SCRIPTS_PATH=/scripts

TON_URL=http://doton-ton-chain

INI_VALUE="1T"
BRIDGE_VOTE_CONTROLLER_PUBLIC_KEY=ebc77aae202a4f12237e10892f4fe0e44f8fb3dfc07008dcc12b37f8f70c1149
PROPOSAL_VOTERS_AMOUNT=2
BLOCK_TIME=2

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
ifeq ($(strip $(SETUP_IMAGE)),)
	$(MAKE) build-setup
endif
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
			BRIDGE_VOTE_CONTROLLER_PUBLIC_KEY=$(BRIDGE_VOTE_CONTROLLER_PUBLIC_KEY) \
			PROPOSAL_VOTERS_AMOUNT=$(PROPOSAL_VOTERS_AMOUNT) \
			BLOCK_TIME=$(PROPOSAL_VOTERS_AMOUNT) \
	) /bin/bash;
