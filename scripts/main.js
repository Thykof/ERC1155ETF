// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

const DAI = "0x6b175474e89094c44da98b954eedeac495271d0f";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const router = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Broker = await hre.ethers.getContractFactory("Broker");
  const broker = await Broker.deploy(
    router,
    DAI
  );

  await broker.deployed();

  console.log("Broker deployed to:", broker.address);

  let ETFs1 = await broker.getETF(1, 0);
  console.log(ETFs1[0]);
  console.log(ETFs1[1].toNumber());

  await broker.buyShares((100 * 10 ** 18).toString(), WETH);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
