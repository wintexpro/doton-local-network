ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SETUP_CONTAINER=$(shell docker ps -q -f name=doton-setup)
BRIDGE_CONTAINER=$(shell docker ps -q -f name=doton-relayer-alice)
BRIDGE_IMAGE=wintex/doton-bridge

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
	$(MAKE) kill-relayers && \
	$(MAKE) kill-setup

.PHONY: kill-relayers
kill-relayers:
	$(MAKE) kill-alice && \
	$(MAKE) kill-bob && \
	$(MAKE) kill-charlie

.PHONY: run-chains
run-chains:
	docker-compose up -d

.PHONY: kill-chains
kill-chains:
	docker container stop doton-ton-chain && \
	docker container rm doton-ton-chain && \
	docker container stop doton-sub-chain && \
	docker container rm doton-sub-chain

.PHONY: run-relayers
run-relayers:
	$(MAKE) run-alice && \
	$(MAKE) run-bob && \
	$(MAKE) run-charlie

.PHONY: run-alice
run-alice:
	docker run -d \
		--name doton-relayer-alice \
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

.PHONY: run-bob
run-bob:
	docker run -d \
		--name doton-relayer-bob \
		--network doton-local-network_default \
		--link doton-sub-chain \
		--link doton-ton-chain \
		-v $(ROOT_DIR)/scripts:/scripts \
		-v $(ROOT_DIR)/contracts:/contracts \
		-v $(ROOT_DIR)/configs:/configs \
		-v $(ROOT_DIR)/keys:/keys \
		-e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) \
		$(BRIDGE_IMAGE) \
		--config /configs/config2.json

.PHONY: run-charlie
run-charlie:
	docker run -d \
		--name doton-relayer-charlie \
		--network doton-local-network_default \
		--link doton-sub-chain \
		--link doton-ton-chain \
		-v $(ROOT_DIR)/scripts:/scripts \
		-v $(ROOT_DIR)/contracts:/contracts \
		-v $(ROOT_DIR)/configs:/configs \
		-v $(ROOT_DIR)/keys:/keys \
		-e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) \
		$(BRIDGE_IMAGE) \
		--config /configs/config3.json

.PHONY: kill-alice
kill-alice:
	docker container stop doton-relayer-alice && \
	docker container rm doton-relayer-alice

.PHONY: kill-bob
kill-bob:
	docker container stop doton-relayer-bob && \
	docker container rm doton-relayer-bob

.PHONY: kill-charlie
kill-charlie:
	docker container stop doton-relayer-charlie && \
	docker container rm doton-relayer-charlie

.PHONY: build-setup
build-setup:
	docker build . -t wintex/doton-setup

.PHONY: run-setup
run-setup:
	$(MAKE) run-setup-substrate && \
	$(MAKE) run-setup-ton

.PHONY: sub-send-msg
sub-send-msg:
	docker exec --env MSG="0x$(shell echo $(MSG) | xxd -p)" -it $(SETUP_CONTAINER) halva-cli exec -p $(CONFIGS_PATH)/halva.js -f $(SCRIPTS_PATH)/helpers.js

.PHONY: deploy-relayer
deploy-relayer:
	docker exec \
		-e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) \
		-it $(BRIDGE_CONTAINER) /bridge \
		--config $(CONFIGS_PATH)/$(CONFIG_NAME) \
		contracts deploy-relayer \
		--accessControllerAddress 0:86429102eff726f48ae807b229e29f5d56565c6e793c471dcf4c148e50b12d05 \
		--bridgeAddress 0:1ec11b150a684e23562a6d0f74adbd3e35f942573e82f99265a1a56699c89ed4 \

.PHONY: run-setup-substrate
run-setup-substrate:
	docker run --rm -d \
		--name doton-setup \
		--network doton-local-network_default \
		--entrypoint make \
		--link doton-sub-chain \
		--link doton-ton-chain \
		--entrypoint halva-cli \
		-e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) \
		-e CONFIGS_PATH=$(CONFIGS_PATH) \
		-e KEYS_PATH=$(KEYS_PATH) \
		-e CONTRACTS_PATH=$(CONTRACTS_PATH) \
		-e SCRIPTS_PATH=$(SCRIPTS_PATH) \
		-v $(ROOT_DIR)/scripts:/scripts \
		-v $(ROOT_DIR)/contracts:/contracts \
		-v $(ROOT_DIR)/configs:/configs \
		-v $(ROOT_DIR)/keys:/keys \
		wintex/doton-setup \
		exec -f $(SCRIPTS_PATH)/setup.js -p $(CONFIGS_PATH)/halva.js \

.PHONY: run-setup-ton
run-setup-ton:
	docker run --rm -d \
		--name doton-setup-bridge \
		--network doton-local-network_default \
		--link doton-sub-chain \
		--link doton-ton-chain \
		-v $(ROOT_DIR)/contracts:/contracts\
		-v $(ROOT_DIR)/scripts:/scripts\
		-v $(ROOT_DIR)/configs:/configs\
		-v $(ROOT_DIR)/keys:/keys \
		-e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) \
		-e CONFIGS_PATH=$(CONFIGS_PATH) \
		-e KEYS_PATH=$(KEYS_PATH) \
		-e CONTRACTS_PATH=$(CONTRACTS_PATH) \
		-e SCRIPTS_PATH=$(SCRIPTS_PATH) \
		--entrypoint /bin/bash \
		$(BRIDGE_IMAGE) \
		-c "\
		./bridge --config /configs/config.json contracts send-grams; \
		sleep 10; \
		./bridge --config /configs/config.json contracts deploy; \
		sleep 10; \
		./bridge --config /configs/config.json contracts setup; \
		sleep 10; \
		./bridge --config /configs/config.json contracts deploy-wallet; \
		" \

EXEC_ON_BRIDGE=docker exec -e KEYSTORE_PASSWORD=$(KEYSTORE_PASSWORD) -it $(BRIDGE_CONTAINER) /bridge --config $(CONFIGS_PATH)/config.json

.PHONY: kill-setup
kill-setup:
	docker container stop doton-setup-bridge && \
	docker container rm doton-setup-bridge

.PHONY: get-balance
get-balance:
	$(EXEC_ON_BRIDGE) contracts get-balance

.PHONY: ton-send-tokens
ton-send-tokens:
	$(EXEC_ON_BRIDGE) contracts send-tokens --amount $(AMOUNT) --to $(TO) --nonce $(NONCE)
