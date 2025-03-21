pragma solidity ^0.8.17;

import {IVerifier} from "./IVerifier.sol";

contract Starter {
    IVerifier public verifier;

    constructor(address _verifier) {
        verifier = IVerifier(_verifier);
    }

    function verifyEqual(bytes calldata proof, bytes32[] calldata y) public view returns (bool) {
        bool proofResult = verifier.verify(proof, y);
        require(proofResult, "Proof is not valid");
        return proofResult;
    }
}
