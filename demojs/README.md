# ElGamal Tokens JavaScript Demo

This is a JavaScript implementation of the ElGamal encryption tests using snarkyjs-elgamal.

## Prerequisites

- Node.js (v14 or higher)
- npm (v6 or higher)

## Installation

1. Install dependencies:
```bash
npm install
```

## Running Tests

To run the tests:
```bash
npm test
```

## Test Cases

The test suite includes the following test cases:

1. `should convert private key to public key`: Verifies that a private key can be converted to a valid public key point.
2. `should encrypt and decrypt small values within u40 range`: Tests encryption and decryption with a small value (42).
3. `should encrypt and decrypt zero`: Tests encryption and decryption with zero plaintext.
4. `should encrypt and decrypt maximum u40 value`: Tests with the maximum allowed value (2^40 - 1).
5. `should fail when encrypting value above u40 range`: Verifies that encryption fails when attempting to encrypt a value above the u40 range.

## Implementation Details

The implementation uses the Baby JubJub curve with the following parameters:
- a = 168700
- d = 168696
- Generator point and base point coordinates are provided in the test file

The ElGamal implementation enforces a u40 range constraint on plaintexts, ensuring they are less than 2^40. 