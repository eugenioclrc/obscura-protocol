// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NoirHelper} from "foundry-noir-helper/NoirHelper.sol";

import {UltraVerifier as HelloWorldVerifer} from "../src/verifiers/helloworldUltraVerifier.sol";
import {Starter} from "../src/Starter.sol";

contract UltraVerifierTest is Test {
    NoirHelper public noirHelper = new NoirHelper();

    HelloWorldVerifer public verifier;
    Starter public starter;

    function setUp() public {
        verifier = new HelloWorldVerifer();
        starter = new Starter(address(verifier));
    }

    function test_verifyProof() public {
        noirHelper = noirHelper.withProjectPath("./circuits/helloworld");
        noirHelper.withInput("x", 1).withInput("y", 1).withInput("return", 1);
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_verifyProof", 2);
        console.logBytes32(publicInputs[0]);
        starter.verifyEqual(proof, publicInputs);
    }

    /*
    function test_wrongProof() public {
        noirHelper = noirHelper.withProjectPath("./circuits/hello");
        noirHelper.clean();
        noirHelper.withInput("x", 1).withInput("y", 5).withInput("return", 5);
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_wrongProof", 2);
        vm.expectRevert();
        starter.verifyEqual(proof, publicInputs);
    }
        */
}

contract HelloworldTest is Test {
    function setUp() public {}

    function test_Increment() public {}
}
