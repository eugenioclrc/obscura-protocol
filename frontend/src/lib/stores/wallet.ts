import { writable } from 'svelte/store';
import type { WalletClient, PublicClient } from 'viem';

// Store type for wallet information
type WalletStore = {
  address: string | null;
  walletClient: WalletClient | null;
  publicClient: PublicClient | null;
  isConnected: boolean;
};

// Initial state
const initialState: WalletStore = {
  address: null,
  walletClient: null,
  publicClient: null,
  isConnected: false
};

// Create the wallet store
export const wallet = writable<WalletStore>(initialState);

// Helper functions to update wallet store
export function connectWallet(address: string, walletClient: WalletClient, publicClient: PublicClient) {
  // Update store with wallet information
  wallet.update(state => ({
    ...state,
    address,
    walletClient,
    publicClient,
    isConnected: true
  }));
  
  // Also store address in sessionStorage for persistence across page refreshes
  sessionStorage.setItem('walletAddress', address);
}

export function disconnectWallet() {
  wallet.set(initialState);
  sessionStorage.removeItem('walletAddress');
} 