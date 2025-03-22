// Note: Exponential ElGamal only supports plaintexts constrained to 40 bits, because solving the Discrete Log is needed during decryption
// It is the responsiblity of the smart contract developer to ensure that all plaintexts are in the u40 range before encryption

use dep::ec::tecurve::affine::Point;
use elgamal;

// Code of the circuit used once at construction of the token to prove the correctness of encryption of the minted total supply.
// In this particular case, we are using a zkSNARK only for its succintness property, not the zk property, because total supply is publicly known.
// The alternative would have been to reimplement Baby JubJub encryption in the EVM onchain which is very gas-expensive and complex.
fn main(
    private_key: Field,
    randomness: Field,
    public_key: pub Point,
    value: pub Field,
    C1: pub Point,
    C2: pub Point,
) {
    let computed_public_key = elgamal::bjj_priv_to_pub_key(private_key);
    assert((public_key.x == computed_public_key.x) & (public_key.y == computed_public_key.y));
    let ciphertext: (Point, Point) =
        elgamal::bjj_exp_elgamal_encrypt(public_key, value, randomness);
    assert(
        (ciphertext.0.x == C1.x)
            & (ciphertext.0.y == C1.y)
            & (ciphertext.1.x == C2.x)
            & (ciphertext.1.y == C2.y),
    );
}

#[test]
fn test_main() {
    // private values
    let private_key: Field =
        2291123624948246627368989940774052753470489062495018070576418670157516550852;
    let randomness: Field =
        168986485046885582825082387270879151100288537211746581237924789162159767775;

    // public values
    let public_key: Point = elgamal::bjj_priv_to_pub_key(private_key);
    let value: Field = 1000000000000; // the message being encrypted, should be a u40
    let (C1, C2) = elgamal::bjj_exp_elgamal_encrypt(public_key, value, randomness);

    main(private_key, randomness, public_key, value, C1, C2);
}