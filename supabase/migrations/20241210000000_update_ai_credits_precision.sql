-- Update ai_credits column to support 4 decimal places
-- This ensures accurate credit storage for token purchases
-- Example: $15.3846 credits for $20 package (769,231 tokens)

ALTER TABLE public.users 
ALTER COLUMN ai_credits TYPE numeric(20, 4);

-- Add comment for documentation
COMMENT ON COLUMN public.users.ai_credits IS 'AI credits in USD. Supports 4 decimal places for accurate token calculations. Example: $15.3846 = 769,231 tokens';

