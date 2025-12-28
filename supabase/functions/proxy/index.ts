// deno-lint-ignore-file
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

export const corsHeaders = {
    'Access-Control-Allow-Origin': '*', // Allow all origins for testing, change to specific origin in production
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
};

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response(null, {
            headers: corsHeaders,
        });
    }

    const url = new URL(req.url);
    const targetUrl = url.searchParams.get('url');
    if (!targetUrl) {
        return new Response('Missing target URL', { status: 400 }); 
    }

    const headers = new Headers(req.headers);
    headers.delete('host');
    
    try {
        const targetHeaders = new Headers();
        if (headers.get('Authorization')) targetHeaders.set('Authorization', headers.get('Authorization')!);
        if (headers.get('Content-Type')) targetHeaders.set('Content-Type', headers.get('Content-Type')!);

        const response = await fetch(targetUrl, {
            method: req.method,
            headers: targetHeaders,
            body: req.body,
        });
        
        const responseHeaders = new Headers(response.headers);
        responseHeaders.set('Access-Control-Allow-Origin', '*');
        responseHeaders.set('Access-Control-Allow-Headers', 'authorization, x-client-info, apikey, content-type');
        responseHeaders.set('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');

        return new Response(response.body, {
            status: response.status,
            headers: responseHeaders,
        });
    } catch (error: any) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    }
});