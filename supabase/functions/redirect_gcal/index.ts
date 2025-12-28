
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  const code = req.url.split("code=")[1].split("&")[0];
  const redirectUrl = `com.wavetogether.fillin://google?code=${code}`;
  const urlEncodedRedirectUrl = encodeURIComponent(redirectUrl);
  return Response.redirect(
    `https://app.taskey.work/integration?provider=${encodeURIComponent('Google Calendar')}&icon=https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo//gcal.png&href=${urlEncodedRedirectUrl}`
  );
});
