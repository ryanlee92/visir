import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  const code = req.url.split("code=")[1].split("&state")[0];

  const response = await fetch("https://slack.com/api/oauth.v2.access", {
    method: "POST",
    body: new URLSearchParams({
      client_id: Deno.env.get("SLACK_CLIENT_ID")!,
      client_secret: Deno.env.get("SLACK_CLIENT_SECRET")!,
      code: code,
      redirect_uri: "https://azukhxinzrivjforwnsc.supabase.co/functions/v1/slack_auth_dev",
    }),
  });

  if (response.ok) {
    try {
      const data = await response.json();

      console.log(data);
      const token = data["authed_user"]["access_token"];

      const userProfileResponse = await fetch(
        "https://slack.com/api/users.profile.get",
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
        }
      );
      const userProfileData = await userProfileResponse.json();
      const email = userProfileData["profile"]["email"];

      const redirectUrl = `com.wavetogether.fillin.slack://ok?=true&token=${token}&email=${email}`;
      const urlEncodedRedirectUrl = encodeURIComponent(redirectUrl);

      return Response.redirect(
        `https://app.taskey.work/integration?provider=Slack&icon=https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo//slack.png&href=${urlEncodedRedirectUrl}`
      );
    } catch (error) {
      const redirectUrl = `com.wavetogether.fillin.slack://ok?=false`;
      const urlEncodedRedirectUrl = encodeURIComponent(redirectUrl);
      return Response.redirect(
        `https://app.taskey.work/integration/failed?provider=Slack&icon=https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo//slack.png&href=${urlEncodedRedirectUrl}`
      );
    }
  } else {
    const redirectUrl = `com.wavetogether.fillin.slack://failed`;
    const urlEncodedRedirectUrl = encodeURIComponent(redirectUrl);
    return Response.redirect(
      `https://app.taskey.work/integration/failed?provider=Slack&icon=https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo//slack.png&href=${urlEncodedRedirectUrl}`
    );
  }
});
