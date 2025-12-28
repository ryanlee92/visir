import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  const body = await req.json();
  const userId = body.user_id;
  const userEmail = body.user_email;
  const storeId = body.store_id;
  const variantId = body.variant_id;
  const discountCode = body.discount_code;
  const isTestMode = body.is_test_mode;

  const apiKey = isTestMode
    ? Deno.env.get("LEMON_SQUEEZY_API_KEY_TEST_MODE")!
    : Deno.env.get("LEMON_SQUEEZY_API_KEY")!;

  //get checkout url
  const checkoutRes = await fetch("https://api.lemonsqueezy.com/v1/checkouts", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/vnd.api+json",
      Accept: "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
    },
    body: JSON.stringify({
      data: {
        type: "checkouts",
        attributes: {
          product_options: {
            enabled_variants: [variantId],
          },
          checkout_data: {
            custom: {
              user_id: userId,
            },
            ...(userEmail && { email: userEmail }),
            ...(discountCode && { discount_code: discountCode }),
          },
        },
        relationships: {
          store: {
            data: {
              type: "stores",
              id: storeId,
            },
          },
          variant: {
            data: {
              type: "variants",
              id: variantId,
            },
          },
        },
      },
    }),
  });

  if (!checkoutRes.ok) {
    const error = await checkoutRes.text();
    return new Response(`Error creating checkout: ${error}`, { status: 500 });
  }

  const checkout = await checkoutRes.json();
  const url = checkout.data.attributes.url;

  return new Response(JSON.stringify({ url }), {
    headers: { "Content-Type": "application/json" },
    status: 200,
  });
});
