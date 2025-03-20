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
    let bjj_affine: Curve = Curve::new(bjj_a, bjj_d, Point::new(bjj_generator_x, bjj_generator_y));
    let base_pt: Point = Point::new(bjj_basept_x, bjj_basept_y);
    let C1: Point = bjj_affine.mul(randomness, base_pt);
    let plain_embedded: Point = bjj_affine.mul(plaintext as Field, base_pt);
    let shared_secret: Point = bjj_affine.mul(randomness, public_key);
    let C2: Point = bjj_affine.add(shared_secret, plain_embedded);
    (C1, C2)
}
