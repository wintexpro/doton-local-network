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
      "ExtAddress": "Text",
      "chainbridge::ChainId": "u8",
      "ChainId": "u8",
      "ResourceId": "[u8; 32]",
      "Nonce": "u64",
      "DepositNonce": "u64",
      "ProposalVotes": {
        "votes_for": "Vec<AccountId>",
        "votes_against": "Vec<AccountId>",
        "status": "enum"
      },
      "Address": "AccountId",
      "LookupSource": "AccountId"
    }
  }
}