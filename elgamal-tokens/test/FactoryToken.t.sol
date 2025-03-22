// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NoirHelper} from "foundry-noir-helper/NoirHelper.sol";

import {UltraVerifier as MintUltraVerifier} from "../src/verifiers/mintUltraVerifier.sol";
import {UltraVerifier as TransferUltraVerifier} from "../src/verifiers/transferUltraVerifier.sol";
import {UltraVerifier as TransferToNewUltraVerifier} from "../src/verifiers/transfer_to_newUltraVerifier.sol";
import {ElTokenFactory} from "../src/Factory.sol";
import {ElToken} from "../src/ElToken.sol";
import {PublicKeyInfrastructure} from "../src/PublicKeyInfrastructure.sol";
import {WETH} from "solmate/tokens/WETH.sol";

contract UltraVerifierTest is Test {

    MintUltraVerifier public MINT_VERIFIER;
    TransferUltraVerifier public TRANSFER_VERIFIER;
    TransferToNewUltraVerifier public TRANSFER_TO_NEW_VERIFIER;
    PublicKeyInfrastructure public PKI;
    ElToken public elToken;
    WETH public weth;
    ElTokenFactory public factory;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() public {
        weth = new WETH();

        PKI = new PublicKeyInfrastructure();
        MINT_VERIFIER = new MintUltraVerifier();
        TRANSFER_VERIFIER = new TransferUltraVerifier();
        TRANSFER_TO_NEW_VERIFIER = new TransferToNewUltraVerifier();
        
        
        factory = new ElTokenFactory(address(MINT_VERIFIER), address(TRANSFER_VERIFIER), address(TRANSFER_TO_NEW_VERIFIER), address(PKI));

        elToken = ElToken(factory.createToken(address(weth)));

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

        PKI.registerPublicKey(2, 2);

        vm.expectRevert();
        elToken.deposit(2 ether);

        vm.expectRevert("MIN_DEPOSIT_NOT_MET");
        elToken.deposit(4);

        elToken.deposit(0.123342342443240345 ether);
        assertEq(weth.balanceOf(bob), 1 ether - 0.1233 ether);
        assertEq(elToken.mintPending(bob), 0.1233 ether / 10 ** 14);
        vm.stopPrank();
    }

    function test_mint() public {
        //uint256 privateKey = 363392786237362068767139959337036002311688465567650996034788007646727742377;
        uint256 publicKeyX = 11035571757224451620605786890790132844722231619710976007063020523319248877914;
        uint256 publicKeyY = 19186343803061871491190042465391631772251521601054015091722300428018876653532;
        //uint256 randomness = 168986485046885582825082387270879151100288537211746581237924789162159767775;

        vm.startPrank(bob);
        PKI.registerPublicKey(publicKeyX, publicKeyY);
        elToken.deposit(1 ether);
        assertEq(elToken.mintPending(bob), 1 ether / 10 ** 14);

        // Encrypted ciphertext data
        uint256 C1_x = 1496197583352242063455862221527010906604817232528901172130809043230997246824;
        uint256 C1_y = 4254363608840175473367393558422388112815775052382181131620648571022664794991;
        uint256 C2_x = 20465501074627735547581698300835043318363179866890168887292719178623513167299;
        uint256 C2_y = 12927228287522866177755582722853391527403617932038524316984546244666235976478;

        // Setup Noir proof generation
        //noirHelper = noirHelper.withProjectPath("./circuits/mint");
        //noirHelper.clean();

        // Create inputs for the proof - using string representations to avoid TOML parsing issues

        ElToken.EncryptedBalance memory encryptedBalance =
            ElToken.EncryptedBalance({C1x: C1_x, C1y: C1_y, C2x: C2_x, C2y: C2_y});

        // Load the proof from file
        string memory proofJson = vm.readFile("./test/proof_mint.bytes");
        bytes memory proof = vm.parseBytes(proofJson);

        // Execute mint with the proof
        elToken.mint(proof, encryptedBalance);

        (uint256 bobbalanceC1x, uint256 bobbalanceC1y, uint256 bobbalanceC2x, uint256 bobbalanceC2y) =
            elToken.balances(bob);
        assertEq(bobbalanceC1x, C1_x);
        assertEq(bobbalanceC1y, C1_y);
        assertEq(bobbalanceC2x, C2_x);
        assertEq(bobbalanceC2y, C2_y);

        // Assert the mint was successful
        assertEq(elToken.mintPending(bob), 0);

        vm.stopPrank();
    }
}
