-- Create inbox_conversation_summary table for caching conversation summaries
CREATE TABLE IF NOT EXISTS public.inbox_conversation_summary (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  task_id TEXT,
  event_id TEXT,
  summary TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '2 days'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_user_task_event UNIQUE (user_id, task_id, event_id),
  CONSTRAINT task_or_event_required CHECK (task_id IS NOT NULL OR event_id IS NOT NULL)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_inbox_conversation_summary_user_id ON public.inbox_conversation_summary(user_id);
CREATE INDEX IF NOT EXISTS idx_inbox_conversation_summary_task_id ON public.inbox_conversation_summary(task_id);
CREATE INDEX IF NOT EXISTS idx_inbox_conversation_summary_event_id ON public.inbox_conversation_summary(event_id);
CREATE INDEX IF NOT EXISTS idx_inbox_conversation_summary_expires_at ON public.inbox_conversation_summary(expires_at);

-- Enable RLS
ALTER TABLE public.inbox_conversation_summary ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only read their own conversation summaries
CREATE POLICY "Users can read their own conversation summaries"
  ON public.inbox_conversation_summary
  FOR SELECT
  USING (auth.uid() = user_id AND expires_at > NOW());

-- RLS Policy: Users can insert their own conversation summaries
CREATE POLICY "Users can insert their own conversation summaries"
  ON public.inbox_conversation_summary
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own conversation summaries
CREATE POLICY "Users can update their own conversation summaries"
  ON public.inbox_conversation_summary
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own conversation summaries
CREATE POLICY "Users can delete their own conversation summaries"
  ON public.inbox_conversation_summary
  FOR DELETE
  USING (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_inbox_conversation_summary_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on row update
CREATE TRIGGER update_inbox_conversation_summary_updated_at
  BEFORE UPDATE ON public.inbox_conversation_summary
  FOR EACH ROW
  EXECUTE FUNCTION update_inbox_conversation_summary_updated_at();

-- Function to delete expired conversation summaries (older than expires_at)
CREATE OR REPLACE FUNCTION cleanup_expired_inbox_conversation_summary()
RETURNS void AS $$
BEGIN
  DELETE FROM public.inbox_conversation_summary
  WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a scheduled job to clean up expired summaries daily
-- Note: This requires pg_cron extension. If not available, use Supabase Edge Functions or external cron job.
-- For now, we'll create the function and document that it should be called periodically.
COMMENT ON FUNCTION cleanup_expired_inbox_conversation_summary() IS 'Deletes conversation summaries where expires_at has passed. Should be called daily via cron job or Supabase Edge Function.';


