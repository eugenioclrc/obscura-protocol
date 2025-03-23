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


# DEPLOYMENTS

### Mantle sepolia

```
forge script script/Local.s.sol --rpc-url https://rpc.sepolia.mantle.xyz --private-key 0x..... --ffi --optimize --broadcast

[⠊] Compiling...
No files changed, compilation skipped
Script ran successfully.

== Return ==
_weth: address 0x47D47bC32EF697cA134dCb36c0c33caD5d137324
_factory: address 0xD860E9DDC809c4d1556CdB3Ab5Bc618b90D22b17

## Setting up 1 EVM.

==========================

Chain 5003

Estimated gas price: 0.040000001 gwei

Estimated total gas used for script: 44184983278

Estimated amount required: 1.767399375304983278 ETH

==========================

##### mantle-sepolia
✅  [Success] Hash: 0xea046e01632804ccd1797829c171716994cd330150b99b60c9e1304d79e293f8
Contract Address: 0x47D47bC32EF697cA134dCb36c0c33caD5d137324
Block: 20599136
Paid: 0.041832372111618501 ETH (2091618501 gas * 0.020000001 gwei)


##### mantle-sepolia
✅  [Success] Hash: 0x49d5cee12f9a7db4ac7b34dd0e0d56b02be6427cea36de5018245f5d07eae96e
Contract Address: 0x11C6e9442adEeDdC976869DC90DDD099362aF223
Block: 20599139
Paid: 0.011119070115953478 ETH (555953478 gas * 0.020000001 gwei)


##### mantle-sepolia
✅  [Success] Hash: 0x42f75f6b6f2c06ba0f68c5bc8a207e96091cc2ca53a57b03200a4371a89b50b9
Contract Address: 0x9D6bF55aF92F2D223d09E99c5Fa47C3b215b2DCe
Block: 20599143
Paid: 0.126582109849105176 ETH (6329105176 gas * 0.020000001 gwei)


##### mantle-sepolia
✅  [Success] Hash: 0xe64897b3fcdb678a750594d07cbed1a0052558ec6ca7e21616f88cecec84be16
Contract Address: 0x2E330f7b2915744716c2b9a498CE38Dc2ab2f388
Block: 20599145
Paid: 0.126594597189729543 ETH (6329729543 gas * 0.020000001 gwei)


##### mantle-sepolia
✅  [Success] Hash: 0x764b8fc366f3f48587229e98906b58ec051806e94183231ef1d062517597966c
Contract Address: 0x68B8744b1A2486080ceef7e9794C56aa7a339bB6
Block: 20599148
Paid: 0.126577913248895346 ETH (6328895346 gas * 0.020000001 gwei)


##### mantle-sepolia
✅  [Success] Hash: 0x757a7fcff368c0506912c33c082835338692074e14883e3cf4be52f11507eab0
Contract Address: 0xD860E9DDC809c4d1556CdB3Ab5Bc618b90D22b17
Block: 20599150
Paid: 0.125351248107562092 ETH (6267562092 gas * 0.020000001 gwei)


##### mantle-sepolia
✅  [Success] Hash: 0x79ad9b9240ad5aad587c79f4ebb69b943c9e94db27f6acb0d809b1492e96178b
Block: 20599153
Paid: 0.003505926415296312 ETH (175296312 gas * 0.020000001 gwei)
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.


