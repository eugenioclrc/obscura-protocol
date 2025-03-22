pragma solidity ^0.8.17;

import {ElToken} from "./ElToken.sol";
import {IVerifier} from "./IVerifier.sol";
import {PublicKeyInfrastructure} from "./PublicKeyInfrastructure.sol";

contract ElTokenFactory {
    mapping(address => address) public tokens;

    PublicKeyInfrastructure public immutable PKI;
    IVerifier public immutable MINT_VERIFIER;
    IVerifier public immutable TRANSFER_VERIFIER;
    IVerifier public immutable TRANSFER_TO_NEW_VERIFIER;

    constructor(address _mint_verifier, address _transfer_verifier, address _transfer_to_new_verifier, address _pki) {
        MINT_VERIFIER = IVerifier(_mint_verifier);
        TRANSFER_VERIFIER = IVerifier(_transfer_verifier);
        TRANSFER_TO_NEW_VERIFIER = IVerifier(_transfer_to_new_verifier);
        PKI = PublicKeyInfrastructure(_pki);
    }

    function createToken(address underlyingToken) external returns (address) {
        ElToken token = new ElToken(underlyingToken);
        tokens[underlyingToken] = address(token);
        return address(token);
    }
}
