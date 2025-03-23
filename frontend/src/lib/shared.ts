import { writable } from 'svelte/store';
import { connectWithSSO } from './wagmiWallet';
import { getAccount } from '@wagmi/core';
import { wagmiConfig } from './wagmiWallet';

// Create a writable store for the wallet address
export const wallet = writable<string>('');

// Function to load the wallet
export const loadWallet = async () => {
    try {
        await connectWithSSO();
        
        // Get the connected account
        const account = getAccount(wagmiConfig);
        
        // Update the wallet store with the address
        if (account.address) {
            wallet.set(account.address);
        } else {
            console.error('No wallet address found');
        }
    } catch (error) {
        console.error('Error loading wallet:', error);
    }
}; 