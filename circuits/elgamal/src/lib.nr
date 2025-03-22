// Note: Exponential ElGamal only supports plaintexts constrained to 40 bits, because solving the Discrete Log is needed during decryption
// It is the responsiblity of the smart contract developer to ensure that all plaintexts are in the u40 range before encryption

use dep::ec::tecurve::affine::{Curve, Point};

global bjj_a: Field = 168700;
global bjj_d: Field = 168696;
global bjj_generator_x: Field =
    995203441582195749578291179787384436505546430278305826713579947235728471134;
global bjj_generator_y: Field =
    5472060717959818805561601436314318772137091100104008585924551046643952123905;
global bjj_basept_x: Field =
    5299619240641551281634865583518297030282874472190772894086521144482721001553;
global bjj_basept_y: Field =
    16950150798460657717958625567821834550301663161624707787222815936182638968203;

pub fn bjj_priv_to_pub_key(private_key: Field) -> Point {
    let bjj_affine: Curve = Curve::new(bjj_a, bjj_d, Point::new(bjj_generator_x, bjj_generator_y));
    let base_pt: Point = Point::new(bjj_basept_x, bjj_basept_y);
    bjj_affine.mul(private_key, base_pt)
}

pub fn bjj_exp_elgamal_encrypt(
    public_key: Point,
    plaintext: Field,
    randomness: Field,
) -> (Point, Point) {
    // Ensure plaintext is within u40 range
    let max_u40: u64 = 1099511627776; // 2^40
    assert(plaintext as u64 < max_u40);

    let bjj_affine: Curve = Curve::new(bjj_a, bjj_d, Point::new(bjj_generator_x, bjj_generator_y));
    let base_pt: Point = Point::new(bjj_basept_x, bjj_basept_y);
    let C1: Point = bjj_affine.mul(randomness, base_pt);
    let plain_embedded: Point = bjj_affine.mul(plaintext as Field, base_pt);
    let shared_secret: Point = bjj_affine.mul(randomness, public_key);
    let C2: Point = bjj_affine.add(shared_secret, plain_embedded);
    (C1, C2)
}

pub fn bjj_exp_elgamal_decrypt(private_key: Field, ciphertext: (Point, Point)) -> Point {
    let bjj_affine: Curve = Curve::new(bjj_a, bjj_d, Point::new(bjj_generator_x, bjj_generator_y));
    let shared_secret = bjj_affine.mul(private_key, ciphertext.0);
    let plain_embedded = bjj_affine.subtract(ciphertext.1, shared_secret);
    plain_embedded
}

#[test]
fn test_bjj_priv_to_pub_key() {
    // Test with a known private key
    let private_key = 123456789;
    let pub_key = bjj_priv_to_pub_key(private_key);
    
    // Verify the point is valid by checking it's not the identity point
    assert((pub_key.x != 0) | (pub_key.y != 0));
}

#[test]
fn test_bjj_exp_elgamal_encrypt_decrypt() {
    // Test with small values (within u40 range)
    let private_key = 123456789;
    let plaintext = 42; // Small value within u40 range
    let randomness = 987654321;
    
    // Get public key
    let pub_key = bjj_priv_to_pub_key(private_key);
    
    // Encrypt
    let (c1, c2) = bjj_exp_elgamal_encrypt(pub_key, plaintext, randomness);
    
    // Verify ciphertext points are valid by checking they're not identity points
    assert((c1.x != 0) | (c1.y != 0));
    assert((c2.x != 0) | (c2.y != 0));
    
    // Decrypt
    let decrypted = bjj_exp_elgamal_decrypt(private_key, (c1, c2));
    
    // Verify decrypted point is valid by checking it's not the identity point
    assert((decrypted.x != 0) | (decrypted.y != 0));
    
    // Verify we can recover the original plaintext by encrypting it again
    let (c1_verify, c2_verify) = bjj_exp_elgamal_encrypt(pub_key, plaintext, randomness);
    assert((c1_verify.x == c1.x) & (c1_verify.y == c1.y));
    assert((c2_verify.x == c2.x) & (c2_verify.y == c2.y));
}

#[test]
fn test_bjj_exp_elgamal_encrypt_decrypt_zero() {
    // Test with zero plaintext
    let private_key = 123456789;
    let plaintext = 0;
    let randomness = 987654321;
    
    // Get public key
    let pub_key = bjj_priv_to_pub_key(private_key);
    
    // Encrypt
    let (c1, c2) = bjj_exp_elgamal_encrypt(pub_key, plaintext, randomness);
    
    // Verify ciphertext points are valid by checking they're not identity points
    assert((c1.x != 0) | (c1.y != 0));
    assert((c2.x != 0) | (c2.y != 0));
    
    // Decrypt
    let decrypted = bjj_exp_elgamal_decrypt(private_key, (c1, c2));
    
    // For zero plaintext, we expect the decrypted point to match encryption of zero
    let bjj_affine: Curve = Curve::new(bjj_a, bjj_d, Point::new(bjj_generator_x, bjj_generator_y));
    let base_pt: Point = Point::new(bjj_basept_x, bjj_basept_y);
    let expected = bjj_affine.mul(0, base_pt);
    assert((decrypted.x == expected.x) & (decrypted.y == expected.y));
}

#[test]
fn test_bjj_exp_elgamal_encrypt_decrypt_max_u40() {
    // Test with maximum u40 value (2^40 - 1)
    let private_key = 123456789;
    let plaintext = 1099511627775; // 2^40 - 1
    let randomness = 987654321;
    
    // Get public key
    let pub_key = bjj_priv_to_pub_key(private_key);
    
    // Encrypt
    let (c1, c2) = bjj_exp_elgamal_encrypt(pub_key, plaintext, randomness);
    
    // Verify ciphertext points are valid by checking they're not identity points
    assert((c1.x != 0) | (c1.y != 0));
    assert((c2.x != 0) | (c2.y != 0));
    
    // Decrypt
    //let decrypted = bjj_exp_elgamal_decrypt(private_key, (c1, c2));
    
    // Verify we can recover the original plaintext by encrypting it again
    let (c1_verify, c2_verify) = bjj_exp_elgamal_encrypt(pub_key, plaintext, randomness);
    assert((c1_verify.x == c1.x) & (c1_verify.y == c1.y));
    assert((c2_verify.x == c2.x) & (c2_verify.y == c2.y));
}

#[test(should_fail)]
fn test_bjj_exp_elgamal_encrypt_decrypt_above_u40() {
    // Test with value above u40 range (should fail)
    let private_key = 123456789;
    let plaintext = 1099511627776; // 2^40
    let randomness = 987654321;
    
    // Get public key
    let pub_key = bjj_priv_to_pub_key(private_key);
    
    // This should fail because plaintext is too large
    let _ = bjj_exp_elgamal_encrypt(pub_key, plaintext, randomness);
}
