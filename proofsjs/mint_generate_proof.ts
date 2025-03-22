// Simple Node.js script to generate a proof using Noir
// Dependencies: @noir-lang/noir_js, @aztec/bb.js
// Make sure to have circuit.json in the same directory

import { Noir } from '@noir-lang/noir_js';
import { UltraPlonkBackend } from '@aztec/bb.js';
import { readFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { BabyJubJubUtils } from './elgamal';

// Get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load circuit using a more robust approach
const circuitPath = resolve(__dirname, '../circuits/mint/target/mint.json');
const circuit = JSON.parse(readFileSync(circuitPath, 'utf8'));

// Helper function for JSON.stringify to handle BigInt
const jsonStringifyReplacer = (key, value) => {
    if (typeof value === 'bigint') {
        return value.toString();
    }
    return value;
};

const main = async () => {
    try {
        console.log('Initializing Noir...');
        const noir = new Noir(circuit);
        
        console.log('Initializing UltraPlonkBackend...');
        const backend = new UltraPlonkBackend(circuit.bytecode, {
             threads: require('os').cpus().length
        });
        
        // Initialize BabyJubJub utilities
        console.log('Initializing BabyJubJub utilities...');
        const bjj = new BabyJubJubUtils();
        await bjj.init();
        
        // Generate or use existing private key
        // The private key from the test is used for consistency
        const privateKey = BigInt("2291123624948246627368989940774052753470489062495018070576418670157516550852");
        
        // Derive public key from private key
        console.log('Deriving public key...');
        const publicKey = bjj.privateToPublicKey(privateKey);
        console.log('Public key:', JSON.stringify(publicKey, jsonStringifyReplacer));
        
        // Value to mint (should be a u40, i.e., less than 2^40)
        const value = 1000000000000; // 1 trillion tokens
        
        // Randomness for the encryption
        // The randomness from the test is used for consistency
        const randomness = BigInt("168986485046885582825082387270879151100288537211746581237924789162159767775");
        
        // Encrypt the value using ElGamal encryption
        console.log('Encrypting value...');
        const encryptedResult = bjj.exp_elgamal_encrypt(publicKey, value, randomness);
        console.log('Encrypted result:', JSON.stringify(encryptedResult, jsonStringifyReplacer));
        
        // Final input for mint proof using the exact format the circuit expects
        const input = {
            private_key: privateKey.toString(),
            randomness: randomness.toString(),
            public_key: {
                x: publicKey.x.toString(),
                y: publicKey.y.toString()
            },
            value: value.toString(),
            C1: {
                x: encryptedResult.C1.x.toString(),
                y: encryptedResult.C1.y.toString()
            },
            C2: {
                x: encryptedResult.C2.x.toString(),
                y: encryptedResult.C2.y.toString()
            }
        };
        
        console.log('Input prepared:', JSON.stringify(input, null, 2));
        
        console.log('Generating witness...');
        const { witness } = await noir.execute(input);
        console.log('Witness generated.');
        
        console.log('Generating proof...');
        const proof = await backend.generateProof(witness);
        console.log('Proof generated:', proof);
        
        return proof;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
};

main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
}).then((data) => {
    console.log("public Inputs", data.publicInputs);
    // proof to hex
    console.log("proof", Buffer.from(data.proof).toString('hex'));
    process.exit(0);
})
;