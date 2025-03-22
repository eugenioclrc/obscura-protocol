// This file ensures global polyfills are properly initialized early
// It's now simplified since vite-plugin-node-polyfills handles most of the work

// Make sure global is defined in the browser
if (typeof window !== 'undefined') {
	// Ensure global exists
	window.global = window;

	// Ensure process exists
	if (!window.process) {
		// @ts-expect-error - We're only providing the minimum needed properties
		window.process = { env: {} };
	}

	// Confirm Buffer is available (should be provided by the Vite plugin)
	console.log('Buffer available:', typeof window.Buffer !== 'undefined');
}

// No exports needed
