// Setup substrate chain

(async function () {
  await execTx(halva.polkadot.tx.chainBridge.addRelayer(alicePair.address))

  await execTx(halva.polkadot.tx.chainBridge.setResource(
    "0x000000000000000000000053696d706c654d6573736167655265736f75726365",
    "0x446f746f6e2e77726974655f6d7367"
  ))

  await execTx(halva.polkadot.tx.chainBridge.setResource(
    "0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00",
    "0x4578616d706c652e7472616e73666572"
  ))

  await execTx(halva.polkadot.tx.chainBridge.whitelistChain(2))

  globalThis.process.exit(0)
})()

async function execTx(subsc) {
  return new Promise((resolve) => {
    halva.polkadot.tx.sudo
      .sudo(subsc)
      .signAndSend(alicePair, (result) => {
        if (result.isInBlock) resolve()
      })
  })
}