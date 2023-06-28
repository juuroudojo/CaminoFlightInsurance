import { ethers } from "hardhat";

async function main() {
  const Observer = await ethers.getContractFactory("Lock");
  const observer = await Observer.deploy(unlockTime);

  await observer.deployed();

  console.log(`Lock deployed to ${observer.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
