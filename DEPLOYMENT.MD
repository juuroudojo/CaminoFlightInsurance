# Deployment Guide

## Table of Contents

- [Introduction](#introduction)
- [Deployment Structure](#deployment-structure)
- [Mainnet Deployment](#mainnet-deployment)
- [Smart Contracts](#smart-contracts)
- [Columbus Deployment](#columbus-deployment)
- [Additional Info](#additional-info)
- [Contributions](#contributions)

## Introduction

This repo can be divided into 2 main parts: 
- Oracle-based parametric insurance with its system based on direct data loading provided by the ticketing infrastructure.
- Subscription-based parametric insurance with mocked oracle infrastrcture.

## Deployment Structure

The topic suggests exposing a robust ecosystem. Taking into account the missing infrastructure required for the oracle-based parametric insurance functionality at this stage, actions like mocking parts of the ecosystem and non-representative logic are required. This migh create quite a convuluted structure, so a respective approach was chosen.

The deployed ecosystem is a copy of Subscription-based parametric insurance with some assumptions, neglections and non-representative logic of the final product. 

The rest of the repo is to be deployed on testnet, but the approach there is more heavily focused on permission management. The interactions there require some roles. (You can contact us to obtain roles for additional testing opportunities). You can also learn a lot by simply going through the tests & rest of the repo.

The infrastructure presumes the following structure:
- All the flights already exist and are in progress (Meaning any bytes32 value is an eligible flight ID)
- Anyone can initiate the finalisation of the flight, the result will be randomised(in a very unsafe manner :d)
- Tokens can be minted and used by anyone by interacting with MockToken.sol
- The insurance subscription calls initiate a chain of events that will result in a payout if the flight is cancelled or delayed. All of it is executed in one call, so payout(if one is present) is instant. You can verify the status of the last finalised flight by calling recentFlightStatus() with flightId as a parameter. 


## Mainnet deployment

- [InsuranceWizard.sol](r) - address
- [MockObserver.sol](d) - address
- [RefundHandler.sol](d) - address
- [MockToken.sol](pu) - address

## Smart Contracts

<image src=https://github.com/juuroudojo/images/blob/main/Diao.png />

- **`InsuranceWizard.sol`** - The endpoint user interacts with. Stores info about subscription details, active plans, payout conditions, etc.

- **`MockObserver.sol`** - A variation of Observer contract with an infrastructure creating randomised data about flight completetion, cancellation, delay.

- **`RefundManager.sol`** - Executes the payout logic, stores and manages the funds.

- **`MockToken.sol`** - A permisionless token implementation. Tokens can be minted by anyone

## Columbus Deployment

Columbus infrastructure has a few additional contracts that are not present in the mainnet deployment, such as MultisigMock. Besides that a different approach to permission management is used. 


## Additional Info

The system is maintained by our team. If you face any issues, want some additional info/explanation or additional opportuinities to interact with the infrastructure feel free to reach out to us on [Discord](https://discord.gg/).

## Contributions

Difficulties and questions you face interacting with the templates is a valuable feedback for us. Reach out to us on [Discord](https://discord.gg/) or create an issue on GitHub. We will be happy to help you out.
