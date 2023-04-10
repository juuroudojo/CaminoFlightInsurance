import { ethers, network } from 'hardhat';
import { expect } from 'chai';
import { BigNumber } from 'ethers';

import {
  FlightManager,
  TicketPurchase,
  TicketManager,
  RefundHandler,
  TokenDealer,
  MockToken,
  BoardingValidator,
  IERC165,
  FlightObserver,
  IERC20,
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

describe('Flight Booking Contracts', function () {
  let flightManager: FlightManager;
  let ticketPurchase: TicketPurchase;
  let ticketManager: TicketManager;
  let refundHandler: RefundHandler;
  let tokenDealer: TokenDealer;
  let tokenDealerM: SignerWithAddress;
  let mockToken: MockToken;
  let boardingValidator: BoardingValidator;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;
  let owner: SignerWithAddress;
  let flightId: string;
  let mockTokenM: SignerWithAddress;

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
              blockNumber: 41152251,
          },
      },],
  });

    [owner, user1, user2] = await ethers.getSigners();

    // DEPLOYMENT

    let mockTokenFactory = await ethers.getContractFactory('MockToken');
    mockToken = await mockTokenFactory.deploy('Mock Token', 'MOCK', ethers.utils.parseEther("50")) as MockToken;

    // Instance of mock token to emulate calls.
    mockTokenM = await getImpersonatedSigner(mockToken.address);

    let tokenDealerFactory = await ethers.getContractFactory('TokenDealer');
    tokenDealer = await tokenDealerFactory.deploy() as TokenDealer;

    tokenDealerM = await getImpersonatedSigner(tokenDealer.address);

    let flightManagerFactory = await ethers.getContractFactory('FlightManager');
    flightManager = await flightManagerFactory.deploy() as FlightManager;

    // let FlightObserverFactory = await ethers.getContractFactory('FlightObserver');
    // flightObserver = await FlightObserverFactory.deploy() as FlightObserver; *****
    let ticketManagerFactory = await ethers.getContractFactory('TicketManager');
    ticketManager = await ticketManagerFactory.deploy(flightManager.address) as TicketManager;

    let ticketPurchaseFactory = await ethers.getContractFactory('TicketPurchase');
    ticketPurchase = await ticketPurchaseFactory.deploy(flightManager.address, ticketManager.address, tokenDealer.address, mockToken.address) as TicketPurchase;

    let boardingValidatorFactory = await ethers.getContractFactory('BoardingValidator');
    boardingValidator = await boardingValidatorFactory.deploy(ticketManager.address) as BoardingValidator;

    let refundHandlerFactory = await ethers.getContractFactory('RefundHandler');
    refundHandler = await refundHandlerFactory.deploy(ticketManager.address, flightManager.address) as RefundHandler;

    

    // GRANTING ROLES
    await flightManager.grantRole(await flightManager.DEFAULT_ADMIN_ROLE(), ticketManager.address);
    await flightManager.grantRole(await flightManager.DEFAULT_ADMIN_ROLE(), ticketPurchase.address);
    await flightManager.grantRole(await flightManager.DEFAULT_ADMIN_ROLE(), boardingValidator.address);
    await flightManager.grantRole(await flightManager.DEFAULT_ADMIN_ROLE(), refundHandler.address);

    await ticketManager.grantRole(await ticketManager.DEFAULT_ADMIN_ROLE(), ticketPurchase.address);
    await ticketManager.grantRole(await ticketManager.DEFAULT_ADMIN_ROLE(), refundHandler.address);
    await ticketManager.grantRole(await ticketManager.DEFAULT_ADMIN_ROLE(), boardingValidator.address);

    await tokenDealer.grantRole(await tokenDealer.DEFAULT_ADMIN_ROLE(), ticketPurchase.address);
    await tokenDealer.grantRole(await tokenDealer.DEFAULT_ADMIN_ROLE(), refundHandler.address);


    // await refundHandler.grantRole(await refundHandler.DEFAULT_ADMIN_ROLE(), flightObserver.address);

    // ADDITIONAL SETUP
    await refundHandler.setToken(mockToken.address);

    //tokenDealer is a multisig

    // await ticketManager.setFlightManager(flightManager.address);
    // approve max uint

    await mockToken.mint(user1.address, ethers.utils.parseEther("50"));
    await mockToken.connect(user1).approve(ticketPurchase.address, ethers.utils.parseEther("50"));

  });

  describe("Ticket Purchase", async() => {

    it('Should not allow user to purchase ticket if flight does not exist/already departed', async function () {
      // let flightId = ethers.utils.formatBytes32String("JL1727");

      // Airline side initiating the flight with the flight details
      await flightManager.addFlight(flightId, "Dusseldorf", "Berlin", 1680747511, 1680747511, ethers.utils.parseEther("0.2"), 20)

      await skipDays(2);

      // User side buying the ticket
      await expect(ticketPurchase.connect(user1).purchaseTicket(flightId, 5)).to.be.revertedWith('Flight has already departed');
    });

    it('Should update available seats after user has purchased one', async function () {
      // let flightId = ethers.utils.formatBytes32String("JL1727");

      // Airline side initiating the flight with the flight details
      await flightManager.addFlight(flightId, "Dusseldorf", "Berlin", 1680747511, 1680747511, ethers.utils.parseEther("0.2"), 20)

      let seatsBeforePurchase = await flightManager.getAvailableSeats(flightId);
      // User side buying the ticket
      await ticketPurchase.connect(user1).purchaseTicket(flightId, 5)

      let seatsAfterPurchase = await flightManager.getAvailableSeats(flightId);

      expect(seatsBeforePurchase.reduce((a, b) => a.add(b), BigNumber.from(0))).to.equal(seatsAfterPurchase.reduce((a, b) => a.add(b), BigNumber.from(0)).add(BigNumber.from(5)));

      console.log("Available seats before purchase", seatsBeforePurchase.toString());
      console.log("Available seats after purchase", seatsAfterPurchase.toString());
    });

    it("Should pull the correct amount of funds", async() => {
      await flightManager.addFlight(flightId, "Dusseldorf", "Berlin", 1680747511, 1680747511, ethers.utils.parseEther("0.2"), 20)
      let balanceBeforePurchase = await mockToken.balanceOf(user1.address);
      await ticketPurchase.connect(user1).purchaseTicket(flightId, 5)
      let balanceAfterPurchase = await mockToken.balanceOf(user1.address);

      expect(balanceAfterPurchase).to.equal(balanceBeforePurchase.sub(ethers.utils.parseEther("0.2")))

      console.log("Balance before purchase", balanceBeforePurchase.toString());
      console.log("Balance after purchase", balanceAfterPurchase.toString());
    })

    it('Should handle incorrect and repetable seat purchasing cases', async function () {
      let flightId = ethers.utils.formatBytes32String("JL1727");

      // Airline side initiating the flight with the flight details
      await flightManager.addFlight(flightId, "Dusseldorf", "Berlin", 1680747511, 1680747511, ethers.utils.parseEther("0.2"), 20)

      // User side buying the ticket
      await ticketPurchase.connect(user1).purchaseTicket(flightId, 5)

      await expect(ticketPurchase.connect(user1).purchaseTicket(flightId, 5)).to.be.revertedWith('Seat is taken')
      await expect(ticketPurchase.connect(user1).purchaseTicket(flightId, 58)).to.be.revertedWith('Incorrect seat number')
    });
  });

  describe("Validating the tickets", async() => {
    it("Should not validate if hasn't checked in", async() => {
      let flightId = ethers.utils.formatBytes32String("JL1727");

      // Airline side initiating the flight with the flight details
      await flightManager.addFlight(flightId, "Dusseldorf", "Berlin", 1686154680, 1686159000, ethers.utils.parseEther("0.2"), 20)

      // User side buying the ticket
      await ticketPurchase.connect(user1).purchaseTicket(flightId, 5)
      await expect(boardingValidator.connect(user1).validateBoardingPass(flightId)).to.be.revertedWith('Ticket not checked in');
    });

    it("Should handle incorrect timings", async() => {
      let flightId = ethers.utils.formatBytes32String("JL1727");

      // Airline side initiating the flight with the flight details
      await flightManager.addFlight(flightId, "Dusseldorf", "Berlin", 1686154680, 1686159000, ethers.utils.parseEther("0.2"), 20)

      // User side buying the ticket
      await ticketPurchase.connect(user1).purchaseTicket(flightId, 5)
      await skipDays(5);
      await boardingValidator.connect(user1).checkIn(flightId);
    });

    it("Should validate the ticket", async() => {
      let flightId = ethers.utils.formatBytes32String("JL1727");

      // Airline side initiating the flight with the flight details
      await flightManager.addFlight(flightId, "Dusseldorf", "Berlin", 1681758311, 1681858311, ethers.utils.parseEther("0.2"), 20)

      // User side buying the ticket
      await ticketPurchase.connect(user1).purchaseTicket(flightId, 5)

      await boardingValidator.connect(user1).checkIn(flightId);
      await boardingValidator.connect(user1).validateBoardingPass(flightId);
    });
  });

  describe("Refund", async() => {
    it("Should refund users", async() => {
      let flightId = ethers.utils.formatBytes32String("JL1727");

      // Airline side initiating the flight with the flight details
      await flightManager.addFlight(flightId, "Dusseldorf", "Berlin", 1681758311, 1681858311, ethers.utils.parseEther("0.2"), 20)

      // User side buying the ticket
      await sendEth([tokenDealerM]);
      await refundHandler.setTokenDealer(tokenDealerM.address);
      await refundHandler.setToken(mockToken.address);
      await refundHandler.setRefundRate(100)
      await mockToken.connect(tokenDealerM).approve(ticketPurchase.address, ethers.constants.MaxUint256);
      await mockToken.connect(tokenDealerM).approve(refundHandler.address, ethers.constants.MaxUint256);

      await ticketPurchase.connect(user1).purchaseTicket(flightId, 5)

      await boardingValidator.connect(user1).checkIn(flightId);
      await boardingValidator.connect(user1).validateBoardingPass(flightId);

      console.log("Balance before refund", (await mockToken.balanceOf(user1.address)).toString());
      // mocked data to be called by the flightObserver
      await refundHandler.handleRefund(flightId);

      console.log("Balance after refund", (await mockToken.balanceOf(user1.address)).toString());
    });
  });
  

});