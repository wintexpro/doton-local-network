GIVER_ADDRESS="0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94"
SENDER_ADDRESS="0:164d61e6cad0597545cb8ab98ecfdb2a29e0cc55d484daece02c63d8511e9a5f"
RECEIVE_ADDRESS="0:e50f4328179ef68fc4c45032adc97b714f668e4152a7b6805a391dca5cf492ee"
INI_VALUE="1T"

.PHONY: init
init:
	tonos-cli -V
	tonos-cli config --url http://doton-ton-chain

	$(MAKE) --file /scripts/Makefile send-init-value
	$(MAKE) --file /scripts/Makefile setup-contracts

.PHONY: send-init-value
send-init-value:
	tonos-cli callex sendGrams $(GIVER_ADDRESS) /contracts/Giver.abi.json -- --dest $(SENDER_ADDRESS) --amount $(INI_VALUE)
	tonos-cli callex sendGrams $(GIVER_ADDRESS) /contracts/Giver.abi.json -- --dest $(RECEIVE_ADDRESS) --amount $(INI_VALUE)

.PHONY: setup-contracts
setup-contracts:
	tonos-cli deploy /contracts/Sender.tvc {} --abi /contracts/Sender.abi.json --sign /keys/$(SENDER_ADDRESS).tonos.key
	tonos-cli deploy /contracts/Receiver.tvc {} --abi /contracts/Receiver.abi.json --sign /keys/$(SENDER_ADDRESS).tonos.key
	cd / && halva-cli exec -f /scripts/setup.js -p /configs/halva.js

	while [ 1 -gt 0 ] ; do \
		$(MAKE) --file /scripts/Makefile send-msg; \
		sleep 4; \
	done

.PHONY: send-msg
send-msg:
	tonos-cli call $(SENDER_ADDRESS) sendData '{"destination": "'$(RECEIVE_ADDRESS)'", "bounce":true, "value": "20000000", "data":"0x48656c6c6f20f09f928e", "destinationChainId":"0x01"}' --abi /contracts/Sender.abi.json --sign /keys/$(SENDER_ADDRESS).tonos.key