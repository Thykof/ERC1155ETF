# ERC1155ETF

Add this:

```
networks: {
  hardhat: {
    forking: {
      url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
      blockNumber: 12081440
    }
  }
}
```

in `hardhat.config.js` to fork the mainet ans have the UNISWAP and ERC20 contracts already deployed.

  
