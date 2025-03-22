import tailwindcss from '@tailwindcss/vite';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { fileURLToPath } from 'url';
import path from 'path';

// Get the directory paths
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootPath = path.resolve(__dirname, '..');
const elgamalTokensPath = path.resolve(rootPath, 'elgamal-tokens');

export default defineConfig({
	plugins: [tailwindcss(), sveltekit()],
	build: {
		target: 'esnext',
	},
	optimizeDeps: {
		esbuildOptions: {
			target: 'esnext'
		},
		// This option is required for @noir-lang/noir_wasm and other WASM packages
		exclude: ['@noir-lang/noir_wasm', '@noir-lang/noir_js', '@aztec/bb.js']
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
	resolve: {
		dedupe: ['@noir-lang/noir_wasm', '@noir-lang/noir_js']
	}
});
