import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  const body = await req.json();
  const customerId = body.customer_id;
  const isTestMode = body.is_test_mode;

  const apiKey = isTestMode
    ? Deno.env.get("LEMON_SQUEEZY_API_KEY_TEST_MODE")!
    : Deno.env.get("LEMON_SQUEEZY_API_KEY")!;

  try {
    const res = await fetch(
      `https://api.lemonsqueezy.com/v1/customers/${customerId}`,
      {
        method: "GET",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          Accept: "application/json",
        },
      }
    );

    if (!res.ok) {
      const errorText = await res.text();
      return new Response(`Failed to fetch customer: ${errorText}`, {
        status: res.status,
      });
    }

    const result = await res.json();

    return new Response(JSON.stringify(result["data"]), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
      status: 200,
    });
  } catch (e) {
    console.error("Error fetching Lemon Squeezy customer:", e);
    return new Response("Internal server error", { status: 500 });
  }
});
