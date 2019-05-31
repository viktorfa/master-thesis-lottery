contract('Simulate lottery play', (accounts) => {
  it('Should play correctly', async () => {
    const L = 2;
    const N = 2 ** L;

    console.log(`Simulating lottery with ${N} players.`);
    let startTime = new Date();
    let tempTime = new Date();

    const lotteryBuilder = new LotteryBuilder(N, price, tStart, tFinal, td);
    await lotteryBuilder.start();

    console.log(`Built lottery in ${new Date() - tempTime} ms`);
    tempTime = new Date();

    const lottery = new LotteryContract(lotteryBuilder.lottery.address);
    await lottery.init();

    console.log(
      `Initialized lottery playing contract in ${new Date() - tempTime} ms`
    );
    tempTime = new Date();

    const matches = await lottery.getAllMatches();

    console.log(`Got all lottery matches in ${new Date() - tempTime} ms`);
    tempTime = new Date();

    const players = generatePlayers(N, accounts);
    const playerMap = players.reduce(
      (acc, x) => ({ ...acc, [x.address]: x }),
      {}
    );

    for (const { address } of players) {
      await lottery.deposit(address);
    }

    console.log(`All players joined in ${new Date() - tempTime} ms`);
    tempTime = new Date();

    const contractPlayers = await lottery.getPlayers();

    let winners = contractPlayers.map((address) => playerMap[address]);
    let level = 0;

    while (winners.length > 1) {
      console.log(`Playing level ${level}.`);
      for (const [i, { address, commitment }] of winners.entries()) {
        await matches[level][i >> 1].commit(commitment, { from: address });
      }
      for (const [i, { address, secret }] of winners.entries()) {
        await matches[level][i >> 1].reveal(secret, { from: address });
      }
      winners = await Promise.all([
        ...matches[level].map(async (match) => {
          return playerMap[await match.getWinner()];
        }),
      ]);
      level++;
      console.log(`Played level ${level} in ${new Date() - tempTime} ms`);
      tempTime = new Date();
    }
    console.log(`Played lottery in ${new Date() - startTime} ms`);

    const winner = await lottery.getWinner();
    assert.notEqual(winner, ZERO_ADDRESS);
    assert.equal(winner, winners[0].address);

    await lottery.lotteryContract.withdraw({ from: winner });

    console.log(
      `Winner is ${winner} who now has ${web3.utils.fromWei(
        await web3.eth.getBalance(winner),
        'ether'
      )} eth`
    );
  });
});