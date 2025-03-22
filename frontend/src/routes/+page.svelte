<script>
// Import and initialize polyfills first
import '$lib/polyfills';

// Set up Buffer globally if it's not already available (fallback)
if (typeof window !== 'undefined' && typeof window.Buffer === 'undefined') {
  // This is a last resort fallback if the Vite plugin fails
  console.warn('Buffer not defined by Vite plugin, using fallback');
  
  // Dynamically import buffer
  const bufferPromise = import('buffer');
  bufferPromise.then(({Buffer}) => {
    // @ts-expect-error - Adding Buffer to window
    window.Buffer = Buffer;
    console.log('Buffer polyfill loaded via fallback');
  }).catch(err => {
    console.error('Failed to load Buffer polyfill:', err);
  });
}

// Import the rest of the dependencies
import { UltraHonkBackend } from '@aztec/bb.js';
import { Noir } from '@noir-lang/noir_js';

import {getCircuit} from '$lib/circuits';
import { BabyJubJubUtils } from '$lib/elgamal';

import {onMount} from 'svelte';

onMount(async () => {
    try {
        console.log("Getting circuit...");
        const { program } = await getCircuit();
        console.log("Circuit loaded successfully");
        const noir = new Noir(program);
        const backend = new UltraHonkBackend(program.bytecode);

        const babyJub = new BabyJubJubUtils();
        await babyJub.init();
        const publicKey = babyJub.privateToPublicKey(BigInt("363392786237362068767139959337036002311688465567650996034788007646727742377"));

        // Create inputs for the proof - using string representations to avoid TOML parsing issues
        const proofInputs = {
            private_key: "363392786237362068767139959337036002311688465567650996034788007646727742377",
            randomness: "168986485046885582825082387270879151100288537211746581237924789162159767775",
            public_key: {
                x: publicKey.x.toString(),
                y: publicKey.y.toString()
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
        // log proof Uint8Array to hexadecimal
        console.log("results", Array.from(new Uint8Array(proof.proof)).map(b => b.toString(16).padStart(2, '0')).join(''));
        console.log(proofInputs)
    } catch (error) {
        console.error("Error during circuit execution:", error);
    }
});
</script>

<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to read the documentation</p>
