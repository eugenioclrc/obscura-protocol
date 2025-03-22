// Note: Exponential ElGamal only supports plaintexts constrained to 40 bits, because solving the Discrete Log is needed during decryption
// It is the responsiblity of the smart contract developer to ensure that all plaintexts are in the u40 range before encryption
use dep::ec::tecurve::affine::{Curve, Point};
use elgamal;


// Code of the circuit used at each transfer of the token to prove the validity of transfer (sender has enough balance) and correctness of encrypted new balances of sender and receiver.
// To be sure this is not vulnerable, we added a check in the smart contract to make sure that sender is different from receiver (a nonce variable is not needed in our case because transfers are initiated by from=msg.sender in the contract, so replay attack is impossible)
// Note : arguments of first line are all the private parameters, the second and third lines contain all the public parameters
fn main(private_key: Field, randomness1: Field, randomness2: Field, value: Field, balance_old_me_clear: Field, // balance_old_me_clear is the clear (i.e decrypted) balance of sender, this is computed offchain by solving the DLP with babygiant algorithm, after calling bjj_exp_elgamal_decrypt with his private key 
 public_key_me: pub Point, public_key_to: pub Point, balance_old_me_encrypted_1: pub Point, balance_old_me_encrypted_2: pub Point, balance_old_to_encrypted_1: pub Point, balance_old_to_encrypted_2: pub Point,
 balance_new_me_encrypted_1: pub Point, balance_new_me_encrypted_2: pub Point, balance_new_to_encrypted_1: pub Point, balance_new_to_encrypted_2: pub Point) { 
    let computed_public_key = elgamal::bjj_priv_to_pub_key(private_key);
    assert((public_key_me.x == computed_public_key.x) & (public_key_me.y == computed_public_key.y)); // check that the sender really owns the private key corresponding to his public key
    
    // Convert field elements to integers for comparison
    let value_u64 = value as u64;
    let balance_old_me_clear_u64 = balance_old_me_clear as u64;
    
    // Use comparison logic rather than operators
    assert(value_u64 <= balance_old_me_clear_u64); // the sender must have sufficient balance
    assert(value_u64 >= 1); // this is to deter potential front-running issue: ref https://crypto.stanford.edu/~buenz/papers/zether.pdf 3.1. Here we adopt a simpler approach than the multistep approach proposed in the Zether paper, for a better UX: an attacker who tries to DOS the sender should at least pay 1 token to either original sender or receiver. The "1" threshold could be changed to ensure correct economic incentives, typically this should be at least a multiple of the average gas price of a transfer transaction.
    // another more straightforward solution to front-running would be simply to do the homomorphic addition in the smart contract rather than the circuit, but this is too expensive today on Ethereum, according to the Zeestar paper III : https://files.sri.inf.ethz.ch/website/papers/sp22-zeestar.pdf
    
    // Use elgamal functions directly rather than trying to recreate Baby Jubjub curve parameters
    let embedded_balance_old_me_clear = elgamal::bjj_priv_to_pub_key(balance_old_me_clear);
    let decoded_value = elgamal::bjj_exp_elgamal_decrypt(private_key, (balance_old_me_encrypted_1, balance_old_me_encrypted_2));
    assert((decoded_value.x == embedded_balance_old_me_clear.x) & (decoded_value.y == embedded_balance_old_me_clear.y)); // check that unencrypted balance of sender really corresponds to his encrypted balance

    let balance_new_me_encrypted_computed = elgamal::bjj_exp_elgamal_encrypt(public_key_me, balance_old_me_clear - value, randomness1);
    assert((balance_new_me_encrypted_computed.0.x==balance_new_me_encrypted_1.x) & (balance_new_me_encrypted_computed.0.y==balance_new_me_encrypted_1.y) & (balance_new_me_encrypted_computed.1.x==balance_new_me_encrypted_2.x) & (balance_new_me_encrypted_computed.1.y==balance_new_me_encrypted_2.y)); // checks that the new encrypted balance of sender is correct
    
    let value_encrypted_to = elgamal::bjj_exp_elgamal_encrypt(public_key_to, value, randomness2);
    
    // Create a curve from the public keys in the parameters to perform point addition
    let curve = Curve::new(168700, 168696, public_key_me);  // Use the Baby Jubjub curve parameters directly
    
    let balance_new_to_encrypted_computed = (curve.add(balance_old_to_encrypted_1, value_encrypted_to.0), curve.add(balance_old_to_encrypted_2, value_encrypted_to.1)); // addition of the points on Baby Jubjub : this operation is additevely homomorphic for Exponential ElGamal
    assert((balance_new_to_encrypted_computed.0.x==balance_new_to_encrypted_1.x) & (balance_new_to_encrypted_computed.0.y==balance_new_to_encrypted_1.y) & (balance_new_to_encrypted_computed.1.x==balance_new_to_encrypted_2.x) & (balance_new_to_encrypted_computed.1.y==balance_new_to_encrypted_2.y)); // checks that the new encrypted balance of receiver is correct
}

// Because of a bug in Noir 10.3, this test will cause a stack overflow error, but you can check that it passes via `nargo prove` instead of `nargo test`: the values inside Prover.toml are strictly equivalent to this test
#[test]
fn test_main() {
    // private values
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852; // see debug notebook for an example on how to compute those
    let randomness1: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775; // see debug notebook for an example on how to compute those
    let randomness2: Field = 2512595847879910647549805200013822046432901960729162086417588755890198945115;
    let value: Field = 100;
    let balance_old_me_clear = 10000;

    // public values
    let public_key_me: Point = elgamal::bjj_priv_to_pub_key(private_key);
    let public_key_to: Point = elgamal::bjj_priv_to_pub_key(2397698694665525209403000085013646741088197704326090841842743616643093564368); // bjj_priv_to_pub_key(private_key_to)
    let balance_old_me_encrypted : (Point, Point) = elgamal::bjj_exp_elgamal_encrypt(public_key_me, balance_old_me_clear, 1223911427385630814994881905088740515414339792865684838215099796087690786721);
    let balance_old_to_encrypted : (Point, Point) = elgamal::bjj_exp_elgamal_encrypt(public_key_to, 42, 1391605116707840153256607813912547565986654451413670922768018807428594876790);
    let balance_new_me_encrypted : (Point, Point) = elgamal::bjj_exp_elgamal_encrypt(public_key_me, 9900, randomness1);
    let balance_new_to_encrypted : (Point, Point) = elgamal::bjj_exp_elgamal_encrypt(public_key_to, 142, 1391605116707840153256607813912547565986654451413670922768018807428594876790+randomness2);

    main(private_key, randomness1, randomness2, value, balance_old_me_clear, public_key_me, public_key_to, balance_old_me_encrypted.0, balance_old_me_encrypted.1, balance_old_to_encrypted.0,
     balance_old_to_encrypted.1, balance_new_me_encrypted.0, balance_new_me_encrypted.1, balance_new_to_encrypted.0,  balance_new_to_encrypted.1);
}
