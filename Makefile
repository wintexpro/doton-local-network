ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SETUP_IMAGE=$(shell docker images -q wintex/doton-setup)

.PHONY: run-chains
run-chains:
	docker-compose up

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

.PHONY: run-setup
run-setup:
ifeq ($(strip $(SETUP_IMAGE)),)
	docker build . -t wintex/doton-setup
endif
	docker run -d \
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
		--file /scripts/Makefile init
