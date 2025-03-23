<script lang="ts">
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import { wallet } from '$lib/stores/wallet';
    import { formatEther } from 'viem';
    import 'iconify-icon';
    import { anvilChain } from '$lib/privateKeyWallet';

    // Local state for wallet info
    let walletAddress: string | null = null;
    let ethBalance: string = '0';
    let isLoading: boolean = true;
    let error: string | null = null;

    // Sample tokens (in a real app, these would come from a blockchain query)
    let privateTokens = [
        { name: 'Private USDC', symbol: 'pUSDC', balance: '0.00', address: '0x721e...d4f3' },
        { name: 'Private ETH', symbol: 'pETH', balance: '0.00', address: '0x94f2...a3c7' }
    ];

    let newTokenAddress = '';
    let showAddTokenForm = false;

    // Function to check if wallet is connected or redirect to connect page
    async function checkWalletConnection() {
        // Subscribe to the wallet store
        const unsubscribe = wallet.subscribe(walletState => {
            if (!walletState.isConnected || !walletState.address || !walletState.publicClient) {
                // Try to get address from session storage (page refresh case)
                const storedAddress = sessionStorage.getItem('walletAddress');
                if (!storedAddress) {
                    // If no wallet is connected, redirect to connect page
                    goto('/app');
                    return;
                }
                
                // Just update the local address if we have it in storage
                walletAddress = storedAddress;
            } else {
                // Update local state from store
                walletAddress = walletState.address;
                
                // Load blockchain data if we have a public client
                if (walletState.publicClient) {
                    loadBlockchainData(walletState.address, walletState.publicClient);
                }
            }
        });

        // Clean up subscription on component unmount
        return unsubscribe;
    }

    // Function to load data from the blockchain
    async function loadBlockchainData(address: string, publicClient: any) {
        try {
            isLoading = true;
            error = null;
            
            // Get ETH balance
            const balance = await publicClient.getBalance({
                address: address as `0x${string}`
            });
            
            // Format the balance from wei to ether
            ethBalance = formatEther(balance);
            
            // Update our sample tokens with the ETH balance for demo
            privateTokens = privateTokens.map(token => 
                token.symbol === 'pETH' 
                    ? { ...token, balance: ethBalance } 
                    : token
            );
            
            isLoading = false;
        } catch (err) {
            isLoading = false;
            error = err instanceof Error ? err.message : 'Failed to load blockchain data';
            console.error('Error loading blockchain data:', err);
        }
    }

    // Initialize on component mount
    onMount(() => checkWalletConnection());

    function toggleAddTokenForm() {
        showAddTokenForm = !showAddTokenForm;
    }

    function selectToken(token: { name: string, symbol: string, balance: string, address: string }) {
        // Handle token selection, maybe store in a store
        goto('/app/dashboard'); // Navigate back to main app after selection
    }

    function addNewToken() {
        if (newTokenAddress) {
            privateTokens = [
                ...privateTokens,
                { 
                    name: 'New Private Token', 
                    symbol: 'NEW', 
                    balance: '0.00',
                    address: newTokenAddress
                }
            ];
            newTokenAddress = '';
            showAddTokenForm = false;
        }
    }
</script>

<div class="app-container">
    <div class="header">
        <button class="back-button" on:click={() => goto('/app')}>
            <iconify-icon icon="carbon:arrow-left" width="24"></iconify-icon>
        </button>
        <h1>Private Tokens</h1>
    </div>

    {#if error}
        <div class="error-banner">
            <iconify-icon icon="carbon:warning" width="20"></iconify-icon>
            <span>{error}</span>
        </div>
    {/if}

    <div class="wallet-info">
        <div class="wallet-address">
            <span class="label">Connected Wallet:</span>
            <span class="address">{walletAddress || 'Not connected'}</span>
        </div>
        <div class="network-info">
            <span class="label">Network:</span>
            <span class="network">{anvilChain.name} ({anvilChain.id})</span>
        </div>
    </div>

    {#if isLoading}
        <div class="loading-container">
            <div class="loading-spinner"></div>
            <span>Loading token data...</span>
        </div>
    {:else}
        <div class="tokens-list">
            {#each privateTokens as token}
                <div class="token-card" on:click={() => selectToken(token)}>
                    <div class="token-info">
                        <div class="token-name">{token.name}</div>
                        <div class="token-address">{token.address}</div>
                    </div>
                    <div class="token-balance">
                        <div class="token-amount">{token.balance}</div>
                        <div class="token-symbol">{token.symbol}</div>
                    </div>
                </div>
            {/each}
        </div>
    {/if}

    <button class="add-token-button" on:click={toggleAddTokenForm}>
        <iconify-icon icon="carbon:add" width="24"></iconify-icon>
        <span>Add Private Token</span>
    </button>

    {#if showAddTokenForm}
        <div class="add-token-form">
            <div class="form-group">
                <label for="tokenAddress">Token Address</label>
                <input 
                    type="text" 
                    id="tokenAddress" 
                    bind:value={newTokenAddress} 
                    placeholder="Enter token contract address"
                />
            </div>
            <button class="submit-button" on:click={addNewToken}>Add Token</button>
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
        display: flex;
        align-items: center;
        margin-bottom: 20px;
    }

    .back-button {
        background: none;
        border: none;
        color: #9aa1b1;
        cursor: pointer;
        padding: 8px;
        margin-right: 10px;
        border-radius: 50%;
        transition: background-color 0.2s;
    }

    .back-button:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }

    h1 {
        font-size: 1.5rem;
        font-weight: 600;
        color: #ffffff;
        margin: 0;
    }

    .error-banner {
        display: flex;
        align-items: center;
        gap: 8px;
        background-color: rgba(239, 68, 68, 0.1);
        color: #ef4444;
        padding: 12px;
        border-radius: 8px;
        margin-bottom: 16px;
    }

    .wallet-info {
        background-color: #2a2f3c;
        border-radius: 12px;
        padding: 16px;
        margin-bottom: 20px;
    }

    .wallet-address, .network-info {
        display: flex;
        flex-direction: column;
        margin-bottom: 8px;
    }

    .label {
        font-size: 0.8rem;
        color: #9aa1b1;
        margin-bottom: 4px;
    }

    .address, .network {
        font-family: 'Roboto Mono', monospace;
        font-size: 0.9rem;
        word-break: break-all;
    }

    .network {
        color: #4ade80;
    }

    .loading-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 40px 0;
        color: #9aa1b1;
    }

    .loading-spinner {
        width: 30px;
        height: 30px;
        border: 3px solid rgba(74, 222, 128, 0.2);
        border-radius: 50%;
        border-top-color: #4ade80;
        animation: spin 1s linear infinite;
        margin-bottom: 16px;
    }

    .tokens-list {
        margin-bottom: 30px;
    }

    .token-card {
        display: flex;
        justify-content: space-between;
        align-items: center;
        background-color: #2a2f3c;
        padding: 16px;
        border-radius: 12px;
        margin-bottom: 12px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .token-card:hover {
        background-color: #343b4d;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
    }

    .token-name {
        font-weight: 600;
        font-size: 1.1rem;
        margin-bottom: 4px;
    }

    .token-address {
        font-family: 'Roboto Mono', monospace;
        color: #9aa1b1;
        font-size: 0.8rem;
    }

    .token-balance {
        text-align: right;
    }

    .token-amount {
        font-weight: 700;
        font-size: 1.1rem;
    }

    .token-symbol {
        color: #9aa1b1;
        font-size: 0.9rem;
    }

    .add-token-button {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        background-color: #2a2f3c;
        border: 2px dashed #4a5568;
        border-radius: 12px;
        padding: 14px;
        color: #9aa1b1;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
    }

    .add-token-button:hover {
        background-color: #343b4d;
        color: #ffffff;
    }

    .add-token-button iconify-icon {
        margin-right: 8px;
    }

    .add-token-form {
        background-color: #2a2f3c;
        border-radius: 12px;
        padding: 20px;
        margin-top: 16px;
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

    .submit-button {
        width: 100%;
        padding: 12px;
        background-color: #4ade80;
        border: none;
        border-radius: 8px;
        color: #1c2029;
        font-weight: 600;
        cursor: pointer;
        transition: background-color 0.2s;
    }

    .submit-button:hover {
        background-color: #22c55e;
    }

    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }
</style> 