import {ethers} from "hardhat"
import fetch from 'node-fetch';
import { MyERC20Votes,MyERC20Votes__factory,TokenizedBallot,TokenizedBallot__factory } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Signer } from "ethers";

const MINT_AMOUNT = ethers.utils.parseUnits("10");

const proposals = ["Chocolate","Strawberry","Vanilla"];

async function deployContracts(){

  // Get the contract factory
    const factory = await ethers.getContractFactory("MyERC20Votes");

  // Deploy the contract
    const contract = await factory.deploy();
    await contract.deployed();
    const tokenTx = await contract.deployTransaction.wait();

    console.log('Token Contract deployed at address:', contract.address);

    const ballotFactory = await ethers.getContractFactory("TokenizedBallot");

    // Deploy the contract
    const ballotContract = await ballotFactory.deploy(
        proposals.map(ethers.utils.formatBytes32String)
        ,contract.address,tokenTx.blockNumber
        );
    await ballotContract.deployed();
  
    console.log('Ballot Contract deployed at address:', ballotContract.address);
    return contract;
}



async function main(){
    deployContracts();
    
}

main().catch((err)=>{
    console.error(err);
    process.exitCode = 1;
})