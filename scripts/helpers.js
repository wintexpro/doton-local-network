(async function () {
  const unsub = await halva.polkadot.tx.doton.sendMsg(process.env.MSG, 2).signAndSend(alicePair, (result) => {
    console.log(`Current status is ${result.status}`);

    if (result.status.isInBlock) {
      console.log(`Transaction included at blockHash ${result.status.asInBlock}`);
    } else if (result.status.isFinalized) {
      console.log(`Transaction finalized at blockHash ${result.status.asFinalized}`);
      unsub();
    }
  })
})()