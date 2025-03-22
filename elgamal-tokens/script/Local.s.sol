// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {NoirHelper} from "foundry-noir-helper/NoirHelper.sol";

import {UltraVerifier as MintUltraVerifier} from "../src/verifiers/mintUltraVerifier.sol";
import {UltraVerifier as TransferUltraVerifier} from "../src/verifiers/transferUltraVerifier.sol";
import {UltraVerifier as TransferToNewUltraVerifier} from "../src/verifiers/transfer_to_newUltraVerifier.sol";
import {ElTokenFactory} from "../src/Factory.sol";
import {ElToken} from "../src/ElToken.sol";
import {PublicKeyInfrastructure} from "../src/PublicKeyInfrastructure.sol";
import {WETH} from "solmate/tokens/WETH.sol";

contract CounterScript is Script {
    MintUltraVerifier public MINT_VERIFIER;
    TransferUltraVerifier public TRANSFER_VERIFIER;
    TransferToNewUltraVerifier public TRANSFER_TO_NEW_VERIFIER;
    PublicKeyInfrastructure public PKI;
    ElToken public elToken;
    WETH public weth;
    ElTokenFactory public factory;

    address user = address(0xbeef);

    function setUp() public {}

    function run() public returns(address _weth, address _factory) {
        vm.startBroadcast();
    
        weth = new WETH();

        PKI = new PublicKeyInfrastructure();
        MINT_VERIFIER = new MintUltraVerifier();
        TRANSFER_VERIFIER = new TransferUltraVerifier();
        TRANSFER_TO_NEW_VERIFIER = new TransferToNewUltraVerifier();
        
        
        factory = new ElTokenFactory(address(MINT_VERIFIER), address(TRANSFER_VERIFIER), address(TRANSFER_TO_NEW_VERIFIER), address(PKI));

        user.call{value:10 ether}("");
        _weth = address(weth);
        _factory = address(factory);

        vm.stopBroadcast();
    }
}
