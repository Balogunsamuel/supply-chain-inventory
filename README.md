# SupplyChainInventory

![License](https://img.shields.io/badge/License-MIT-blue.svg)

## Introduction

SupplyChainInventory is a Solidity smart contract that manages a supply chain inventory system. It allows you to create, track, and transfer products within the supply chain. The smart contract is designed to be used on any EVM blockchain.

## Description

This smart contract includes features for creating products, tracking product details, checking product availability, and transferring ownership of the product from one address to another while ensuring secure and transparent transactions.

## Features

- **Create Products**: The owner of the contract can create new products with a name, price, and initial quantity.

- **Check Price and Quantity**: Users can query the price and available quantity of a product.

- **Pay for Products**: Users can purchase a product by sending a specified amount. The product's ownership is transferred to the buyer.

- **Track Ownership**: The smart contract keeps a record of product ownership changes.

- **Availability Check**: The contract checks if a product is available for purchase.

## Installation

To use this smart contract, you need to deploy it on the Ethereum blockchain. You can follow these steps:

1. Clone the repository or copy the contract code to a Solidity file.

2. Use a development environment like Remix, Foundry, or Hardhat to deploy the contract to the blockchain.

3. Interact with the deployed contract using a web3 library or Ethereum wallet.

## Usage

1. **Creating a Product**:

   To create a product, call the `createProduct` function with the product's name, price, and initial quantity. Only the contract owner can create products.

2. **Checking Price and Quantity**:

   Use the `getPrice` and `getQuantity` functions to check the price and quantity of a product based on its ID.

3. **Paying for a Product**:

   To purchase a product, call the `payForProduct` function with the product ID, the address of the new owner, and the desired quantity. Ensure you send the correct amount of Ether with the transaction.

4. **Checking Availability**:

   You can check the availability of a product using the `quantityAvailable` function. It will return true if the product is available for purchase.

5. **Viewing Ownership History**:

   You can view the ownership history of a product by calling the `getOwnersOfAProduct` function with the product ID.

## Contributing

Contributions to this project are welcome. If you have ideas for improvements or would like to report issues, please follow these steps:

1. Fork the repository
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them.
4. Push your changes to your branch.
5. Submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
