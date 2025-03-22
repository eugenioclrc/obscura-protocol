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
        mint_verifier = new MintUltraVerifier();
        elToken = new ElToken(address(weth), address(pki), address(mint_verifier));

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

    function test_basicDeposit() public {
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

    function test_mint() public {
        uint256 privateKey = 363392786237362068767139959337036002311688465567650996034788007646727742377;
        uint256 publicKeyX = 11399805767625558235203971404651168062138053844057929237231029823545978690429;
        uint256 publicKeyY = 16107672938816583933731171731418032574757815549503661527457618583376341575199;
        uint256 randomness = 168986485046885582825082387270879151100288537211746581237924789162159767775;

        vm.startPrank(bob);
        pki.registerPublicKey(publicKeyX, publicKeyY);
        elToken.deposit(1 ether);
        
        // Encrypted ciphertext data
        uint256 C1_x = 1496197583352242063455862221527010906604817232528901172130809043230997246824;
        uint256 C1_y = 4254363608840175473367393558422388112815775052382181131620648571022664794991;
        uint256 C2_x = 547569482198353691335551042438602887242720055887692148619786977945462377382;
        uint256 C2_y = 19058709733707387429852348723195847206775195997862985934749463164317886511126;
        
        // Get pending mint amount
        uint256 mintAmount = elToken.mintPending(bob);
        
        // Setup Noir proof generation
        noirHelper = noirHelper.withProjectPath("./circuits/mint");
        noirHelper.clean();
        
        // Create inputs for the proof - using string representations to avoid TOML parsing issues
        
        /* not working
        noirHelper.withInput("private_key", vm.toString(privateKey))
            .withInput("randomness", vm.toString(randomness))
            .withInput("public_key_x", vm.toString(publicKeyX))
            .withInput("public_key_y", vm.toString(publicKeyY))
            .withInput("value", vm.toString(mintAmount))
            .withInput("C1_x", vm.toString(C1_x))
            .withInput("C1_y", vm.toString(C1_y))
            .withInput("C2_x", vm.toString(C2_x))
            .withInput("C2_y", vm.toString(C2_y));
            */
        
        // Generate the proof - using public inputs (public key x/y and ciphertext points)
        //(bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_mint", 7);
        // @todo use proof from file proof_mint.json
        /*
        and this public input:
        ```
        {
            "private_key": "363392786237362068767139959337036002311688465567650996034788007646727742377",
            "randomness": "168986485046885582825082387270879151100288537211746581237924789162159767775",
            "public_key": {
                "x": "11399805767625558235203971404651168062138053844057929237231029823545978690429",
                "y": "16107672938816583933731171731418032574757815549503661527457618583376341575199"
            },
            "value": 10000,
            "C1": {
                "x": "1496197583352242063455862221527010906604817232528901172130809043230997246824",
                "y": "4254363608840175473367393558422388112815775052382181131620648571022664794991"
            },
            "C2": {
                "x": "547569482198353691335551042438602887242720055887692148619786977945462377382",
                "y": "19058709733707387429852348723195847206775195997862985934749463164317886511126"
            }
        }
        ```
        */
        
        ElToken.EncryptedBalance memory encryptedBalance = ElToken.EncryptedBalance({
            C1x: C1_x,
            C1y: C1_y,
            C2x: C2_x,
            C2y: C2_y
        });

        // Load the proof from file
        string memory proofJson = vm.readFile("./test/proof_mint.bytes");
        bytes memory proof = vm.parseBytes(proofJson);
        
        // Alternatively, generate the proof using NoirHelper (uncomment if needed)
        /*
        noirHelper.withInput("private_key", vm.toString(privateKey))
            .withInput("randomness", vm.toString(randomness))
            .withInput("public_key", string.concat('{"x":', vm.toString(publicKeyX), ',"y":', vm.toString(publicKeyY), '}'))
            .withInput("value", vm.toString(mintAmount))
            .withInput("C1", string.concat('{"x":', vm.toString(C1_x), ',"y":', vm.toString(C1_y), '}'))
            .withInput("C2", string.concat('{"x":', vm.toString(C2_x), ',"y":', vm.toString(C2_y), '}'));
        
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_mint", 7);
        */

        // Execute mint with the proof
        elToken.mint(proof, encryptedBalance);
        
        // Assert the mint was successful
        assertEq(elToken.mintPending(bob), 0);
        //assertEq(elToken.balanceOf(bob), mintAmount);
        
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

