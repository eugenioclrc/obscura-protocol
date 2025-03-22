import type { RequestHandler } from './$types';

// Handle GET requests to the proxy endpoint
export const GET: RequestHandler = async ({ url, fetch }) => {
	try {
		// Get the GitHub path from the query parameter
		const githubPath = url.searchParams.get('path');
		if (!githubPath) {
			return new Response('Missing path parameter', { status: 400 });
		}

		// Construct the full GitHub URL
		const githubUrl = `https://github.com${githubPath}`;
		console.log(`Proxying GitHub request to: ${githubUrl}`);

		// Fetch the resource from GitHub
		const response = await fetch(githubUrl, {
			headers: {
				'User-Agent': 'Mozilla/5.0 (compatible; SvelteKit; +https://kit.svelte.dev)'
			}
		});

		// Create a new response with the same body but with appropriate CORS headers
		const body = await response.arrayBuffer();

		// Return the response with CORS headers
		return new Response(body, {
			status: response.status,
			statusText: response.statusText,
			headers: {
				'Content-Type': response.headers.get('Content-Type') || 'application/octet-stream',
				'Access-Control-Allow-Origin': '*',
				'Access-Control-Allow-Methods': 'GET, OPTIONS',
				'Access-Control-Allow-Headers': 'Content-Type'
			}
		});
	} catch (error) {
		console.error('Error in GitHub proxy:', error);
		return new Response('Error fetching from GitHub', { status: 500 });
	}
};

// Handle OPTIONS requests for CORS preflight
export const OPTIONS: RequestHandler = async () => {
	return new Response(null, {
		headers: {
			'Access-Control-Allow-Origin': '*',
			'Access-Control-Allow-Methods': 'GET, OPTIONS',
			'Access-Control-Allow-Headers': 'Content-Type'
		}
	});
};
