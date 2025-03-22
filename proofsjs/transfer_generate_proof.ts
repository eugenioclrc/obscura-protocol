// Simple Node.js script to generate a proof for the transfer circuit using Noir
// Dependencies: @noir-lang/noir_js, @aztec/bb.js
// Make sure to have the circuit.json file accessible

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
const circuitPath = resolve(__dirname, '../circuits/transfer/target/transfer.json');
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
        
        // Generate or use existing private key (sender's private key)
        // The private key from the test is used for consistency
        const privateKey = BigInt("2291123624948246627368989940774052753470489062495018070576418670157516550852");
        
        // Derive sender's public key from private key
        console.log('Deriving sender\'s public key...');
        const senderPublicKey = bjj.privateToPublicKey(privateKey);
        console.log('Sender\'s public key:', JSON.stringify(senderPublicKey, jsonStringifyReplacer));
        
        // Recipient's public key (from the test case)
        const recipientPublicKey = bjj.privateToPublicKey(BigInt("2397698694665525209403000085013646741088197704326090841842743616643093564368"));
        console.log('Recipient\'s public key:', JSON.stringify(recipientPublicKey, jsonStringifyReplacer));

        // Value to transfer
        const transferValue = 100;
        
        // Sender's old balance (this would be known to the sender since they can decrypt their balance)
        const senderOldBalanceClear = 9900;
        
        // Randomness for encrypting the new balances
        const randomness1 = BigInt("268986485046885582825082387270879151100288537211746581237924789162159767775");
        const randomness2 = BigInt("3512595847879910647549805200013822046432901960729162086417588755890198945115");
        
        // Generate the encrypted old balances (normally these would come from the blockchain)
        console.log('Generating encrypted balances...');
        
        // Here we simulate existing encrypted balances for testing
        const oldRandomness1 = BigInt("168986485046885582825082387270879151100288537211746581237924789162159767775");
        const oldRandomness2 = BigInt("2512595847879910647549805200013822046432901960729162086417588755890198945115");

        const senderOldEncryptedBalance = bjj.exp_elgamal_encrypt(senderPublicKey, senderOldBalanceClear, oldRandomness1);
        const recipientOldEncryptedBalance = bjj.exp_elgamal_encrypt(recipientPublicKey, 42, oldRandomness2);
  
        // Calculate new balances
        const senderNewBalanceClear = senderOldBalanceClear - transferValue;
        const recipientNewBalanceClear = 100 + transferValue;
        
        // Encrypt new balances
        const senderNewEncryptedBalance = bjj.exp_elgamal_encrypt(senderPublicKey, senderNewBalanceClear, randomness1);
        
        // For the recipient's new balance, we'd normally use homomorphic addition on the blockchain
        // Here we're just encrypting it directly for the proof
        const recipientNewEncryptedBalance = bjj.exp_elgamal_encrypt(recipientPublicKey, recipientNewBalanceClear, oldRandomness2 + randomness2);
        
        // Final input for transfer proof using the exact format the circuit expects
        const input = {
            private_key: privateKey.toString(),
            randomness1: randomness1.toString(),
            randomness2: randomness2.toString(),
            value: transferValue.toString(),
            balance_old_me_clear: senderOldBalanceClear.toString(),
            public_key_me: {
                x: senderPublicKey.x.toString(),
                y: senderPublicKey.y.toString()
            },
            public_key_to: {
                x: recipientPublicKey.x.toString(),
                y: recipientPublicKey.y.toString()
            },
            balance_old_me_encrypted_1: {
                x: senderOldEncryptedBalance.C1.x.toString(),
                y: senderOldEncryptedBalance.C1.y.toString()
            },
            balance_old_me_encrypted_2: {
                x: senderOldEncryptedBalance.C2.x.toString(),
                y: senderOldEncryptedBalance.C2.y.toString()
            },
            balance_old_to_encrypted_1: {
                x: recipientOldEncryptedBalance.C1.x.toString(),
                y: recipientOldEncryptedBalance.C1.y.toString()
            },
            balance_old_to_encrypted_2: {
                x: recipientOldEncryptedBalance.C2.x.toString(),
                y: recipientOldEncryptedBalance.C2.y.toString()
            },
            balance_new_me_encrypted_1: {
                x: senderNewEncryptedBalance.C1.x.toString(),
                y: senderNewEncryptedBalance.C1.y.toString()
            },
            balance_new_me_encrypted_2: {
                x: senderNewEncryptedBalance.C2.x.toString(),
                y: senderNewEncryptedBalance.C2.y.toString()
            },
            balance_new_to_encrypted_1: {
                x: recipientNewEncryptedBalance.C1.x.toString(),
                y: recipientNewEncryptedBalance.C1.y.toString()
            },
            balance_new_to_encrypted_2: {
                x: recipientNewEncryptedBalance.C2.x.toString(),
                y: recipientNewEncryptedBalance.C2.y.toString()
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
    console.log("Public Inputs:", data.publicInputs);
    // proof to hex
    console.log("Proof:", Buffer.from(data.proof).toString('hex'));
    process.exit(0);
}); 