SHELL := /bin/bash

GIVER_ADDRESS=
PUBLIC_KEY=
KEY=

KEYS_PATH=
CONTRACTS_PATH=
SCRIPTS_PATH=

BRIDGE_VOTE_CONTROLLER_PUBLIC_KEY=
PROPOSAL_VOTERS_AMOUNT=

TON_URL=

INI_VALUE=

RELAYER_ADDRESS=
RELAYER_PARAMS=

SENDER_ADDRESS=
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

	$(call ton_send_init_value,$(RELAYER_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(SENDER_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(RECEIVER_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(BRIDGE_VOTE_CONTROLLER_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(ACCESS_CONTROLLER_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(BRIDGE_ADDRESS),$(INI_VALUE))
	$(call ton_send_init_value,$(HANDLER_ADDRESS),$(INI_VALUE))

.PHONY: ton-deploy-contracts
ton-deploy-contracts:
	$(call ton_set_addresses)

	$(eval RELAYER_PARAMS := '{"_accessControllerAddress": "$(ACCESS_CONTROLLER_ADDRESS)", "_myPublicKey": "$(PUBLIC_KEY)", "_myInitState":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Relayer.tvc)'", "_bridgeAddress":"$(BRIDGE_ADDRESS)"}')
	$(eval BRIDGE_VOTE_CONTROLLER_PARAMS := '{"_proposalStateInit":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Proposal.tvc)'","_ballotInitState":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Relayer.tvc)'","_deployInitialValue": 2000000000,"_publicKey":"'$(PUBLIC_KEY)'","_proposalVotersAmount":'$(PROPOSAL_VOTERS_AMOUNT)',"_bridgeAddress":"'$(BRIDGE_ADDRESS)'"}')
	$(eval BRIDGE_PARAMS := '{"_relayerInitState":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Relayer.tvc)'","_accessControllerAddress":"'$(ACCESS_CONTROLLER_ADDRESS)'","_voteControllerAddress": "'$(BRIDGE_VOTE_CONTROLLER_ADDRESS)'"}')
	$(eval ACCESS_CONTROLLER_PARAMS := '{"_accessCardInitState":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Relayer.tvc)'", "_initialValue": 1000000}')
	$(eval HANDLER_PARAMS := '{"_proposalStateInit":"'$(shell base64 -w 0 $(CONTRACTS_PATH)/Proposal.tvc)'"}')

	$(call ton_deploy,Sender,{})
	$(call ton_deploy,Receiver,{})
	$(call ton_deploy,Relayer,$(RELAYER_PARAMS))
	$(call ton_deploy,AccessController,$(ACCESS_CONTROLLER_PARAMS))
	$(call ton_deploy,BridgeVoteController,$(BRIDGE_VOTE_CONTROLLER_PARAMS))
	$(call ton_deploy,Bridge,$(BRIDGE_PARAMS))
	$(call ton_deploy,Handler,$(HANDLER_PARAMS))

	tonos-cli call $(ACCESS_CONTROLLER_ADDRESS) grantSuperAdminRole '{"accessCardAddress": "$(RELAYER_ADDRESS)"}' --abi $(CONTRACTS_PATH)/AccessController.abi.json --sign $(KEYS_PATH)/$(KEY).tonos.key
	tonos-cli call $(RELAYER_ADDRESS) bridgeSetHandler '{"messageType": "0x000000000000000000000053696d706c654d6573736167655265736f75726365", "handlerAddress":"$(HANDLER_ADDRESS)"}' --abi $(CONTRACTS_PATH)/Relayer.abi.json --sign $(KEYS_PATH)/$(KEY).tonos.key

.PHONY: ton-block-producing
ton-block-producing:
	$(call ton_set_addresses)
	while [ 1 -gt 0 ] ; do \
		tonos-cli callex sendGrams $(GIVER_ADDRESS) $(CONTRACTS_PATH)/Giver.abi.json -- --dest $(RELAYER_ADDRESS) --amount "0" \
		sleep $(BLOCK_TIME); \
	done

.PHONY: sub-setup
sub-setup:
	halva-cli exec -f /scripts/setup.js -p /configs/halva.js

# make -f /scripts/Makefile ton-send-msg MSG="Hello!" KEYS_PATH=/keys SCRIPTS_PATH=/scripts CONTRACTS_PATH=/contracts TON_URL=http://doton-ton-chain KEY=0:df22eba0b48020b70efa7a6e9d6360ed1dc20877250947470cc1289b14c9cc1e
.PHONY: ton-send-msg
ton-send-msg:
	$(call ton_set_addresses)
	tonos-cli call $(SENDER_ADDRESS) sendData '{"destination": "'$(RECEIVER_ADDRESS)'", "bounce":true, "value": "20000000", "data":"0x$(shell echo $(MSG) | xxd -p)", "destinationChainId":"0x01"}' --abi $(CONTRACTS_PATH)/Sender.abi.json --sign $(KEYS_PATH)/$(KEY).tonos.key

#################
# TON Functions #
#################

define ton_set_addresses
	$(call ton_genaddr,RELAYER_ADDRESS,Relayer,$(KEY))
	$(call ton_genaddr,SENDER_ADDRESS,Sender,$(KEY))
	$(call ton_genaddr,RECEIVER_ADDRESS,Receiver,$(KEY))
	$(call ton_genaddr,ACCESS_CONTROLLER_ADDRESS,AccessController,$(KEY))
	$(call ton_genaddr,BRIDGE_VOTE_CONTROLLER_ADDRESS,BridgeVoteController,$(KEY))
	$(call ton_genaddr,BRIDGE_ADDRESS,Bridge,$(KEY))
	$(call ton_genaddr,HANDLER_ADDRESS,Handler,$(KEY))

	@echo "Relayer address:                  $(RELAYER_ADDRESS)"
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
	tonos-cli deploy $(CONTRACTS_PATH)/$(1).tvc $(2) --abi $(CONTRACTS_PATH)/$(1).abi.json --sign $(KEYS_PATH)/$(KEY).tonos.key
endef
