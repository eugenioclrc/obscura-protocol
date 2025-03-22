//import { base, mainnet, optimism } from 'wagmi/chains'
//import { injected, metaMask, safe, walletConnect } from 'wagmi/connectors'

//const projectId = '<WALLETCONNECT_PROJECT_ID>'

import { zksyncSsoConnector } from 'zksync-sso/connector';
import { zksyncSepoliaTestnet } from 'viem/chains';
import { createConfig, connect } from '@wagmi/core';
import { parseEther } from 'viem';
import { createPublicClient, http } from 'viem';
// svelte stores

const ssoConnector = zksyncSsoConnector({
	// Optional session configuration, if omitted user will have to sign every transaction via Auth Server
	session: {
		expiry: '1 day',

		// Allow up to 0.1 ETH to be spend in gas fees
		feeLimit: parseEther('0.1')
	}
});

export const wagmiConfig = createConfig({
	chains: [zksyncSepoliaTestnet],
	connectors: [ssoConnector],
	client: ({ chain }) =>
		createPublicClient({
			chain,
			transport: http()
		})
});

export const connectWithSSO = () => {
	connect(wagmiConfig, {
		connector: ssoConnector,
		chainId: zksyncSepoliaTestnet.id // or another chain id that has SSO support
	});
};
