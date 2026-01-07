// deno-lint-ignore-file
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

export const corsHeaders = {
    'Access-Control-Allow-Origin': '*', // Allow all origins for testing, change to specific origin in production
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
};

// 허용된 도메인 화이트리스트
const ALLOWED_DOMAINS = [
    'slack.com',
    'api.slack.com',
    'secure.gravatar.com',
    'files.slack.com',
];

// 내부 IP 범위 차단 (SSRF 방지)
const BLOCKED_IP_RANGES = [
    /^127\./,           // localhost
    /^10\./,            // private network
    /^172\.(1[6-9]|2[0-9]|3[0-1])\./,  // private network
    /^192\.168\./,      // private network
    /^169\.254\./,      // link-local
    /^::1$/,            // IPv6 localhost
    /^fc00:/,           // IPv6 private network
    /^fe80:/,           // IPv6 link-local
];

function isAllowedDomain(url: string): boolean {
    try {
        const parsedUrl = new URL(url);
        const hostname = parsedUrl.hostname.toLowerCase();
        
        // 도메인 화이트리스트 확인
        const isAllowed = ALLOWED_DOMAINS.some(domain => 
            hostname === domain || hostname.endsWith('.' + domain)
        );
        
        if (!isAllowed) {
            return false;
        }
        
        // IP 주소인 경우 내부 IP 차단
        const isIpAddress = /^\d+\.\d+\.\d+\.\d+$/.test(hostname) || hostname.includes(':');
        if (isIpAddress) {
            const isBlocked = BLOCKED_IP_RANGES.some(range => range.test(hostname));
            if (isBlocked) {
                return false;
            }
        }
        
        // HTTPS만 허용
        return parsedUrl.protocol === 'https:';
    } catch {
        return false;
    }
}

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

    // 도메인 화이트리스트 검증
    if (!isAllowedDomain(targetUrl)) {
        return new Response('Domain not allowed', { status: 403 });
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