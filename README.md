<p align="center">
  <img src="https://github.com/juuroudojo/images/blob/main/camino-logo.png" height="150" />
</p>

<br/>

# Camino Parametric Insurance

## [Deployment Guide](https://github.com/juuroudojo/CaminoInsurance/blob/master/DEPLOYMENT.MD)


Repo explores the topic of parametric insurance, walks you through basic concepts topic beholds, discovering solutions with defferent approaches and angles. The architecture description of each can be put down like this:
- Oracle-based parametric insurance built like a prototype suggesting the existing oracle infrastructure.
- Oracle-based parametric insurance with mocked oracle infrastructure.
- Subscription-based parametric insurance with mocked oracle infrastrcture.
- Subscription-based parametric insurance with mocked oracle infrastrcture and an interactive game-like component(The flight status is randomised after subscription, tokens and flights are permissionless).
- Ticketing ecosystem using the data provided by ticket sales as a leverage for a parametric insurance system. This example discovers how parametric insurance can be an integrated feature within another project, not just a standalone product.
## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Installation and Setup](#installation-and-setup)
5. [User Guide](#user-guide)
6. [Contributing](#contributing)
7. [License and Contact Information](#license-and-contact-information)

## Description

Repo contains implementations of the following projects:


## Prerequisitess

To run and interact with these projects, you will need:

- [Node.js](https://nodejs.org/en/download/) (version 14.x or higher)
- [npm](https://www.npmjs.com/get-npm) (usually bundled with Node.js)
- [Hardhat](https://hardhat.org/getting-started/#overview) development environment
- [Camino Wallet](https://wallet.camino.foundation/) (Or you can also use MetaMask, or any other wallets)

## Project Structure

The repository is organized as follows:

- `contracts/` - Contains the Solidity smart contracts implementing the token standards and marketplace:
  - `subInsurance/` - Contains the Subscription-based parametric insurance with mocked oracle infrastrcture.
  - `ticketingInsurance/` - Contains the Ticketing ecosystem using the data provided by ticket sales as a leverage for a parametric insurance system.
- `test/` - Contains the test scripts for the smart contracts. Also a good place to look for examples of how to interact with the contracts.
  -`SubInsurance.ts` - Tests for the Subscription-based parametric insurance with mocked oracle infrastrcture and an interactive randomness element.
  <!-- As far as randomness is involved some test are intended to fail sometimes -->
    -`TicketingInsurance.ts` - Tests for the Ticketing ecosystem using the data provided by ticket sales as a leverage for a parametric insurance system.
- `scripts/` - Contains deployment scripts.

## Installation and Setup

1. Clone the repository:

```bash
git clone https://github.com/juuroudojo/CaminoInsurance.git
```

2. Install the required dependencies:

```bash
cd CaminoInsurance
npm install
```

3. Create a `.env` file in the root directory and configure it with your MetaMask wallet's private key and a [Columbus testnet]() API key for deploying to testnets:

```dotenv
PRIVATE_KEY="your_private_key"
COLUMBUS_API_KEY="your_columbus_api_key"
```

4. Compile the smart contracts:

```bash
npx hardhat compile
```

5. Deploy the contracts to a local test network or a public testnet using Hardhat:

```bash
npx hardhat run scripts/deploy.ts --network localhost
```

## User Guide

The tests are also a good place to look for examples of how to interact with the contracts. Feel free to look through different use cases in the test scripts in the `test/` directory.

## Contributing

If you'd like to contribute to the project, please submit an issue or create a pull request with your proposed changes.

## License and Contact Information

This project is licensed under the [MIT License](LICENSE). For any questions or suggestions, please contact the repository owner.


