import { OAuth2Client } from 'npm:google-auth-library';

console.log('Hello from Functions!');

Deno.serve(async (req) => {
	console.log('############ function started');

	if (req.method !== 'POST') {
		return new Response('Method Not Allowed', { status: 405 });
	}

	const { server_code } = await req.json();

	const googleClientId = Deno.env.get('GOOGLE_CLIENT_ID')!;
	const googleClientSecret = Deno.env.get('GOOGLE_CLIENT_SECRET')!;

	const oauth2Client = new OAuth2Client(
		googleClientId,
		googleClientSecret,
		'',
	);

	try {
		const { tokens } = await oauth2Client.getToken(server_code);
		oauth2Client.setCredentials(tokens);

		return new Response(JSON.stringify({ data: tokens }), {
			headers: { 'Content-Type': 'application/json' },
		});
	} catch (error) {
		console.error('Error getting tokens:', error);
		return new Response(JSON.stringify({ error: error }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' },
		});
	}
});
