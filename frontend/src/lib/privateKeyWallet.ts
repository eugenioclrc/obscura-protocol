import { createWalletClient, http, type WalletClient, type PublicClient } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { createPublicClient } from 'viem';
import { localhost } from 'viem/chains';

// Create a custom anvil chain configuration
export const anvilChain = {
  ...localhost,
  id: 31337,
  name: 'Anvil',
};

// Creates a wallet client from a private key
export async function createWalletFromPrivateKey(privateKey: string): Promise<{ 
  walletClient: WalletClient; 
  address: string;
  publicClient: PublicClient;
}> {
  try {
    // Ensure the private key has the 0x prefix and correct type
    const formattedKey = privateKey.startsWith('0x') 
      ? privateKey as `0x${string}` 
      : `0x${privateKey}` as `0x${string}`;
    
    // Create an account from the private key
    const account = privateKeyToAccount(formattedKey);
    
    // Create the wallet client
    const walletClient = createWalletClient({
      account,
      chain: anvilChain,
      transport: http('http://localhost:8545'),
    });

    // Create a public client for reading from the chain
    const publicClient = createPublicClient({
      chain: anvilChain,
      transport: http('http://localhost:8545'),
    });
    
    return { 
      walletClient, 
      address: account.address,
      publicClient
    };
  } catch (error) {
    console.error('Error creating wallet from private key:', error);
    throw new Error('Invalid private key format');
  }
} 