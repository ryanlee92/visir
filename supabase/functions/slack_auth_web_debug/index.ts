import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  const code = req.url.split("code=")[1].split("&state")[0];

  const response = await fetch("https://slack.com/api/oauth.v2.access", {
    method: "POST",
    body: new URLSearchParams({
      client_id: Deno.env.get("SLACK_CLIENT_ID")!,
      client_secret: Deno.env.get("SLACK_CLIENT_SECRET")!,
      code: code,
      redirect_uri: 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/slack_auth_web_debug',
    }),
  });

  if (response.ok) {
    try {
      const data = await response.json();

      console.log('###### ${data}', data);
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
      console.log('###### ${userProfileData}', userProfileData);
      const email = userProfileData["profile"]["email"];

      return Response.redirect(
        "http://localhost:7357/redirect.html?ok=true&token=" +
          token +
          "&email=" +
          email
      );
    } catch (error) {
      console.log(error);
      return Response.redirect("http://localhost:7357/redirect.html?ok=false");
    }
  } else {
    return Response.redirect("http://localhost:7357/redirect.html?ok=false");
  }
});
