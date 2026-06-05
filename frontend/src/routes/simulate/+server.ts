import { error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

// In Docker, the backend is available at http://backend:8000
// In local dev, we still use Vite's proxy. 
// This server route acts as a fallback or production proxy.
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8000';

export const POST: RequestHandler = async ({ request, fetch }) => {
	try {
		const contentType = request.headers.get('content-type');
		const body = await request.arrayBuffer();

		const response = await fetch(`${BACKEND_URL}/simulate`, {
			method: 'POST',
			headers: {
				'Content-Type': contentType || 'application/x-www-form-urlencoded'
			},
			body: body
		});

		if (!response.ok) {
			const errText = await response.text();
			throw error(response.status, errText);
		}

		const data = await response.json();
		return new Response(JSON.stringify(data), {
			headers: {
				'Content-Type': 'application/json'
			}
		});
	} catch (e: any) {
		console.error('Proxy error:', e);
		throw error(500, e.message || 'Internal Server Error');
	}
};
