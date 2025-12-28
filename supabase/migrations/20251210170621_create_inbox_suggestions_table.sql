-- Create inbox_suggestions table for caching AI-generated inbox suggestions
CREATE TABLE IF NOT EXISTS public.inbox_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  inbox_id TEXT NOT NULL,
  summary TEXT,
  urgency TEXT NOT NULL,
  reason TEXT NOT NULL,
  date_type TEXT,
  reasoned_body TEXT,
  conversation_summary TEXT,
  target_date TIMESTAMPTZ,
  duration INTEGER,
  is_asap BOOLEAN,
  is_date_only BOOLEAN,
  project_id TEXT,
  estimated_effort INTEGER,
  sender_name TEXT,
  priority_score INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_user_inbox UNIQUE (user_id, inbox_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_inbox_suggestions_user_id ON public.inbox_suggestions(user_id);
CREATE INDEX IF NOT EXISTS idx_inbox_suggestions_inbox_id ON public.inbox_suggestions(inbox_id);
CREATE INDEX IF NOT EXISTS idx_inbox_suggestions_created_at ON public.inbox_suggestions(created_at);

-- Enable RLS
ALTER TABLE public.inbox_suggestions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only read their own suggestions
CREATE POLICY "Users can read their own inbox suggestions"
  ON public.inbox_suggestions
  FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own suggestions
CREATE POLICY "Users can insert their own inbox suggestions"
  ON public.inbox_suggestions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own suggestions
CREATE POLICY "Users can update their own inbox suggestions"
  ON public.inbox_suggestions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own suggestions
CREATE POLICY "Users can delete their own inbox suggestions"
  ON public.inbox_suggestions
  FOR DELETE
  USING (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_inbox_suggestions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on row update
CREATE TRIGGER update_inbox_suggestions_updated_at
  BEFORE UPDATE ON public.inbox_suggestions
  FOR EACH ROW
  EXECUTE FUNCTION update_inbox_suggestions_updated_at();

-- Function to delete expired suggestions (older than 30 days)
CREATE OR REPLACE FUNCTION cleanup_expired_inbox_suggestions()
RETURNS void AS $$
BEGIN
  DELETE FROM public.inbox_suggestions
  WHERE created_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a scheduled job to clean up expired suggestions daily
-- Note: This requires pg_cron extension. If not available, use Supabase Edge Functions or external cron job.
-- For now, we'll create the function and document that it should be called periodically.
COMMENT ON FUNCTION cleanup_expired_inbox_suggestions() IS 'Deletes inbox suggestions older than 30 days. Should be called daily via cron job or Supabase Edge Function.';

