import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables. Please check your .env file.');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Generate or retrieve visitor ID from localStorage
export const getVisitorId = (): string => {
  const storageKey = 'visir-visitor-id';
  let visitorId = localStorage.getItem(storageKey);
  
  if (!visitorId) {
    // Generate a simple UUID-like string
    visitorId = 'visitor_' + Date.now() + '_' + Math.random().toString(36).substring(2, 15);
    localStorage.setItem(storageKey, visitorId);
  }
  
  return visitorId;
};

