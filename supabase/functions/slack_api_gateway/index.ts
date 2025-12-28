import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import qs from "https://deno.land/x/deno_qs@0.0.3/mod.ts";

export const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', {headers: corsHeaders})
    }

    const {method, url, headers, body} = await req.json();

    if (method === 'POST') {
        const response = await fetch(url, {
            method: method,
            headers: headers || {},
            body: qs.stringify(body),
        });

        const responseBody = await response.json();
        return new Response(JSON.stringify(responseBody), {
            headers: {
                ...response.headers,
                ...corsHeaders,
            },
        })
    } else {
        const response = await fetch(url, {
            method: method,
            headers: headers || {},
        });

        const responseBody = await response.json();
        return new Response(JSON.stringify(responseBody), {
            headers: {
                ...response.headers,
                ...corsHeaders,
            },
        })
    }

});
