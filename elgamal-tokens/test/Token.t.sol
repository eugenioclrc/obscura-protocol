// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NoirHelper} from "foundry-noir-helper/NoirHelper.sol";

import {UltraVerifier as MintUltraVerifier} from "../src/verifiers/mintUltraVerifier.sol";
import {ElToken} from "../src/ElToken.sol";
import {PublicKeyInfrastructure} from "../src/PublicKeyInfrastructure.sol";
import {WETH} from "solmate/tokens/WETH.sol";

contract UltraVerifierTest is Test {
    NoirHelper public noirHelper = new NoirHelper();

    MintUltraVerifier public mint_verifier;
    PublicKeyInfrastructure public pki = new PublicKeyInfrastructure();
    ElToken public elToken;
    WETH public weth = new WETH();

    address bob = makeAddr("bob");

    function setUp() public {
        elToken = new ElToken(address(weth), address(pki), address(mint_verifier));
        mint_verifier = new MintUltraVerifier();

        // Mint some tokens
        deal(bob, 1 ether);
        vm.startPrank(bob);
        weth.deposit{value: 1 ether}();
        weth.approve(address(elToken), type(uint256).max);
        vm.stopPrank();
    }

    function test_contants() public {
        assertEq(elToken.MIN_DEPOSIT(), 0.0001 ether);
        assertEq(elToken.PRECISION_DIFF(), 18 - 4);
    }

    function test_verifyProof() public {
        vm.startPrank(bob);

        vm.expectRevert("NOT_REGISTERED");
        elToken.deposit(1 ether);

        pki.registerPublicKey(2, 2);

        vm.expectRevert();
        elToken.deposit(2 ether);

        vm.expectRevert("MIN_DEPOSIT_NOT_MET");
        elToken.deposit(4);

        elToken.deposit(0.123342342443240345 ether);
        assertEq(weth.balanceOf(bob), 1 ether - 0.1233 ether);
        assertEq(elToken.mintPending(bob), 0.1233 ether / 10**14);
        vm.stopPrank();
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
