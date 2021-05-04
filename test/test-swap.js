const Web3 = require('web3')

const uri = 'http://localhost:8545'
const web3 = new Web3(uri)
const provider = new Web3.providers.HttpProvider(uri)

const { expect } = require("chai");

const ADDR = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";
const DAI = "0x6b175474e89094c44da98b954eedeac495271d0f";
const router = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

const ERC20Abi = [
  // Read-Only Functions
  "function balanceOf(address owner) view returns (uint256)",
  "function decimals() view returns (uint8)",
  "function symbol() view returns (string)",

  // Authenticated Functions
  "function transfer(address to, uint amount) returns (boolean)",

  // Events
  "event Transfer(address indexed from, address indexed to, uint amount)"
];

describe("Swap", function () {
  it('balanceOf DAI', async function() {
    const ERC20_DATA = require('../artifacts/@uniswap/v2-periphery/contracts/interfaces/IERC20.sol/IERC20.json')
    const DAI_ADDRESS = '0x6b175474e89094c44da98b954eedeac495271d0f'

    const instance = new web3.eth.Contract(
      ERC20_DATA.abi,
      DAI_ADDRESS
    );

    let balance = await instance.methods.balanceOf(DAI_ADDRESS).call();
    assert.notEqual(0, balance)
  })

  it("make a swap", async function () {
    const provider = ethers.getDefaultProvider();

    const Swap = await ethers.getContractFactory("Swap");
    const swap = await Swap.deploy(router, DAI);

    await swap.deployed();

    let deadline = ((new Date()).getTime() / 1000).toFixed(0)
    let DAIAmount = 1650
    console.log(DAIAmount);

    DAIAmount = ethers.BigNumber.from(DAIAmount)
    await swap.convertEthToDai(DAIAmount, deadline, {
      value: ethers.utils.parseUnits('1', 'ether').toHexString()
    });

    const DAIContract = await new ethers.Contract(DAI, ERC20Abi, provider);
    let r = await DAIContract.balanceOf(swap.address)
    console.log(r.toNumber());
  });
});
