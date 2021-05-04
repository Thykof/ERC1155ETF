const Web3 = require('web3')

const uri = 'http://localhost:8545'
const web3 = new Web3(uri)
const provider = new Web3.providers.HttpProvider(uri)

const ERC20_DATA = require('../artifacts/contracts/IERC20.sol/IERC20.json')
const DAI_ADDRESS = '0x6b175474e89094c44da98b954eedeac495271d0f'

async function main() {
  const instance = new web3.eth.Contract(
    ERC20_DATA.abi,
    DAI_ADDRESS
  );

  let balance = await instance.methods.balanceOf(DAI_ADDRESS).call();
  console.log(`balance is: ${balance}`);
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
