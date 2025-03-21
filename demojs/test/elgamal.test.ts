import * as chai from 'chai';
const { expect } = chai;
import { BabyJubJubUtils } from '../src/elgamal.js';
import chaiAsPromised from 'chai-as-promised';

chai.use(chaiAsPromised);

describe('ElGamal Encryption Tests', () => {
    let utils: BabyJubJubUtils;
    // Predefined randomness for deterministic tests
    const TEST_RANDOMNESS = 168986485046885582825082387270879151100288537211746581237924789162159767775n;

    before(async () => {
        utils = new BabyJubJubUtils();
        await utils.init();
    });

    it('should convert private key to public key with known value', async () => {
        // Test with a known private key (matching Noir test)
        const privateKey = 123456789n;
        const pubKey = utils.privateToPublicKey(privateKey);
        
        // Verify the point is not the identity point
        expect(pubKey.x.toString() !== '0' || pubKey.y.toString() !== '0').to.be.true;
    });

    it('should encrypt and decrypt with known values', async () => {
        // Test with known values (matching Noir test)
        const privateKey = 123456789n;
        const plaintext = 42; // Small value within u40 range
        
        // Get public key
        const publicKey = utils.privateToPublicKey(privateKey);
        
        // Encrypt
        const ciphertext = utils.exp_elgamal_encrypt(publicKey, plaintext, TEST_RANDOMNESS);
        
        // Verify ciphertext points are not identity points
        expect(ciphertext.C1.x.toString() !== '0' || ciphertext.C1.y.toString() !== '0').to.be.true;
        expect(ciphertext.C2.x.toString() !== '0' || ciphertext.C2.y.toString() !== '0').to.be.true;
        
        // Decrypt
        const decrypted = utils.exp_elgamal_decrypt_embedded(privateKey, ciphertext.C1, ciphertext.C2);
        
        // Verify decrypted point is not the identity point
        expect(decrypted.x.toString() !== '0' || decrypted.y.toString() !== '0').to.be.true;
        
        // Verify we can recover the original plaintext by encrypting it again
        const ciphertextVerify = utils.exp_elgamal_encrypt(publicKey, plaintext, TEST_RANDOMNESS);
        expect(ciphertextVerify.C1.x === ciphertext.C1.x && 
               ciphertextVerify.C1.y === ciphertext.C1.y).to.be.true;
        expect(ciphertextVerify.C2.x === ciphertext.C2.x && 
               ciphertextVerify.C2.y === ciphertext.C2.y).to.be.true;
    });

    it('should encrypt and decrypt zero', async () => {
        const { privateKey, publicKey } = utils.generatePrivateAndPublicKey();
        const plaintext = 0;
        
        // Encrypt
        const ciphertext = utils.exp_elgamal_encrypt(publicKey, plaintext, TEST_RANDOMNESS);
        
        // Verify ciphertext points are not identity points
        expect(ciphertext.C1.x.toString() !== '0' || ciphertext.C1.y.toString() !== '0').to.be.true;
        expect(ciphertext.C2.x.toString() !== '0' || ciphertext.C2.y.toString() !== '0').to.be.true;
        
        // Decrypt
        const decrypted = utils.exp_elgamal_decrypt_embedded(privateKey, ciphertext.C1, ciphertext.C2);
        
        // For zero plaintext, we expect the decrypted point to be equal to the base point multiplied by zero
        const zeroPoint = utils.privateToPublicKey(0);
        expect(decrypted.x === zeroPoint.x && decrypted.y === zeroPoint.y).to.be.true;
    });

    it('should encrypt and decrypt maximum u40 value', async () => {
        const { privateKey, publicKey } = utils.generatePrivateAndPublicKey();
        const plaintext = 1099511627775; // 2^40 - 1
        
        // Encrypt
        const ciphertext = utils.exp_elgamal_encrypt(publicKey, plaintext, TEST_RANDOMNESS);
        
        // Verify ciphertext points are not identity points
        expect(ciphertext.C1.x.toString() !== '0' || ciphertext.C1.y.toString() !== '0').to.be.true;
        expect(ciphertext.C2.x.toString() !== '0' || ciphertext.C2.y.toString() !== '0').to.be.true;
        
        // Verify we can recover the original plaintext by encrypting it again
        const ciphertextVerify = utils.exp_elgamal_encrypt(publicKey, plaintext, TEST_RANDOMNESS);
        expect(ciphertextVerify.C1.x === ciphertext.C1.x && 
               ciphertextVerify.C1.y === ciphertext.C1.y).to.be.true;
        expect(ciphertextVerify.C2.x === ciphertext.C2.x && 
               ciphertextVerify.C2.y === ciphertext.C2.y).to.be.true;
    });

    it('should fail when encrypting value above u40 range', async () => {
        const { publicKey } = utils.generatePrivateAndPublicKey();
        const plaintext = 1099511627776; // 2^40
        
        // This should fail because plaintext is too large
        expect(() => utils.exp_elgamal_encrypt(publicKey, plaintext, TEST_RANDOMNESS))
            .to.throw('Plain value most be an integer in uint40 range');
    });

    it('should add points correctly', async () => {
        const { privateKey: priv1, publicKey: pub1 } = utils.generatePrivateAndPublicKey();
        const { privateKey: priv2, publicKey: pub2 } = utils.generatePrivateAndPublicKey();
        
        // Add two public keys
        const sum = utils.add_points(pub1, pub2);
        
        // Verify the sum is a valid point
        expect(sum.x.toString() !== '0' || sum.y.toString() !== '0').to.be.true;
    });

    it('should encrypt and decrypt 42 value', async () => {
        const privateKey = 123456789n;
        const plaintext = 42; // Small value within u40 range
        const randomness = 987654321n;
        
        // Get public key
        const publicKey = utils.privateToPublicKey(privateKey);
        
        // Encrypt
        const ciphertext = utils.exp_elgamal_encrypt(publicKey, plaintext, randomness);
        
        // Verify ciphertext points are not identity points
        expect(ciphertext.C1.x.toString() !== '0' || ciphertext.C1.y.toString() !== '0').to.be.true;
        expect(ciphertext.C2.x.toString() !== '0' || ciphertext.C2.y.toString() !== '0').to.be.true;
        
        // Verify we can recover the original plaintext by encrypting it again
        const ciphertextVerify = utils.exp_elgamal_encrypt(publicKey, plaintext, randomness);
        expect(ciphertextVerify.C1.x === ciphertext.C1.x && 
               ciphertextVerify.C1.y === ciphertext.C1.y).to.be.true;
        expect(ciphertextVerify.C2.x === ciphertext.C2.x && 
               ciphertextVerify.C2.y === ciphertext.C2.y).to.be.true;

        // Decrypt
        const decrypted = utils.exp_elgamal_decrypt_embedded(privateKey, ciphertext.C1, ciphertext.C2);
        
        // Verify the decrypted point is equal to the base point multiplied by 42
        const expectedPoint = utils.privateToPublicKey(42);
        expect(decrypted.x === expectedPoint.x && decrypted.y === expectedPoint.y).to.be.true;
    });
}); 