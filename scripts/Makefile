SHELL := /bin/bash

ADDRESS=0:164d61e6cad0597545cb8ab98ecfdb2a29e0cc55d484daece02c63d8511e9a5f
GIVER_ADDRESS=0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94

KEYS_PATH=
CONTRACTS_PATH=
SCRIPTS_PATH=

BRIDGE_VOTE_CONTROLLER_PUBLIC_KEY=
PROPOSAL_VOTERS_AMOUNT=

TON_URL=

INI_VALUE="1T"

RECEIVER_ADDRESS=

ACCESS_CONTROLLER_ADDRESS=
ACCESS_CONTROLLER_PARAMS=

BRIDGE_VOTE_CONTROLLER_ADDRESS=
BRIDGE_VOTE_CONTROLLER_PARAMS=

BRIDGE_ADDRESS=
BRIDGE_PARAMS=

HANDLER_ADDRESS=
HANDLER_PARAMS=

BLOCK_TIME=4

.PHONY: init
init:
	$(MAKE) -f $(SCRIPTS_PATH)/Makefile ton-init
	$(MAKE) -f $(SCRIPTS_PATH)/Makefile ton-deploy-contracts
	$(MAKE) -f $(SCRIPTS_PATH)/Makefile sub-setup
	$(MAKE) -f $(SCRIPTS_PATH)/Makefile ton-block-producing

.PHONY: ton-init
ton-init:
	tonos-cli config --url $(TON_URL)
	$(call ton_set_addresses)

	$(call ton_send_init_value,$(ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(RECEIVER_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(BRIDGE_VOTE_CONTROLLER_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(ACCESS_CONTROLLER_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(BRIDGE_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(HANDLER_ADDRESS),$(INI_VALUE))

.PHONY: ton-deploy-contracts
ton-deploy-contracts:
	$(call ton_set_addresses)

	$(eval BRIDGE_VOTE_CONTROLLER_PARAMS := '{"_proposalStateInit":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Proposal.tvc)'","_ballotInitState":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Relayer.tvc)'","_deployInitialValue": 2000000000,"_publicKey":"0x'$(BRIDGE_VOTE_CONTROLLER_PUBLIC_KEY)'","_proposalVotersAmount":'$(PROPOSAL_VOTERS_AMOUNT)',"_bridgeAddress":"'$(BRIDGE_ADDRESS)'"}')
	$(eval BRIDGE_PARAMS := '{"_relayerInitState":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Relayer.tvc)'","_accessControllerAddress":"'$(ACCESS_CONTROLLER_ADDRESS)'","_voteControllerAddress": "'$(BRIDGE_VOTE_CONTROLLER_ADDRESS)'"}')
	$(eval ACCESS_CONTROLLER_PARAMS := '{"_accessCardInitState":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Relayer.tvc)'", "_initialValue": 1000000}')
	$(eval HANDLER_PARAMS := '{"_proposalStateInit":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Proposal.tvc)'"}')

	$(call ton_deploy,Sender,{})
	$(call ton_deploy,Receiver,{})
	$(call ton_deploy,AccessController,$(ACCESS_CONTROLLER_PARAMS))
	$(call ton_deploy,BridgeVoteController,$(BRIDGE_VOTE_CONTROLLER_PARAMS))
	$(call ton_deploy,Bridge,$(BRIDGE_PARAMS))
	$(call ton_deploy,Handler,$(HANDLER_PARAMS))

.PHONY: ton-block-producing
ton-block-producing:
	while [ 1 -gt 0 ] ; do \
		tonos-cli callex sendGrams $(GIVER_ADDRESS) $(CONTRACTS_PATH)/Giver.abi.json -- --dest $(ADDRESS) --amount "0" \
		sleep $(BLOCK_TIME); \
	done

.PHONY: sub-setup
sub-setup:
	halva-cli exec -f /scripts/setup.js -p /configs/halva.js

.PHONY: ton-send-msg
ton-send-msg:
	tonos-cli call $(ADDRESS) sendData '{"destination": "'$(RECEIVE_ADDRESS)'", "bounce":true, "value": "20000000", "data":"0x$(shell echo $(MSG) | xxd -p)", "destinationChainId":"0x01"}' --abi /contracts/Sender.abi.json --sign $(KEYS_PATH)/$(ADDRESS).tonos.key

#################
# TON Functions #
#################

define ton_set_addresses
	$(call ton_genaddr,RECEIVER_ADDRESS,Receiver,$(ADDRESS))
	$(call ton_genaddr,ACCESS_CONTROLLER_ADDRESS,AccessController,$(ADDRESS))
	$(call ton_genaddr,BRIDGE_VOTE_CONTROLLER_ADDRESS,BridgeVoteController,$(ADDRESS))
	$(call ton_genaddr,BRIDGE_ADDRESS,Bridge,$(ADDRESS))
	$(call ton_genaddr,HANDLER_ADDRESS,Handler,$(ADDRESS))

	@echo "Bridge Vote Controller address:   $(BRIDGE_VOTE_CONTROLLER_ADDRESS)"
	@echo "Access Controller address:        $(ACCESS_CONTROLLER_ADDRESS)"
	@echo "Bridge address:                   $(BRIDGE_ADDRESS)"
	@echo "Handler address:                  $(HANDLER_ADDRESS)"
endef

define ton_genaddr
	$(eval GEN_ADDRESS_CMD :=$(shell tonos-cli genaddr --setkey $(KEYS_PATH)/$(3).tonos.key $(CONTRACTS_PATH)/$(2).tvc $(CONTRACTS_PATH)/$(2).abi.json))
	$(eval $(1) := $(shell echo "$(GEN_ADDRESS_CMD)" | grep -o "Raw address: \([0-9a-zA-Z:]*\)" | grep -o "0:\([0-9a-zA-Z:]*\)"))
endef

define ton_send_init_value
	tonos-cli callex sendGrams $(GIVER_ADDRESS) $(CONTRACTS_PATH)/Giver.abi.json -- --dest $(1) --amount $(2)
endef

define ton_deploy
	tonos-cli deploy $(CONTRACTS_PATH)/$(1).tvc $(2) --abi $(CONTRACTS_PATH)/$(1).abi.json --sign $(KEYS_PATH)/$(ADDRESS).tonos.key
endef
