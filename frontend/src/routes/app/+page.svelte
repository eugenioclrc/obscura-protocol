<script lang="ts">
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import 'iconify-icon';
    import { createWalletFromPrivateKey } from '$lib/privateKeyWallet';
    import { wallet, connectWallet } from '$lib/stores/wallet';

    let activeOption: string = 'privateKey';  // Set privateKey as the default active option
    let privateKey: string = '';
    let privateKeyVisible: boolean = false;
    let loading: boolean = false;
    let error: string | null = null;

    // Local state for the wallet address to show in the UI
    let walletAddress: string | null = null;

    function selectOption(option: string) {
        activeOption = option;
        // Clear any previous errors when changing options
        error = null;
    }

    async function connectWalletHandler() {
        if (activeOption !== 'privateKey') {
            // Mock connection for non-privateKey options
            loading = true;
            
            setTimeout(() => {
                loading = false;
                goto('/app/tokens');
            }, 1500);
            return;
        }
        
        // Connect with private key
        loading = true;
        error = null;
        
        try {
            if (!privateKey.trim()) {
                throw new Error('Private key is required');
            }
            
            const { walletClient, address, publicClient } = await createWalletFromPrivateKey(privateKey);
            
            // Store wallet info in the Svelte store (will be accessible app-wide)
            connectWallet(address, walletClient, publicClient);
            
            // Update local state for UI feedback
            walletAddress = address;
            
            // Navigate to tokens page after successful connection
            setTimeout(() => {
                loading = false;
                goto('/app/tokens');
            }, 500);
        } catch (err) {
            loading = false;
            error = err instanceof Error ? err.message : 'Failed to connect wallet';
            console.error('Wallet connection error:', err);
        }
    }

    function togglePrivateKeyVisibility() {
        privateKeyVisible = !privateKeyVisible;
    }
</script>

<div class="app-container">
    <div class="header">
        <h1>Connect Wallet</h1>
        <p class="subtitle">Choose your preferred method to connect</p>
    </div>

    <div class="wallet-options">
        <button 
            class="wallet-option {activeOption === 'sso' ? 'active' : ''}" 
            on:click={() => selectOption('sso')}
        >
            <div class="option-icon">
                <iconify-icon icon="carbon:user-profile" width="24"></iconify-icon>
            </div>
            <div class="option-info">
                <div class="option-title">Single Sign-On</div>
                <div class="option-description">Connect using your existing account</div>
            </div>
        </button>

        <button 
            class="wallet-option {activeOption === 'privateKey' ? 'active' : ''}" 
            on:click={() => selectOption('privateKey')}
        >
            <div class="option-icon">
                <iconify-icon icon="carbon:key" width="24"></iconify-icon>
            </div>
            <div class="option-info">
                <div class="option-title">Private Key</div>
                <div class="option-description">Enter your wallet's private key</div>
            </div>
        </button>

        <button 
            class="wallet-option {activeOption === 'extension' ? 'active' : ''}" 
            on:click={() => selectOption('extension')}
        >
            <div class="option-icon">
                <iconify-icon icon="carbon:wallet" width="24"></iconify-icon>
            </div>
            <div class="option-info">
                <div class="option-title">MetaMask / Rabby</div>
                <div class="option-description">Connect using browser extension</div>
            </div>
        </button>
    </div>

    {#if activeOption === 'privateKey'}
        <div class="private-key-form">
            <div class="form-group">
                <label for="privateKey">Enter Private Key</label>
                <div class="private-key-input">
                    <input 
                        type={privateKeyVisible ? 'text' : 'password'}
                        id="privateKey" 
                        bind:value={privateKey} 
                        placeholder="Enter your private key"
                    />
                    <button class="visibility-toggle" on:click={togglePrivateKeyVisibility}>
                        <iconify-icon 
                            icon={privateKeyVisible ? "carbon:view-off" : "carbon:view"} 
                            width="20"
                        ></iconify-icon>
                    </button>
                </div>
                {#if error}
                    <div class="error-message">{error}</div>
                {/if}
            </div>
        </div>
    {/if}

    <button 
        class="connect-button {!activeOption || (activeOption === 'privateKey' && !privateKey) ? 'disabled' : ''}"
        disabled={!activeOption || (activeOption === 'privateKey' && !privateKey)}
        on:click={connectWalletHandler}
    >
        {#if loading}
            <div class="loading-spinner"></div>
            Connecting...
        {:else}
            Connect Wallet
        {/if}
    </button>

    {#if walletAddress}
        <div class="wallet-connected">
            <div class="success-message">Wallet connected successfully</div>
            <div class="address-display">
                <span>Address:</span> {walletAddress}
            </div>
        </div>
    {/if}
</div>

<style>
    .app-container {
        max-width: 480px;
        margin: 0 auto;
        padding: 20px;
        font-family: 'Inter', system-ui, -apple-system, sans-serif;
        color: #e1e7ef;
        position: relative;
        background-color: #1c2029;
        min-height: 100vh;
    }

    .header {
        margin-bottom: 30px;
        text-align: center;
    }

    h1 {
        font-size: 1.8rem;
        font-weight: 600;
        color: #ffffff;
        margin: 0 0 8px 0;
    }

    .subtitle {
        font-size: 1rem;
        color: #9aa1b1;
        margin: 0;
    }

    .wallet-options {
        display: flex;
        flex-direction: column;
        gap: 12px;
        margin-bottom: 24px;
    }

    .wallet-option {
        display: flex;
        align-items: center;
        background-color: #2a2f3c;
        border: 2px solid transparent;
        border-radius: 12px;
        padding: 16px;
        color: #e1e7ef;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        text-align: left;
    }

    .wallet-option:hover {
        background-color: #343b4d;
    }

    .wallet-option.active {
        border-color: #4ade80;
        background-color: #343b4d;
    }

    .option-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 48px;
        height: 48px;
        background-color: rgba(74, 222, 128, 0.1);
        color: #4ade80;
        border-radius: 50%;
        margin-right: 16px;
    }

    .option-info {
        flex: 1;
    }

    .option-title {
        font-weight: 600;
        font-size: 1.1rem;
        margin-bottom: 4px;
    }

    .option-description {
        color: #9aa1b1;
        font-size: 0.9rem;
    }

    .private-key-form {
        background-color: #2a2f3c;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 24px;
    }

    .form-group {
        margin-bottom: 16px;
    }

    label {
        display: block;
        margin-bottom: 8px;
        color: #9aa1b1;
        font-size: 0.9rem;
    }

    .private-key-input {
        position: relative;
        display: flex;
    }

    input {
        width: 100%;
        padding: 12px;
        background-color: #1c2029;
        border: 1px solid #4a5568;
        border-radius: 8px;
        color: #e1e7ef;
        font-family: 'Roboto Mono', monospace;
        font-size: 0.9rem;
    }

    input:focus {
        outline: none;
        border-color: #4ade80;
    }

    .visibility-toggle {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #9aa1b1;
        cursor: pointer;
    }

    .connect-button {
        width: 100%;
        padding: 14px;
        background-color: #4ade80;
        border: none;
        border-radius: 12px;
        color: #1c2029;
        font-weight: 600;
        font-size: 1rem;
        cursor: pointer;
        transition: background-color 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .connect-button:hover:not(.disabled) {
        background-color: #22c55e;
    }

    .connect-button.disabled {
        background-color: #4a5568;
        cursor: not-allowed;
        opacity: 0.7;
    }

    .loading-spinner {
        width: 20px;
        height: 20px;
        border: 3px solid rgba(28, 32, 41, 0.3);
        border-radius: 50%;
        border-top-color: #1c2029;
        animation: spin 1s linear infinite;
        margin-right: 10px;
    }

    .error-message {
        color: #ef4444;
        font-size: 0.85rem;
        margin-top: 8px;
    }

    .wallet-connected {
        margin-top: 20px;
        padding: 16px;
        background-color: rgba(74, 222, 128, 0.1);
        border-radius: 8px;
        border: 1px solid rgba(74, 222, 128, 0.2);
    }

    .success-message {
        color: #4ade80;
        font-weight: 600;
        margin-bottom: 8px;
    }

    .address-display {
        font-family: 'Roboto Mono', monospace;
        font-size: 0.8rem;
        word-break: break-all;
    }

    .address-display span {
        color: #9aa1b1;
    }

    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }
</style> 