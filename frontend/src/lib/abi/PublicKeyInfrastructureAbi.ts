export default [
	{
		type: 'function',
		name: 'isRegistered',
		inputs: [{ name: 'account', type: 'address', internalType: 'address' }],
		outputs: [{ name: '', type: 'bool', internalType: 'bool' }],
		stateMutability: 'view'
	},
	{
		type: 'function',
		name: 'registerPublicKey',
		inputs: [
			{ name: 'X', type: 'uint256', internalType: 'uint256' },
			{ name: 'Y', type: 'uint256', internalType: 'uint256' }
		],
		outputs: [],
		stateMutability: 'nonpayable'
	},
	{
		type: 'function',
		name: 'registry',
		inputs: [{ name: '', type: 'address', internalType: 'address' }],
		outputs: [
			{ name: 'X', type: 'uint256', internalType: 'uint256' },
			{ name: 'Y', type: 'uint256', internalType: 'uint256' }
		],
		stateMutability: 'view'
	},
	{
		type: 'event',
		name: 'NewRegisteredPublicKey',
		inputs: [
			{ name: 'owner', type: 'address', indexed: true, internalType: 'address' },
			{ name: 'PubKeyX', type: 'uint256', indexed: false, internalType: 'uint256' },
			{ name: 'PubKeyY', type: 'uint256', indexed: false, internalType: 'uint256' }
		],
		anonymous: false
	}
];
