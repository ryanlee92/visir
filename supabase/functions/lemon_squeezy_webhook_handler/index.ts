// functions/lemon_webhook/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

serve(async (req) => {
  const rawBody = await req.text();
  const payload = JSON.parse(rawBody); // <- 이걸로 한 번만

  const expectedSig = req.headers.get("X-Signature")!;
  const secret = Deno.env.get("LEMON_SQUEEZY_WEBHOOK_SIGNING_KEY")!;

  // HMAC-SHA256 해시 계산
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const signatureBytes = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(rawBody)
  );
  const signatureHex = Array.from(new Uint8Array(signatureBytes))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  if (signatureHex !== expectedSig) {
    return new Response("Invalid signature", { status: 401 });
  }

  const userId = payload.meta?.custom_data?.user_id;
  const eventName = payload.meta?.event_name;

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

  // 일회성 결제 (Additional Token 구매) 처리
  const isOrderCreated = eventName === 'order_created';
  
  if (isOrderCreated) {
    console.log('Order created event received. Payload:', JSON.stringify(payload, null, 2));
    console.log('User ID:', userId);
    
    // Order 이벤트의 경우 payload 구조가 다름
    const orderData = payload.data;
    console.log('Order data:', JSON.stringify(orderData, null, 2));
    
    // 레몬 스퀴지 order_created 이벤트 구조:
    // - first_order_item에 첫 번째 주문 항목 정보가 포함됨
    // - order_items는 included 배열에 포함될 수 있음
    let orderItems: any[] = [];
    
    // 방법 1: first_order_item 사용 (가장 간단하고 확실한 방법)
    if (orderData?.attributes?.first_order_item) {
      orderItems = [orderData.attributes.first_order_item];
      console.log('Found first_order_item:', orderItems.length);
    }
    
    // 방법 2: included 배열에서 order-items 타입 찾기
    if (orderItems.length === 0 && payload.included) {
      orderItems = payload.included.filter((item: any) => item.type === 'order-items');
      console.log('Found order_items in included:', orderItems.length);
    }
    
    // 방법 3: relationships.order_items 확인
    if (orderItems.length === 0 && orderData?.relationships?.order_items?.data) {
      const orderItemIds = orderData.relationships.order_items.data.map((item: any) => item.id);
      if (payload.included) {
        orderItems = payload.included.filter((item: any) => 
          item.type === 'order-items' && orderItemIds.includes(item.id)
        );
        console.log('Found order_items via relationships:', orderItems.length);
      }
    }
    
    console.log('Final orderItems count:', orderItems.length);
    
    // Token Package Variant IDs (Test & Production)
    const variantToAmount: { [key: string]: number } = {
      // Test Mode
      '1139724': 5,
      '1139728': 10,
      '1139729': 20,
      '1139731': 50,
      // Production Mode
      '1139736': 5,
      '1139737': 10,
      '1139738': 20,
      '1139739': 50,
    };
    
    // UI와 동일한 토큰 계산 로직 (AiPricingCalculator.calculateTokensFromPackage와 동일)
    const baseTokenPrice = 0.00002; // 토큰당 기본 가격 ($)
    
    // 패키지 금액별 토큰 수 매핑 (UI에 표시되는 것과 동일하게 하드코딩)
    // $5: 5 / (0.00002 * 1.5) = 166,667 tokens
    // $10: 10 / (0.00002 * 1.4) = 357,143 tokens
    // $20: 20 / (0.00002 * 1.3) = 769,231 tokens
    // $50: (50 / (0.00002 * 1.2)) * 1.25 = 2,604,167 tokens
    const tokensByAmount: { [key: number]: number } = {
      5: 166667,
      10: 357143,
      20: 769231,
      50: 2604167,
    };
    
    let totalTokensToAdd = 0;
    let totalCreditsToAdd = 0;
    
    // 주문 항목에서 토큰 패키지 찾기
    for (const item of orderItems) {
      console.log('Processing order item:', JSON.stringify(item, null, 2));
      
      // variant_id 추출 (여러 방법 시도)
      let itemVariantId: string | null = null;
      
      // 방법 1: first_order_item의 variant_id (직접 속성)
      if (item.variant_id) {
        itemVariantId = item.variant_id.toString();
      }
      // 방법 2: attributes.variant_id 확인
      else if (item.attributes?.variant_id) {
        itemVariantId = item.attributes.variant_id.toString();
      }
      // 방법 3: relationships.variant.data.id 확인
      else if (item.relationships?.variant?.data?.id) {
        itemVariantId = item.relationships.variant.data.id.toString();
      }
      // 방법 4: included 배열에서 variant 찾기
      else if (item.relationships?.variant?.data?.id && payload.included) {
        const variantId = item.relationships.variant.data.id;
        const variant = payload.included.find((inc: any) => 
          inc.type === 'variants' && inc.id === variantId
        );
        if (variant) {
          itemVariantId = variant.id.toString();
        }
      }
      
      console.log('Extracted variant_id:', itemVariantId);
      
      if (!itemVariantId) {
        console.log('Order item missing variant_id. Item structure:', JSON.stringify(item, null, 2));
        continue;
      }
      
      // Variant ID로 패키지 금액 확인
      const packageAmount = variantToAmount[itemVariantId];
      
      if (packageAmount && tokensByAmount[packageAmount]) {
        const tokens = tokensByAmount[packageAmount];
        totalTokensToAdd += tokens;
        // 크레딧은 실제 지급된 토큰 수를 baseTokenPrice로 환산한 값으로 저장
        // 이렇게 하면 나중에 크레딧을 토큰으로 환산했을 때 실제 지급된 토큰 수와 일치함
        const credits = tokens * baseTokenPrice;
        totalCreditsToAdd += credits;
        console.log(`✓ Token package detected: $${packageAmount}, Adding ${tokens} tokens ($${credits.toFixed(4)} credits). Variant: ${itemVariantId}`);
      } else {
        console.log(`✗ Unknown variant ID: ${itemVariantId}. Available variants:`, Object.keys(variantToAmount));
      }
    }
    
    console.log(`Total tokens to add: ${totalTokensToAdd}, Total credits to add: ${totalCreditsToAdd}, User ID: ${userId}`);
    
    // 크레딧 추가
    if (totalCreditsToAdd > 0 && userId) {
      // 기존 크레딧 조회
      const { data: userData, error: userError } = await supabase
        .from("users")
        .select("ai_credits")
        .eq("id", userId)
        .single();

      if (userError) {
        console.error("Error fetching user credits:", userError);
        return new Response("Failed to fetch user credits", { status: 500 });
      }

      const currentCredits = userData?.ai_credits || 0;
      const newCredits = currentCredits + totalCreditsToAdd;

      // 디버깅을 위한 상세 로그
      console.log(`Credit update details:`);
      console.log(`  Current credits: $${currentCredits.toFixed(4)}`);
      console.log(`  Credits to add: $${totalCreditsToAdd.toFixed(4)}`);
      console.log(`  New credits: $${newCredits.toFixed(4)}`);
      console.log(`  Tokens to add: ${totalTokensToAdd.toLocaleString()}`);
      console.log(`  Expected tokens from new credits: ${Math.round(newCredits / baseTokenPrice).toLocaleString()}`);

      // 크레딧 업데이트
      const { error: creditsError } = await supabase
        .from("users")
        .update({
          ai_credits: newCredits,
          ai_credits_updated_at: new Date().toISOString(),
        })
        .eq("id", userId);

      if (creditsError) {
        console.error("Error updating credits:", creditsError);
        return new Response("Failed to update credits", { status: 500 });
      }

      console.log(`✓ Successfully added ${totalCreditsToAdd.toFixed(4)} credits (${totalTokensToAdd.toLocaleString()} tokens) for token purchase. User: ${userId}, Order: ${orderData?.id}`);
      
      // 구매 로그 저장 (UI에 표시된 토큰 수와 동일하게 저장)
      const purchaseTokens = totalTokensToAdd;
      const { error: logError } = await supabase
        .from("ai_api_usage_logs")
        .insert({
          id: crypto.randomUUID(),
          user_id: userId,
          api_provider: "lemon_squeezy",
          model: "token_purchase",
          function_name: "credit_purchase",
          prompt_tokens: 0,
          completion_tokens: 0,
          total_tokens: purchaseTokens,
          credits_used: totalCreditsToAdd,
          used_user_api_key: false,
          created_at: new Date().toISOString(),
        });

      if (logError) {
        console.error("Error saving purchase log:", logError);
        // 로그 저장 실패해도 크레딧 추가는 성공했으므로 계속 진행
      } else {
        console.log(`Saved purchase log for ${totalCreditsToAdd} credits (${purchaseTokens} tokens)`);
      }
    } else {
      if (!userId) {
        console.error('User ID is missing in order_created event');
      }
      if (totalCreditsToAdd === 0) {
        console.error('No credits to add. Order items may not match token package variants.');
      }
    }
    
    return new Response("OK", { status: 200 });
  }

  // Ultra Plan variant IDs (Test & Production)
  const ultraPlanVariantIds = ['1139396', '1139389']; // Test: 1139396, Production: 1139389
  const variantId = payload.data?.attributes?.variant_id?.toString();
  const isUltraPlan = variantId && ultraPlanVariantIds.includes(variantId);
  
  // 구독 상태 확인
  const subscriptionStatus = payload.data?.attributes?.status;
  const isActiveOrCreated = subscriptionStatus === 'active' || subscriptionStatus === 'on_trial';
  const isSubscriptionCreated = eventName === 'subscription_created';
  const isSubscriptionUpdated = eventName === 'subscription_updated';

  // Ultra Plan 구독 생성 또는 월간 갱신 시 500K 토큰 ($10 크레딧) 추가 여부 확인
  let shouldAddCredits = false;
  
  if (isUltraPlan && isActiveOrCreated) {
    if (isSubscriptionCreated) {
      // 구독 생성 시 항상 토큰 추가
      shouldAddCredits = true;
    } else if (isSubscriptionUpdated) {
      // 구독 업데이트 시: 이전 구독 정보와 마지막 크레딧 추가 날짜를 가져와서 갱신 여부 확인
      const { data: userData, error: userError } = await supabase
        .from("users")
        .select("subscription, ai_credits_updated_at")
        .eq("id", userId)
        .single();

      if (userError) {
        console.error("Error fetching user subscription:", userError);
        // 에러가 나도 구독 정보는 업데이트해야 하므로 계속 진행
      } else {
        const oldSubscription = userData?.subscription;
        const newRenewsAt = payload.data?.attributes?.renews_at;
        const oldRenewsAt = oldSubscription?.attributes?.renews_at;
        const lastCreditsAddedAt = userData?.ai_credits_updated_at;

        // renews_at이 변경되었고, 새로운 갱신일이 이전 갱신일보다 미래인 경우
        if (newRenewsAt && oldRenewsAt) {
          const newRenewsDate = new Date(newRenewsAt);
          const oldRenewsDate = new Date(oldRenewsAt);
          
          // 새로운 갱신일이 이전 갱신일보다 미래이고, 최소 25일 이상 차이가 나면 월간 갱신으로 간주
          const daysDifference = (newRenewsDate.getTime() - oldRenewsDate.getTime()) / (1000 * 60 * 60 * 24);
          
          if (daysDifference >= 25 && daysDifference <= 35) {
            // 중복 추가 방지: 새로운 renews_at의 년-월이 마지막 크레딧 추가 년-월과 다른 경우에만 추가
            const newRenewsYearMonth = `${newRenewsDate.getFullYear()}-${String(newRenewsDate.getMonth() + 1).padStart(2, '0')}`;
            
            if (lastCreditsAddedAt) {
              const lastAddedDate = new Date(lastCreditsAddedAt);
              const lastAddedYearMonth = `${lastAddedDate.getFullYear()}-${String(lastAddedDate.getMonth() + 1).padStart(2, '0')}`;
              
              // 새로운 갱신 월이 마지막 추가 월과 다를 때만 추가
              if (newRenewsYearMonth !== lastAddedYearMonth) {
                shouldAddCredits = true;
                console.log(`Monthly renewal detected. Old renews_at: ${oldRenewsAt}, New renews_at: ${newRenewsAt}, Days difference: ${daysDifference}, New month: ${newRenewsYearMonth}, Last added month: ${lastAddedYearMonth}`);
              } else {
                console.log(`Credits already added for this renewal month (${newRenewsYearMonth}). Skipping.`);
              }
            } else {
              // 마지막 추가 날짜가 없으면 추가 (첫 구독)
              shouldAddCredits = true;
              console.log(`Monthly renewal detected (first time). New renews_at: ${newRenewsAt}`);
            }
          }
        } else if (newRenewsAt && !oldRenewsAt) {
          // 이전 갱신일이 없고 새로운 갱신일이 있으면 첫 구독 또는 재활성화
          // 하지만 마지막 추가 날짜를 확인하여 중복 방지
          if (lastCreditsAddedAt) {
            const newRenewsDate = new Date(newRenewsAt);
            const lastAddedDate = new Date(lastCreditsAddedAt);
            const newRenewsYearMonth = `${newRenewsDate.getFullYear()}-${String(newRenewsDate.getMonth() + 1).padStart(2, '0')}`;
            const lastAddedYearMonth = `${lastAddedDate.getFullYear()}-${String(lastAddedDate.getMonth() + 1).padStart(2, '0')}`;
            
            if (newRenewsYearMonth !== lastAddedYearMonth) {
              shouldAddCredits = true;
              console.log(`Subscription reactivated. New renews_at: ${newRenewsAt}, New month: ${newRenewsYearMonth}, Last added month: ${lastAddedYearMonth}`);
            } else {
              console.log(`Credits already added for this month (${newRenewsYearMonth}). Skipping reactivation credits.`);
            }
          } else {
            shouldAddCredits = true;
            console.log(`First subscription or reactivation. New renews_at: ${newRenewsAt}`);
          }
        }
      }
    }
  }

  // 사용자 정보 업데이트
  const { error: updateError } = await supabase
    .from("users")
    .update({
      subscription: payload.data,
      lemon_squeezy_customer_id: payload.data.attributes.customer_id,
    })
    .eq("id", userId);

  if (updateError) {
    console.error("Error updating user:", updateError);
    return new Response("Failed to update user", { status: 500 });
  }

  // Ultra Plan 구독 생성 또는 월간 갱신 시 500K 토큰 ($10 크레딧) 추가
  if (shouldAddCredits) {
    // 기존 크레딧 조회
    const { data: userData, error: userError } = await supabase
      .from("users")
      .select("ai_credits")
      .eq("id", userId)
      .single();

    if (userError) {
      console.error("Error fetching user credits:", userError);
      return new Response("Failed to fetch user credits", { status: 500 });
    }

    const currentCredits = userData?.ai_credits || 0;
    const ultraPlanCredits = 10.0; // 500K tokens = $10
    const newCredits = currentCredits + ultraPlanCredits;

    // 크레딧 업데이트
    const { error: creditsError } = await supabase
      .from("users")
      .update({
        ai_credits: newCredits,
        ai_credits_updated_at: new Date().toISOString(),
      })
      .eq("id", userId);

    if (creditsError) {
      console.error("Error updating credits:", creditsError);
      return new Response("Failed to update credits", { status: 500 });
    }

    const eventType = isSubscriptionCreated ? "subscription creation" : "monthly renewal";
    console.log(`Added ${ultraPlanCredits} credits (500K tokens) for Ultra Plan ${eventType}. User: ${userId}, Variant: ${variantId}`);
    
    // Ultra Plan 구독 크레딧 추가 로그 저장
    const ultraPlanTokens = 500000; // 500K tokens
    const { error: logError } = await supabase
      .from("ai_api_usage_logs")
      .insert({
        id: crypto.randomUUID(),
        user_id: userId,
        api_provider: "lemon_squeezy",
        model: "ultra_plan",
        function_name: isSubscriptionCreated ? "subscription_created" : "subscription_renewal",
        prompt_tokens: 0,
        completion_tokens: 0,
        total_tokens: ultraPlanTokens,
        credits_used: ultraPlanCredits,
        used_user_api_key: false,
        created_at: new Date().toISOString(),
      });

    if (logError) {
      console.error("Error saving Ultra Plan credit log:", logError);
      // 로그 저장 실패해도 크레딧 추가는 성공했으므로 계속 진행
    } else {
      console.log(`Saved Ultra Plan credit log for ${ultraPlanCredits} credits (${ultraPlanTokens} tokens)`);
    }
  }

  return new Response("OK", { status: 200 });
});
