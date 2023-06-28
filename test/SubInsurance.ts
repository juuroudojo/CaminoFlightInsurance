import { ethers, network } from 'hardhat';
import { expect } from 'chai';
import { BigNumber } from 'ethers';

import {
  InsuranceWizard,
  MockObserver,
  RefundManager,
  MockToken,
  IERC20,
  MockToken__factory,
  MultisigMock,
} from '../typechain';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

async function getImpersonatedSigner(address: string): Promise<SignerWithAddress> {
  await ethers.provider.send(
    'hardhat_impersonateAccount',
    [address]
  );

  return await ethers.getSigner(address);
}

async function skipDays(days: number) {
  ethers.provider.send("evm_increaseTime", [days * 86400]);
  ethers.provider.send("evm_mine", []);
}

async function sendEth(users: SignerWithAddress[]) {
  let signers = await ethers.getSigners();

  for (let i = 0; i < users.length; i++) {
    await signers[0].sendTransaction({
      to: users[i].address,
      value: ethers.utils.parseEther("1.0")

    });
  }
}

  describe('Subscription insurance', function () {
    let owner: SignerWithAddress;
    let user1: SignerWithAddress;
    let user2: SignerWithAddress;
    let multisigMock: SignerWithAddress;
    let flightId: string;

    let token: IERC20;
    let wizard: InsuranceWizard;
    let manager: RefundManager;
    let observer: MockObserver;
    let multisig: MultisigMock;
  
    before(async function () {
      flightId = ethers.utils.formatBytes32String("JL1727");
    });

    beforeEach(async function () {
      await network.provider.request({
        method: "hardhat_reset",
        params: [{
            forking: {
                enabled: true,
                jsonRpcUrl: process.env.POLYGON_FORKING_URL as string,
                //you can fork from last block by commenting next line
                // blockNumber: 40490876,
            },
        },],
        });

        flightId = ethers.utils.formatBytes32String("FruitNinja");

        [owner, user1, user2, multisigMock] = await ethers.getSigners();

        let Token = await ethers.getContractFactory("MockToken"); 
        token = await Token.deploy("Toki", "TOKI", ethers.utils.parseEther("100000"));

        let Wizard = await ethers.getContractFactory("InsuranceWizard");
        wizard = await Wizard.deploy();

        let Manager = await ethers.getContractFactory("RefundManager");
        let manager = await Manager.deploy();

        let Observer = await ethers.getContractFactory("MockObserver");
        observer = await Observer.deploy(manager.address);

        let Multisig = await ethers.getContractFactory("MultisigMock");
        multisig = await Multisig.deploy([owner.address], 1);

        // Wizard Set-up
        await wizard.setToken(token.address);
        await wizard.setFlightObserver(observer.address);
        await wizard.setRefundHandler(manager.address);
        await wizard.setSubThreshold(ethers.utils.parseEther("0.1"));
        await wizard.setMultisig(wizard.address);

        await manager.setWizard(wizard.address);
        await manager.setToken(token.address);

        // Set-up Subscription tiers
        await wizard.setInsuranceTier(0, 300, 300);
        await wizard.setInsuranceTier(1, 300, 300);
        await wizard.setInsuranceTier(2, 30, 300);

        // Roles and permissions
        await manager.grantRole(await manager.DEFAULT_ADMIN_ROLE(), observer.address);

        await token.transfer(manager.address, ethers.utils.parseEther("1000"));
    });

    it('Should process the full cycle of data flow ', async function () {
      // User set-uo
      await token.transfer(user1.address, ethers.utils.parseEther("100"));
      await token.transfer(wizard.address, ethers.utils.parseEther("1000"));

      await token.connect(multisigMock).approve(wizard.address, ethers.utils.parseEther("1000"));

      let balanceBefore = await token.balanceOf(user1.address);

      await token.connect(user1).approve(wizard.address, ethers.utils.parseEther("100"));
      await wizard.connect(user1).insureFlight(ethers.utils.parseEther("10"), 2, flightId);

      console.log(await observer.recentFlightStatus(flightId));

      await skipDays(2);

      let balanceAfter = await token.balanceOf(user1.address);

      console.log("Balance before", balanceBefore.toString());
      console.log("Balance after", balanceAfter.toString());

      expect(balanceAfter).to.be.gt(balanceBefore);
    });

    it('Should output random results ', async function () {
      // User set-uo
      await token.transfer(user1.address, ethers.utils.parseEther("100"));
      await token.transfer(wizard.address, ethers.utils.parseEther("1000"));

      await token.connect(multisigMock).approve(wizard.address, ethers.utils.parseEther("1000"));

      let balanceBefore = await token.balanceOf(user1.address);

      await token.connect(user1).approve(wizard.address, ethers.utils.parseEther("100"));
      await wizard.connect(user1).insureFlight(ethers.utils.parseEther("10"), 2, flightId);

      console.log(await observer.recentFlightStatus(flightId));

      await skipDays(2);

      let balanceAfter = await token.balanceOf(user1.address);

      console.log("Balance before", balanceBefore.toString());
      console.log("Balance after", balanceAfter.toString());
    });

    it('Should output random results 2 ', async function () {
      // User set-uo
      await token.transfer(user1.address, ethers.utils.parseEther("100"));
      await token.transfer(wizard.address, ethers.utils.parseEther("1000"));

      await token.connect(multisigMock).approve(wizard.address, ethers.utils.parseEther("1000"));

      let balanceBefore = await token.balanceOf(user1.address);

      await token.connect(user1).approve(wizard.address, ethers.utils.parseEther("100"));
      await wizard.connect(user1).insureFlight(ethers.utils.parseEther("10"), 2, flightId);

      console.log(await observer.recentFlightStatus(flightId));

      await skipDays(2);

      let balanceAfter = await token.balanceOf(user1.address);

      console.log("Balance before", balanceBefore.toString());
      console.log("Balance after", balanceAfter.toString());
    });

    });
