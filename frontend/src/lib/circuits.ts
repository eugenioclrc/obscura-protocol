import { compile, createFileManager } from "@noir-lang/noir_wasm"

import main from "../../../elgamal-tokens/circuits/mint/src/main.nr?url";
import elgamal from "../../../elgamal-tokens/circuits/mint/src/elgamal.nr?url";
import nargoToml from "../../../elgamal-tokens/circuits/mint/Nargo.toml?url";

// Pre-download the known dependencies to avoid CORS issues
async function preloadDependencies() {
    // Only run in browser
    if (typeof window === 'undefined') {
        return;
    }

    // Create a custom fetch function that routes GitHub requests through our proxies
    const originalFetch = window.fetch;
    window.fetch = function(input, init) {
        const url = typeof input === 'string' ? input : input instanceof URL ? input.toString() : input.url;
        let newUrl = url;
        
        // Route GitHub and codeload requests through our proxies
        if (url.startsWith('https://github.com/')) {
            newUrl = '/github-proxy' + url.substring('https://github.com'.length);
            console.log('Proxying GitHub request through github-proxy:', newUrl);
        } else if (url.startsWith('https://codeload.github.com/')) {
            newUrl = '/codeload-proxy' + url.substring('https://codeload.github.com'.length);
            console.log('Proxying codeload request through codeload-proxy:', newUrl);
        }
        
        // If URL was modified, create new Request or update URL
        if (newUrl !== url) {
            // If input is a Request object, create a new one with the modified URL
            if (typeof input !== 'string' && !(input instanceof URL)) {
                input = new Request(newUrl, input);
            } else {
                input = newUrl;
            }
        }
        
        // Add fallback mode for any remaining GitHub requests that might escape our proxy
        if (init && (url.includes('github.com') || url.includes('codeload.github.com'))) {
            init = {
                ...init,
                // Use these options as fallbacks for direct GitHub requests
                mode: 'cors' as RequestMode,
                credentials: 'omit' as RequestCredentials
            };
        }
        
        return originalFetch.call(this, input, init);
    };

    // Pre-fetch the known EC dependency through our proxy
    try {
        console.log('Pre-fetching EC dependency through proxy');
        // First try the GitHub proxy
        const response = await fetch('/github-proxy/noir-lang/ec/archive/v0.1.2.zip');
        console.log('Pre-fetch response status:', response.status);
    } catch (e) {
        console.log('Pre-fetch through GitHub proxy failed, will fall back to direct fetch:', e);
    }
}

export async function getCircuit() {
    // Only try to preload dependencies in the browser
    if (typeof window !== 'undefined') {
        await preloadDependencies();
    }
    
    const fm = createFileManager("/");
    const mainResponse = await fetch(main);
    const nargoTomlResponse = await fetch(nargoToml);
    const elgamalResponse = await fetch(elgamal);
    if (!mainResponse.body || !nargoTomlResponse.body) {
        throw new Error("Failed to fetch required circuit files");
    }
   
    fm.writeFile("./src/main.nr", mainResponse.body);
    fm.writeFile("./Nargo.toml", nargoTomlResponse.body);
    fm.writeFile("./src/elgamal.nr", elgamalResponse.body);
    try {
        console.log("Compiling circuit...");
        const result = await compile(fm);
        console.log("Circuit compiled successfully");
        return result;
    } catch (error) {
        console.error("Error compiling circuit:", error);
        throw error;
    }
}