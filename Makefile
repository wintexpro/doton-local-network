ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SETUP_CONTAINER=$(shell docker ps -q -f name=doton-setup)
BRIDGE_IMAGE=wintex/doton-bridge:latest

CONFIGS_PATH=/configs
KEYS_PATH=/keys
CONTRACTS_PATH=/contracts
SCRIPTS_PATH=/scripts

TON_URL=http://doton-ton-chain

INI_VALUE="5T"
PROPOSAL_VOTERS_AMOUNT=1
BLOCK_TIME=7

GIVER_ADDRESS=0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94
PUBLIC_KEY=0xebc77aae202a4f12237e10892f4fe0e44f8fb3dfc07008dcc12b37f8f70c1149
KEY=0:e8bc02f9e8e56c04d9248743cfed5b8c3a0d6b5171f7fcf083a0dd206f847891
KEYSTORE_PASSWORD=123456

define ENV
	KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD)
	CONFIGS_PATH=$(CONFIGS_PATH)
	KEYS_PATH=$(KEYS_PATH)
	CONTRACTS_PATH=$(CONTRACTS_PATH)
	SCRIPTS_PATH=$(SCRIPTS_PATH)
	TON_URL=$(TON_URL)
	INI_VALUE=$(INI_VALUE)
	PROPOSAL_VOTERS_AMOUNT=$(PROPOSAL_VOTERS_AMOUNT)
	BLOCK_TIME=$(BLOCK_TIME)
	GIVER_ADDRESS=$(GIVER_ADDRESS)
	PUBLIC_KEY=$(PUBLIC_KEY)
	KEY=$(KEY)
endef

.PHONY: kill-all
kill-all:
	$(MAKE) kill-chains && \
	$(MAKE) kill-bridge && \
	$(MAKE) kill-setup

.PHONY: run-chains
run-chains:
	docker-compose up -d

.PHONY: kill-chains
kill-chains:
	docker container stop doton-ton-chain && \
	docker container rm doton-ton-chain && \
	docker container stop doton-sub-chain && \
	docker container rm doton-sub-chain

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
		-e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) \
		$(BRIDGE_IMAGE) \
		--config /configs/config.json

.PHONY: kill-bridge
kill-bridge:
	docker container stop doton-bridge && \
	docker container rm doton-bridge

.PHONY: build-setup
build-setup:
	docker build . -t wintex/doton-setup

.PHONY: run-setup
run-setup:
	docker exec -it $(shell docker run -d \
		--rm \
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
		--file /scripts/Makefile sub-setup $(ENV) \
	) /bin/bash;

.PHONY: run-setup-bridge
run-setup-bridge:
	docker exec -it $(shell docker run -d \
		--rm \
		--name doton-setup-bridge \
		--network doton-local-network_default \
		--link doton-sub-chain \
		--link doton-ton-chain \
		-v $(ROOT_DIR)/contracts:/contracts\
		-v $(ROOT_DIR)/scripts:/scripts\
		-v $(ROOT_DIR)/configs:/configs\
		-v $(ROOT_DIR)/keys:/keys \
		-e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) \
		--entrypoint /bin/bash \
		$(BRIDGE_IMAGE) \
		-c "\
		./bridge --config /configs/config.json contracts send-grams; \
		sleep 3; \
		./bridge --config /configs/config.json contracts deploy; \
		sleep 3; \
		./bridge --config /configs/config.json contracts setup; \
		sleep 3; \
		./bridge --config /configs/config.json contracts deploy-wallet; \
		" \
	) /bin/bash;

.PHONY: kill-setup
kill-setup:
	docker container stop doton-setup-bridge && \
	docker container rm doton-setup-bridge

.PHONY: get-balance
get-balance:
	docker run --rm \
		--network doton-local-network_default \
		--link doton-sub-chain \
		--link doton-ton-chain \
		-v $(ROOT_DIR)/contracts:/contracts\
		-v $(ROOT_DIR)/scripts:/scripts\
		-v $(ROOT_DIR)/configs:/configs\
		-v $(ROOT_DIR)/keys:/keys \
		-e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) \
		--entrypoint /bin/bash \
		$(BRIDGE_IMAGE) \
		-c "\
		./bridge --config /configs/config.json contracts get-balance; \
		"\