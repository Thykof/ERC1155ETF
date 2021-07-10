const Web3 = require('web3')

const MyDeFiProject = artifacts.require("MyDeFiProject");

const uri = 'http://localhost:8545'
const web3 = new Web3(uri)
const provider = new Web3.providers.HttpProvider(uri)

const { expect } = require("chai");

describe("MyDeFiProject", function () {
  it('Make a swap', async function () {
    const myDeFiProject = await MyDeFiProject.new("Hello, world!");
    const r = await myDeFiProject.swapTokensForEth();
  })
});
