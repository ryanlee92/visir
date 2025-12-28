-- Create agent_chat_history table
CREATE TABLE IF NOT EXISTS agent_chat_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  messages JSONB NOT NULL DEFAULT '[]'::jsonb,
  action_type TEXT,
  conversation_summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for efficient queries
CREATE INDEX IF NOT EXISTS idx_agent_chat_history_user_project_updated 
  ON agent_chat_history(user_id, project_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_agent_chat_history_user_id 
  ON agent_chat_history(user_id);

CREATE INDEX IF NOT EXISTS idx_agent_chat_history_project_id 
  ON agent_chat_history(project_id) WHERE project_id IS NOT NULL;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_agent_chat_history_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_agent_chat_history_updated_at
  BEFORE UPDATE ON agent_chat_history
  FOR EACH ROW
  EXECUTE FUNCTION update_agent_chat_history_updated_at();

-- Enable Row Level Security
ALTER TABLE agent_chat_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only view their own chat history
CREATE POLICY "Users can view their own chat history"
  ON agent_chat_history
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own chat history
CREATE POLICY "Users can insert their own chat history"
  ON agent_chat_history
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own chat history
CREATE POLICY "Users can update their own chat history"
  ON agent_chat_history
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own chat history
CREATE POLICY "Users can delete their own chat history"
  ON agent_chat_history
  FOR DELETE
  USING (auth.uid() = user_id);

