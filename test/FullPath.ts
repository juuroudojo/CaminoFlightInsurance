import { ethers } from 'hardhat';
import { expect } from 'chai';

import {
  FlightManager,
  TicketPurchase,
  TicketManager,
  RefundHandler,
  TokenDealer,
  MockToken,
  BoardingValidator,
} from '../typechain';

describe('Flight Booking Contracts', function () {
  let flightManager: FlightManager;
  let ticketPurchase: TicketPurchase;
  let ticketManager: TicketManager;
  let refundHandler: RefundHandler;
  let tokenDealer: TokenDealer;
  let mockToken: MockToken;
  let boardingValidator: BoardingValidator;

  before(async function () {
    const [owner, user1, user2] = await ethers.getSigners();

    let mockTokenFactory = await ethers.getContractFactory('MockToken');
    mockToken = await mockTokenFactory.deploy('Mock Token', 'MOCK', ethers.utils.parseEther("50")) as MockToken;

    let tokenDealerFactory = await ethers.getContractFactory('TokenDealer');
    tokenDealer = await tokenDealerFactory.deploy() as TokenDealer;

    let flightManagerFactory = await ethers.getContractFactory('FlightManager');
    flightManager = await flightManagerFactory.deploy() as FlightManager;

    let ticketPurchaseFactory = await ethers.getContractFactory('TicketPurchase');
    ticketPurchase = await ticketPurchaseFactory.deploy(flightManager.address, ticketManager.address, tokenDealer.address, mockToken.address) as TicketPurchase;

    let boardingValidatorFactory = await ethers.getContractFactory('BoardingValidator');
    boardingValidator = await boardingValidatorFactory.deploy(flightManager.address) as BoardingValidator;

    let refundHandlerFactory = await ethers.getContractFactory('RefundHandler');
    refundHandler = await refundHandlerFactory.deploy(ticketManager.address, flightManager.address) as RefundHandler;

    let ticketManagerFactory = await ethers.getContractFactory('TicketManager');
    ticketManager = await ticketManagerFactory.deploy() as TicketManager;
  });


});