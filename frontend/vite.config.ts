import tailwindcss from '@tailwindcss/vite';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { fileURLToPath } from 'url';
import path from 'path';
import { nodePolyfills } from 'vite-plugin-node-polyfills';

// Get the directory paths
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootPath = path.resolve(__dirname, '..');
const elgamalTokensPath = path.resolve(rootPath, 'elgamal-tokens');

export default defineConfig({
	plugins: [
		tailwindcss(),
		sveltekit(),
		// Add Node.js polyfills
		nodePolyfills({
			// Whether to polyfill `node:` protocol imports
			protocolImports: true,
			// Enable specific polyfills
			include: ['buffer', 'process', 'util', 'stream', 'assert', 'crypto'],
			globals: {
				process: true,
				Buffer: true
			}
		})
	],
	build: {
		target: 'esnext',
		rollupOptions: {
			// Enable these as required by circomlibjs
			output: {
				manualChunks: {}
			}
		}
	},
	optimizeDeps: {
		esbuildOptions: {
			target: 'esnext',
			// Add Node.js polyfills for libraries that use Node.js builtins
			define: {
				global: 'globalThis'
			}
		},
		// This option is required for @noir-lang/noir_wasm and other WASM packages
		exclude: ['@noir-lang/noir_wasm', '@noir-lang/noir_js', '@aztec/bb.js']
	},
	resolve: {
		dedupe: ['@noir-lang/noir_wasm', '@noir-lang/noir_js'],
		alias: {
			// Add this to explicitly tell Vite to use crypto-browserify for 'crypto'
			crypto: 'crypto-browserify',
			stream: 'stream-browserify',
			assert: 'assert'
		}
	},
	// Add Node.js polyfills
	define: {
		'process.env': {},
		global: 'globalThis'
	},
	server: {
		fs: {
			// Allow serving files from the parent project folder
			allow: [
				// Allow serving files from the project root
				rootPath,
				// Explicitly allow the elgamal-tokens directory
				elgamalTokensPath
			]
		},
		proxy: {
			// Proxy GitHub requests to bypass CORS - modified to handle codeload redirects
			'/github-proxy': {
				target: 'https://github.com',
				changeOrigin: true,
				rewrite: (path) => path.replace(/^\/github-proxy/, ''),
				headers: {
					'User-Agent': 'Mozilla/5.0'
				},
				followRedirects: true,
				configure: (proxy) => {
					proxy.on('error', (err) => {
						console.log('proxy error', err);
					});
					proxy.on('proxyReq', (_, req) => {
						console.log('Proxying:', req.method, req.url);
					});
				}
			},
			// Add specific proxy for codeload.github.com
			'/codeload-proxy': {
				target: 'https://codeload.github.com',
				changeOrigin: true,
				rewrite: (path) => path.replace(/^\/codeload-proxy/, ''),
				headers: {
					'User-Agent': 'Mozilla/5.0'
				}
			}
		}
	},
	// Add SSR specific configuration
	ssr: {
		// Exclude problematic dependencies from SSR
		noExternal: ['buffer', 'crypto-browserify', 'stream-browserify', 'assert', 'util']
	}
});
