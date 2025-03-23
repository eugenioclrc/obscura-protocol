# Obscura Protocol

A privacy-preserving token protocol built on Ethereum using ElGamal encryption and zero-knowledge proofs.

## Overview

Obscura Protocol enables private token transfers on Ethereum by encrypting token balances using ElGamal encryption. Users can transfer tokens without revealing the amounts, while still proving the validity of transfers using zero-knowledge proofs.

## Key Features

- **Private Token Balances**: All token balances are encrypted using ElGamal encryption
- **Zero-Knowledge Proofs**: Transfers are validated using zk-proofs to ensure correctness without revealing amounts
- **Public Key Infrastructure**: Built-in PKI for managing user encryption keys
- **ERC20 Compatible**: Works with existing ERC20 token standards

## How It Works

1. Users register their public encryption keys with the protocol
2. Token balances are stored as ElGamal ciphertexts on-chain
3. To transfer tokens:
   - Sender generates a zk-proof showing the transfer is valid
   - Protocol verifies proof and updates encrypted balances
   - Only sender and receiver can decrypt their own balances

## Getting Started

### Prerequisites

- Node.js 16+
- Foundry
- Bun (for running some of the JavaScript components)

### Installation

```bash
# Clone the repository with submodules
git clone --recursive https://github.com/your-username/obscura-protocol.git
cd obscura-protocol

# Install dependencies for the smart contracts
cd elgamal-tokens
forge install

# Install dependencies for the proof generation
cd ../proofsjs
npm install

# Install dependencies for the frontend
cd ../frontend
npm install
```

### Building

```bash
# Build smart contracts
cd elgamal-tokens
forge build

# Build the circuits
make all

# Build the frontend
cd ../frontend
npm run build
```

## Project Structure

### `/elgamal-tokens`

Contains the Solidity smart contracts for the Obscura Protocol. This is a Foundry project with:
- `src/` - Smart contract implementations including the main token contract, ElGamal encryption logic, and proof verification
- `test/` - Tests for the smart contracts
- `script/` - Deployment and interaction scripts

### `/circuits`

Zero-knowledge circuits implemented in Circom:
- `elgamal/` - Circuits for ElGamal encryption operations
- `mint/` - Circuits for minting new tokens
- `transfer/` - Circuits for transferring tokens between users
- `transfer_to_new/` - Circuits for transferring tokens to new users

### `/proofsjs`

JavaScript tools for generating zero-knowledge proofs:
- Generates proofs for mint and transfer operations
- Handles ElGamal encryption/decryption in JavaScript
- Integrates with the circuits for proof generation

### `/frontend`

A web application built with SvelteKit:
- Provides a user interface for interacting with the Obscura Protocol
- Manages user keys and balances
- Allows users to mint and transfer tokens privately

### `/demojs`

Contains a simple demo implementation in TypeScript:
- Demonstrates the core functionality of the protocol
- Provides examples of using the ElGamal encryption and proof system

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
