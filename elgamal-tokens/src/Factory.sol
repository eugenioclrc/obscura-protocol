pragma solidity ^0.8.17;

import {ElToken} from "./ElToken.sol";
import {IVerifier} from "./IVerifier.sol";
import {PublicKeyInfrastructure} from "./PublicKeyInfrastructure.sol";

contract ElTokenFactory {
    mapping(address => address) public tokens;

    IVerifier public immutable MINT_VERIFIER;
    PublicKeyInfrastructure public immutable PKI;
    
    constructor(address _mint_verifier, address _pki) {
        MINT_VERIFIER = IVerifier(_mint_verifier);
        PKI = PublicKeyInfrastructure(_pki);
    }

    function createToken(address underlyingToken) external returns (address) {
        ElToken token = new ElToken(underlyingToken);
        tokens[underlyingToken] = address(token);
        return address(token);
    }
}
