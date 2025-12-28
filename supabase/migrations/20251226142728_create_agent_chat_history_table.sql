-- Create agent_chat_history table for storing agent conversation history
CREATE TABLE IF NOT EXISTS public.agent_chat_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
  messages JSONB NOT NULL DEFAULT '[]'::jsonb,
  action_type TEXT,
  conversation_summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_agent_chat_history_user_id ON public.agent_chat_history(user_id);
CREATE INDEX IF NOT EXISTS idx_agent_chat_history_project_id ON public.agent_chat_history(project_id);
CREATE INDEX IF NOT EXISTS idx_agent_chat_history_updated_at ON public.agent_chat_history(updated_at);
CREATE INDEX IF NOT EXISTS idx_agent_chat_history_user_project_updated ON public.agent_chat_history(user_id, project_id, updated_at DESC);

-- Enable RLS
ALTER TABLE public.agent_chat_history ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can read their own chat history
CREATE POLICY "Users can read their own chat history"
  ON public.agent_chat_history
  FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own chat history
CREATE POLICY "Users can insert their own chat history"
  ON public.agent_chat_history
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own chat history
CREATE POLICY "Users can update their own chat history"
  ON public.agent_chat_history
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own chat history
CREATE POLICY "Users can delete their own chat history"
  ON public.agent_chat_history
  FOR DELETE
  USING (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_agent_chat_history_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on row update
CREATE TRIGGER update_agent_chat_history_updated_at
  BEFORE UPDATE ON public.agent_chat_history
  FOR EACH ROW
  EXECUTE FUNCTION update_agent_chat_history_updated_at();

