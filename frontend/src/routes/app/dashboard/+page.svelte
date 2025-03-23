<script lang="ts">
    import { formatEther } from 'viem';
    import { wallet } from '$lib/shared';
    import { onMount } from 'svelte';
    import { loadWallet } from '$lib/shared';
    import { goto } from '$app/navigation';
    //import ReceiveModal from './ReceiveModal.svelte';
    //import SendModal from './SendModal.svelte';
    import 'iconify-icon';

    let receiver: string = '';
    let amount: string = '';
    let modal: boolean = false;
    let modalSend: boolean = false;

    onMount(async () => {
            // Load the wallet
            await loadWallet();

            try {
                    const urlParams = new URLSearchParams(window.location.search);
                    const payment = urlParams.get('payment') || '';
                    receiver = payment.split('?')[0].replace('ethereum:', '');
                    //amount = String(formatEther(payment.split('?value=')[1]));

                    if (receiver && amount) {
                            modalSend = true;
                    }
            } catch (err) {
                    console.error('Error parsing payment params:', err);
            }
    });
</script>

<div class="app-container">
    <button class="settings-button">
            <iconify-icon icon="carbon:settings" width="24"></iconify-icon>
    </button>

    <h1>USDC balance</h1>
    <div class="balance-card">
            $ 23152<span class="balance-decimals">.02</span>
    </div>

    <div class="action-buttons">
            <button class="action-button" on:click={() => modalSend = true}>
                    <iconify-icon icon="carbon:send-alt" width="24"></iconify-icon>
                    <span>Transfer</span>
            </button>
            <button class="action-button" on:click={() => modal = true}>
                    <iconify-icon icon="carbon:download" width="24"></iconify-icon>
                    <span>Receive</span>
            </button>
            <button class="action-button">
                    <iconify-icon icon="carbon:package" width="24"></iconify-icon>
                    <span>Wrap</span>
            </button>
            <button class="action-button">
                    <iconify-icon icon="carbon:box" width="24"></iconify-icon>
                    <span>Unwrap</span>
            </button>
    </div>
    
    <button class="private-tokens-button" on:click={() => goto('/app/tokens')}>
            <iconify-icon icon="carbon:privacy" width="20"></iconify-icon>
            <span>Manage Private Tokens</span>
    </button>

    <div class="wallet-card">
            <iconify-icon icon="carbon:wallet" width="20"></iconify-icon>
            <span>Your Wallet:</span>
            <div class="address">{$wallet || '0x38641F...9BC2c755'}</div>
    </div>

    <h2>History</h2>
    <div class="history-item">
            <div>
                    <strong>Received</strong>
                    <div class="address">EQDn6i8M...CI3t</div>
            </div>
            <div class="positive-amount">+227.28</div>
    </div>
    <div class="history-item">
            <div>
                    <strong>Sent</strong>
                    <div class="address">MBI6nDQE...r3LO</div>
            </div>
            <div class="negative-amount">-3100</div>
    </div>
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

    .settings-button {
        position: absolute;
        top: 20px;
        right: 20px;
        background: none;
        border: none;
        color: #9aa1b1;
        cursor: pointer;
        padding: 8px;
        border-radius: 50%;
        transition: background-color 0.2s;
    }

    .settings-button:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }

    h1 {
        font-size: 1.2rem;
        font-weight: 500;
        color: #9aa1b1;
        margin-top: 50px;
        margin-bottom: 10px;
    }

    h2 {
        font-size: 1.2rem;
        font-weight: 500;
        margin-top: 30px;
        margin-bottom: 15px;
        color: #9aa1b1;
    }

    .balance-card {
        font-size: 3rem;
        font-weight: 700;
        margin-bottom: 30px;
        color: #ffffff;
    }

    .balance-decimals {
        font-size: 2rem;
        color: #9aa1b1;
    }

    .action-buttons {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 12px;
        margin-bottom: 30px;
    }

    .action-button {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        background-color: #2a2f3c;
        border: none;
        border-radius: 12px;
        padding: 16px 0;
        color: #ffffff;
        font-weight: 500;
        transition: all 0.2s;
        cursor: pointer;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    }

    .action-button:hover {
        background-color: #343b4d;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
    }

    .action-button span {
        margin-top: 8px;
        font-size: 0.9rem;
    }

    .wallet-card {
        display: flex;
        align-items: center;
        background-color: #2a2f3c;
        padding: 16px;
        border-radius: 12px;
        margin-bottom: 20px;
        font-size: 0.9rem;
    }

    .wallet-card iconify-icon {
        margin-right: 10px;
        color: #9aa1b1;
    }

    .wallet-card span {
        color: #9aa1b1;
        margin-right: 8px;
    }

    .address {
        font-family: 'Roboto Mono', monospace;
        color: #e1e7ef;
        font-size: 0.85rem;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .history-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 16px 0;
        border-bottom: 1px solid #2a2f3c;
    }
    
    .history-item strong {
        display: block;
        margin-bottom: 4px;
        color: #e1e7ef;
    }

    .history-item .address {
        color: #9aa1b1;
    }

    .positive-amount {
        color: #4ade80;
        font-weight: 600;
    }

    .negative-amount {
        color: #f87171;
        font-weight: 600;
    }

    @media (max-width: 480px) {
        .action-buttons {
            grid-template-columns: repeat(2, 1fr);
        }
    }

    .private-tokens-button {
        display: flex;
        align-items: center;
        background-color: #2a2f3c;
        padding: 14px;
        border: none;
        border-radius: 12px;
        margin-bottom: 20px;
        width: 100%;
        color: #e1e7ef;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
    }

    .private-tokens-button:hover {
        background-color: #343b4d;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
    }

    .private-tokens-button iconify-icon {
        margin-right: 10px;
        color: #9aa1b1;
    }
</style>
