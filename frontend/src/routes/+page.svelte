<script>
import { UltraHonkBackend } from '@aztec/bb.js';
import { Noir } from '@noir-lang/noir_js';

import {getCircuit} from '$lib/circuits';

import {onMount} from 'svelte';

onMount(async () => {
    try {
        console.log("Getting circuit...");
        const { program } = await getCircuit();
        console.log("Circuit loaded successfully");
        const noir = new Noir(program);
        const backend = new UltraHonkBackend(program.bytecode);

        // Create inputs for the proof - using string representations to avoid TOML parsing issues
        //uint256 privateKey = 363392786237362068767139959337036002311688465567650996034788007646727742377;
        //uint256 publicKeyX = 11399805767625558235203971404651168062138053844057929237231029823545978690429;
        //uint256 publicKeyY = 16107672938816583933731171731418032574757815549503661527457618583376341575199;
        //uint256 randomness = 168986485046885582825082387270879151100288537211746581237924789162159767775;
        
        // Encrypted ciphertext data
        //uint256 C1_x = 1496197583352242063455862221527010906604817232528901172130809043230997246824;
        //uint256 C1_y = 4254363608840175473367393558422388112815775052382181131620648571022664794991;
        //uint256 C2_x = 547569482198353691335551042438602887242720055887692148619786977945462377382;
        //uint256 C2_y = 19058709733707387429852348723195847206775195997862985934749463164317886511126;

        const proofInputs = {
            private_key: "363392786237362068767139959337036002311688465567650996034788007646727742377",
            randomness: "168986485046885582825082387270879151100288537211746581237924789162159767775",
            public_key: {
                x: "11399805767625558235203971404651168062138053844057929237231029823545978690429",
                y: "16107672938816583933731171731418032574757815549503661527457618583376341575199"
            },
            value: 10000,
            C1: {
                x: "1496197583352242063455862221527010906604817232528901172130809043230997246824",
                y: "4254363608840175473367393558422388112815775052382181131620648571022664794991"
            },
            C2: {
                x: "547569482198353691335551042438602887242720055887692148619786977945462377382",
                y: "19058709733707387429852348723195847206775195997862985934749463164317886511126"
            }
        };
        
        console.log("logs", "Generating witness... ⏳");
        const { witness } = await noir.execute(proofInputs);
        console.log("logs", "Generated witness... ✅");

        console.log("logs", "Generating proof... ⏳");
        const proof = await backend.generateProof(witness);
        console.log("logs", "Generated proof... ✅");
        console.log("results", proof.proof);
    } catch (error) {
        console.error("Error during circuit execution:", error);
    }
});
</script>

<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to read the documentation</p>
