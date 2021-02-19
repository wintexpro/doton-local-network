const mnemonic = "bottom drive obey lake curtain smoke basket hold race lonely fit walk";

module.exports = {
  networks: {
    test: {
      mnemonic,
      ws: "ws://doton-sub-chain:9944",
    },
  },
  polkadotjs: {
    types: {
      "Message": "Text",
      "chainbridge::ChainId": "u8",
      "ExtAddress": "Text",
      "ChainId": "u8",
      "ResourceId": "[u8; 32]",
      "Nonce": "u64",
      "DepositNonce": "u64",
      "ProposalVotes": {
        "votes_for": "Vec<AccountId>",
        "votes_against": "Vec<AccountId>",
        "status": "enum"
      },
      "Erc721Token": {
        "id": "TokenId",
        "metadata": "Vec<u8>"
      },
      "TokenId": "U256",
      "Address": "AccountId",
      "LookupSource": "AccountId"
    }
  }
}