-- Change project_id from UUID to TEXT in agent_chat_history table
-- This allows storing project identifiers that are not UUIDs (e.g., color codes)

-- Drop the foreign key constraint first
ALTER TABLE public.agent_chat_history 
  DROP CONSTRAINT IF EXISTS agent_chat_history_project_id_fkey;

-- Drop the index that uses project_id
DROP INDEX IF EXISTS idx_agent_chat_history_project_id;
DROP INDEX IF EXISTS idx_agent_chat_history_user_project_updated;

-- Change the column type from UUID to TEXT
ALTER TABLE public.agent_chat_history 
  ALTER COLUMN project_id TYPE TEXT USING project_id::TEXT;

-- Recreate the index
CREATE INDEX IF NOT EXISTS idx_agent_chat_history_project_id 
  ON public.agent_chat_history(project_id) 
  WHERE project_id IS NOT NULL;

-- Recreate the composite index
CREATE INDEX IF NOT EXISTS idx_agent_chat_history_user_project_updated 
  ON public.agent_chat_history(user_id, project_id, updated_at DESC);

