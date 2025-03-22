// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NoirHelper} from "foundry-noir-helper/NoirHelper.sol";

import {UltraVerifier as MintUltraVerifier} from "../src/verifiers/mintUltraVerifier.sol";
import {UltraVerifier as TransferUltraVerifier} from "../src/verifiers/transferUltraVerifier.sol";
import {UltraVerifier as TransferToNewUltraVerifier} from "../src/verifiers/transfer_to_newUltraVerifier.sol";

import {ElToken} from "../src/ElToken.sol";
import {PublicKeyInfrastructure} from "../src/PublicKeyInfrastructure.sol";
import {WETH} from "solmate/tokens/WETH.sol";

contract UltraVerifierTest is Test {
    NoirHelper public noirHelper;

    MintUltraVerifier public MINT_VERIFIER;
    TransferUltraVerifier public TRANSFER_VERIFIER;
    TransferToNewUltraVerifier public TRANSFER_TO_NEW_VERIFIER;
    PublicKeyInfrastructure public PKI;
    ElToken public elToken;
    WETH public weth;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() public {
        noirHelper = new NoirHelper();

        weth = new WETH();

        PKI = new PublicKeyInfrastructure();
        MINT_VERIFIER = new MintUltraVerifier();
        TRANSFER_VERIFIER = new TransferUltraVerifier();
        TRANSFER_TO_NEW_VERIFIER = new TransferToNewUltraVerifier();
        elToken = new ElToken(address(weth));

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

    function test_transfer_to_new() public {
        test_mint();

        // Encrypted ciphertext data
        uint256 C1_x = 1496197583352242063455862221527010906604817232528901172130809043230997246824;
        uint256 C1_y = 4254363608840175473367393558422388112815775052382181131620648571022664794991;
        uint256 C2_x = 20465501074627735547581698300835043318363179866890168887292719178623513167299;
        uint256 C2_y = 12927228287522866177755582722853391527403617932038524316984546244666235976478;

        (uint256 bobbalanceC1x, uint256 bobbalanceC1y, uint256 bobbalanceC2x, uint256 bobbalanceC2y) =
            elToken.balances(bob);

        assertEq(bobbalanceC1x, C1_x);
        assertEq(bobbalanceC1y, C1_y);
        assertEq(bobbalanceC2x, C2_x);
        assertEq(bobbalanceC2y, C2_y);

        // at this point bob has 1_0000 tokens that equivalent to 1 ether WETH
        vm.startPrank(bob);

        // Create encrypted balance objects with the public inputs
        ElToken.EncryptedBalance memory encryptedBalanceOldMe =
            ElToken.EncryptedBalance({C1x: bobbalanceC1x, C1y: bobbalanceC1y, C2x: bobbalanceC2x, C2y: bobbalanceC2y});

        // For a new receiver like Alice, the old balance would be zeros
        ElToken.EncryptedBalance memory encryptedBalanceOldTo =
            ElToken.EncryptedBalance({C1x: 0, C1y: 0, C2x: 0, C2y: 0});

        // New balance for Bob after transfer
        ElToken.EncryptedBalance memory encryptedBalanceNewMe = ElToken.EncryptedBalance({
            C1x: 1496197583352242063455862221527010906604817232528901172130809043230997246824,
            C1y: 4254363608840175473367393558422388112815775052382181131620648571022664794991,
            C2x: 7132239081249683658423301873709487886527317837638472026039930231927727767690,
            C2y: 20712645620037612149496468163608886190807435151767794218410876452886668026838
        });

        // New balance for Alice after transfer
        ElToken.EncryptedBalance memory encryptedBalanceNewTo = ElToken.EncryptedBalance({
            C1x: 5101368220729117265340845140402972511220167236309017717230892476800594300849,
            C1y: 9464551464843298006890812707339307347419442508224586622078302003473992946248,
            C2x: 12569109508198965523215984731209646522185734359542096304413601810871781846681,
            C2y: 13208904001440149853051089636207920553482181951125970640265081452010859970019
        });

        // Load the proof from file
        string memory proofJson = vm.readFile("./test/proof_transfer_to_new.bytes");
        bytes memory proof_transfer_new = vm.parseBytes(proofJson);

        vm.expectRevert("RECEIVER_NOT_REGISTERED");
        elToken.transferPrivate(
            alice,
            encryptedBalanceOldMe,
            encryptedBalanceOldTo,
            encryptedBalanceNewMe,
            encryptedBalanceNewTo,
            proof_transfer_new
        );

        vm.stopPrank();

        // Register a key for Alice
        vm.startPrank(alice);

        uint256 publicKeyX = 4634264854040818138625745019270360081367026367183099861136305383680538427056;
        uint256 publicKeyY = 15673152810959729295350484662231526942827385252225094571441698124202132264222;
        PKI.registerPublicKey(publicKeyX, publicKeyY);
        vm.stopPrank();

        console.log("bob balance C1x", bobbalanceC1x);
        console.log("bob balance C1y", bobbalanceC1y);
        console.log("bob balance C2x", bobbalanceC2x);
        console.log("bob balance C2y", bobbalanceC2y);

        vm.startPrank(bob);
        elToken.transferPrivate(
            alice,
            encryptedBalanceOldMe,
            encryptedBalanceOldTo,
            encryptedBalanceNewMe,
            encryptedBalanceNewTo,
            proof_transfer_new
        );
        vm.stopPrank();

        (uint256 alicebalanceC1x, uint256 alicebalanceC1y, uint256 alicebalanceC2x, uint256 alicebalanceC2y) =
            elToken.balances(alice);
        console.log("alice balance C1x", alicebalanceC1x);
        console.log("alice balance C1y", alicebalanceC1y);
        console.log("alice balance C2x", alicebalanceC2x);
        console.log("alice balance C2y", alicebalanceC2y);

        (bobbalanceC1x, bobbalanceC1y, bobbalanceC2x, bobbalanceC2y) = elToken.balances(bob);
        console.log("bob balance C1x", bobbalanceC1x);
        console.log("bob balance C1y", bobbalanceC1y);
        console.log("bob balance C2x", bobbalanceC2x);
        console.log("bob balance C2y", bobbalanceC2y);
    }

    function test_transfer_to_existing_user() public {
        test_transfer_to_new();

        ElToken.EncryptedBalance memory encryptedBalanceOldMe = ElToken.EncryptedBalance({
            C1x: 11017998082309010223062454201157773337951899306065725147149719209748915162513,
            C1y: 891184252204890740833160122406506380957356897324023910513221381207852952589,
            C2x: 9541124900713504821396342874206529589527528863334370665187472286364951857063,
            C2y: 3950810041948905034521793696410783215603076883603177458127776409646563297950
        });

        ElToken.EncryptedBalance memory encryptedBalanceOldTo = ElToken.EncryptedBalance({
            C1x: 5071608101324055067557638680091755256823694404140603233907036803540380918255,
            C1y: 18092433154514174944101765178562257647161151065090166335434817774976138779799,
            C2x: 3384603700985393270728476214200017209830506917412762072822812880616293558275,
            C2y: 12151053141889194321800315012428500927897782619812437478800137918243792930702
        });

        ElToken.EncryptedBalance memory encryptedBalanceNewMe = ElToken.EncryptedBalance({
            C1x: 1496197583352242063455862221527010906604817232528901172130809043230997246824,
            C1y: 4254363608840175473367393558422388112815775052382181131620648571022664794991,
            C2x: 15435893553017563670825946226470291258046904768484187444995481737410622369973,
            C2y: 2621394540762208794510986319327807863751637280839895884120727567166538222091
        });

        ElToken.EncryptedBalance memory encryptedBalanceNewTo = ElToken.EncryptedBalance({
            C1x: 12316946172442669334459682536759703104955873651712662817559042780828455956907,
            C1y: 8855209734781576767922463747623028875751643647015986898096811877259979051834,
            C2x: 15911962846252204227709649507354161850931087939521847621900173374056333964890,
            C2y: 18130962328042523240002549970864798664836422526373042073906528674660374500136
        });

        // Load the proof from file
        string memory proofJson = vm.readFile("./test/proof_transfer.bytes");
        bytes memory proof_transfer = vm.parseBytes(proofJson);

        vm.startPrank(bob);
        elToken.transferPrivate(
            alice,
            encryptedBalanceOldMe,
            encryptedBalanceOldTo,
            encryptedBalanceNewMe,
            encryptedBalanceNewTo,
            proof_transfer
        );
        vm.stopPrank();
    }
}
