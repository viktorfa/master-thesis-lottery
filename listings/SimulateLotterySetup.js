contract('Simulate lottery build', (accounts) => {
  it('Should build master contract and match contracts for n players', async () => {
    const L = 2;
    const N = 2 ** L;

    const organizerAddress = accounts[0];
    const organizerInitialBalance = web3.utils.fromWei(
      await web3.eth.getBalance(organizerAddress),
      'ether'
    );

    console.log(`Organizer has ${organizerInitialBalance} ether`);

    console.log(`Building lottery with ${N} players.`);
    const startTime = new Date();
    const lotteryBuilder = new LotteryBuilder(N, price, tStart, tFinal, td);
    await lotteryBuilder.start();
    console.log(`Built lottery in ${new Date() - startTime} ms`);

    const organizerFinalBalance = web3.utils.fromWei(
      await web3.eth.getBalance(organizerAddress),
      'ether'
    );

    console.log(`Organizer has ${organizerFinalBalance} ether`);
    console.log(
      `Organizer used ${organizerInitialBalance -
        organizerFinalBalance} ether for gas.`
    );
  });
});
