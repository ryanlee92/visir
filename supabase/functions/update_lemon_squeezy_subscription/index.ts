// supabase/functions/cancel_lemon_subscription/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  const body = await req.json();
  const subscriptionId = body.subscription_id;
  const attributes = body.attributes;
  const isTestMode = body.is_test_mode;

  const apiKey = isTestMode
    ? Deno.env.get("LEMON_SQUEEZY_API_KEY_TEST_MODE")!
    : Deno.env.get("LEMON_SQUEEZY_API_KEY")!;

  if (!subscriptionId) {
    return new Response("Missing subscription_id", { status: 400 });
  }

  const url = `https://api.lemonsqueezy.com/v1/subscriptions/${subscriptionId}`;

  try {
    const res = await fetch(url, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        Accept: "application/json",
        "Content-Type": "application/vnd.api+json",
      },
      body: JSON.stringify({
        data: {
          type: "subscriptions",
          id: subscriptionId,
          attributes: attributes,
        },
      }),
    });

    if (!res.ok) {
      const errorText = await res.text();
      console.error("❌ Lemon API error:", errorText);
      return new Response(`Failed to cancel subscription: ${errorText}`, {
        status: res.status,
      });
    }

    const result = await res.json();
    console.log("✅ Subscription cancelled:", result.data);

    return new Response(
      JSON.stringify({
        message: "Subscription cancelled successfully",
        subscription: result.data,
      }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (e) {
    console.error("❌ Internal error:", e);
    return new Response("Internal server error", { status: 500 });
  }
});
