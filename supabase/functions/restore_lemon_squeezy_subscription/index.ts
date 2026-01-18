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

    // Check if we need to add credits for active subscription
    const variantId = String(matchedSubscription.attributes?.variant_id);
    const status = matchedSubscription.attributes?.status;
    const isActive = status === 'active' || status === 'on_trial';

    // Ultra Plan variant IDs (Test & Production)
    const ultraPlanVariantIds = ['1139396', '1139389'];
    // Pro Plan variant IDs (Test & Production)
    const proPlanVariantIds = ['915989', '921376', '881561', '921377'];

    const isUltraPlan = ultraPlanVariantIds.includes(variantId);
    const isProPlan = proPlanVariantIds.includes(variantId);

    // Get current user data to check if credits need to be added
    const { data: userData, error: userError } = await supabase
      .from("users")
      .select("ai_credits, ai_credits_updated_at")
      .eq("id", userId)
      .single();

    if (userError) {
      console.error("Error fetching user data:", userError);
      return new Response("Failed to fetch user data", { status: 500 });
    }

    // Determine if we should add credits
    let shouldAddCredits = false;
    let planType: 'ultra' | 'pro' | null = null;

    if ((isUltraPlan || isProPlan) && isActive) {
      const lastCreditsAddedAt = userData?.ai_credits_updated_at;
      const renewsAt = matchedSubscription.attributes?.renews_at;

      if (renewsAt) {
        const renewsDate = new Date(renewsAt);
        const renewsYearMonth = `${renewsDate.getFullYear()}-${String(renewsDate.getMonth() + 1).padStart(2, '0')}`;

        if (lastCreditsAddedAt) {
          const lastAddedDate = new Date(lastCreditsAddedAt);
          const lastAddedYearMonth = `${lastAddedDate.getFullYear()}-${String(lastAddedDate.getMonth() + 1).padStart(2, '0')}`;

          // Only add credits if this is a different billing period
          if (renewsYearMonth !== lastAddedYearMonth) {
            shouldAddCredits = true;
            planType = isUltraPlan ? 'ultra' : 'pro';
            console.log(`Restore: Will add credits. Current period: ${renewsYearMonth}, Last added: ${lastAddedYearMonth}`);
          } else {
            console.log(`Restore: Credits already added for period ${renewsYearMonth}. Skipping.`);
          }
        } else {
          // No credits ever added, add them now
          shouldAddCredits = true;
          planType = isUltraPlan ? 'ultra' : 'pro';
          console.log(`Restore: First time adding credits for ${planType} plan`);
        }
      }
    }

    // Update subscription
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

    // Add credits if needed
    if (shouldAddCredits && planType) {
      const currentCredits = userData?.ai_credits || 0;
      let planCredits: number;
      let planTokens: number;
      let planName: string;

      if (planType === 'ultra') {
        planCredits = 12.0; // 600K tokens = $12
        planTokens = 600000;
        planName = "Ultra Plan";
      } else {
        planCredits = 2.0; // 100K tokens = $2
        planTokens = 100000;
        planName = "Pro Plan";
      }

      const newCredits = currentCredits + planCredits;

      const { error: creditsError } = await supabase
        .from("users")
        .update({
          ai_credits: newCredits,
          ai_credits_updated_at: new Date().toISOString(),
        })
        .eq("id", userId);

      if (creditsError) {
        console.error("Error updating credits during restore:", creditsError);
      } else {
        console.log(`✓ Restore: Added ${planCredits} credits (${planTokens} tokens) for ${planName}. User: ${userId}, New total: ${newCredits}`);

        // Save log
        const { error: logError } = await supabase
          .from("ai_api_usage_logs")
          .insert({
            id: crypto.randomUUID(),
            user_id: userId,
            api_provider: "lemon_squeezy",
            model: planType === 'ultra' ? "ultra_plan" : "pro_plan",
            function_name: "subscription_restored",
            prompt_tokens: 0,
            completion_tokens: 0,
            total_tokens: planTokens,
            credits_used: planCredits,
            used_user_api_key: false,
            created_at: new Date().toISOString(),
          });

        if (logError) {
          console.error("Error saving restore credit log:", logError);
        }
      }
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
