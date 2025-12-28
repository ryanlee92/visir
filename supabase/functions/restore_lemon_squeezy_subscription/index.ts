// supabase/functions/get_lemon_subscription_by_customer_id/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

serve(async (req) => {
  const body = await req.json();
  const userId = body.user_id;
  const customerId = body.customer_id;
  const isTestMode = body.is_test_mode;

  const apiKey = isTestMode
    ? Deno.env.get("LEMON_SQUEEZY_API_KEY_TEST_MODE")!
    : Deno.env.get("LEMON_SQUEEZY_API_KEY")!;

  let page = 1;
  const perPage = 100;
  let matchedSubscription = null;

  try {
    while (true) {
      const res = await fetch(
        `https://api.lemonsqueezy.com/v1/subscriptions?page[number]=${page}&page[size]=${perPage}`,
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            Accept: "application/json",
          },
        }
      );

      if (!res.ok) {
        const errorText = await res.text();
        return new Response(`Error fetching subscriptions: ${errorText}`, {
          status: 500,
        });
      }

      const result = await res.json();
      const subscriptions = result.data;

      for (const sub of subscriptions) {
        const subCustomerId = String(sub.attributes?.customer_id);
        if (subCustomerId === String(customerId)) {
          matchedSubscription = sub;
          break;
        }
      }

      const currentPage = result.meta?.page?.currentPage;
      const lastPage = result.meta?.page?.lastPage;
      const hasNextPage = currentPage && lastPage && currentPage < lastPage;

      if (matchedSubscription || !hasNextPage) break;
      page++;
    }

    if (!matchedSubscription) {
      return new Response(
        JSON.stringify({ message: "Subscription not found" }),
        {
          headers: { "Content-Type": "application/json" },
          status: 404,
        }
      );
    }

    const attr = matchedSubscription.attributes;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    // 사용자 정보 업데이트
    const { error } = await supabase
      .from("users")
      .update({
        subscription: matchedSubscription,
        lemon_squeezy_customer_id: matchedSubscription.attributes.customer_id,
      })
      .eq("id", userId);

    if (error) {
      console.error("Error updating user:", error);
      return new Response("Failed to update user", { status: 500 });
    }

    return new Response(
      JSON.stringify({
        subscription_id: matchedSubscription.id,
        customer_id: attr.customer_id,
        status: attr.status,
        product_name: attr.product_name,
        ends_at: attr.ends_at,
        renews_at: attr.renews_at,
        created_at: attr.created_at,
        updated_at: attr.updated_at,
        test_mode: attr.test_mode,
        urls: attr.urls,
      }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (e) {
    console.error("Error:", e);
    return new Response("Internal server error", { status: 500 });
  }
});
