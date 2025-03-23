this folder contains basic javascript code to generate proofs for the circuits.

### Generate a mint proof
To generate a proof, run `bun run mint_generate_proof.ts`

### Generate a transfer proof
To generate a proof, run `bun run transfer_generate_proof.ts`

### Generate a transfer to new account proof
To generate a proof, run `bun run transfer_to_new_generate_proof.ts`


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