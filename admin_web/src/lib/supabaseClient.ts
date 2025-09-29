import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = (import.meta.env.VITE_SUPABASE_URL as string) || '';
const SUPABASE_ANON_KEY = (import.meta.env.VITE_SUPABASE_ANON_KEY as string) || '';

export const supabaseConfigured = Boolean(SUPABASE_URL && SUPABASE_ANON_KEY);

if (!supabaseConfigured) {
  // Visible in dev console to help diagnose blank page issues
  // Ensure you create admin_web/.env with VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY
  console.error('Supabase env missing. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY');
}

export const supabase = supabaseConfigured
  ? createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  : ({} as ReturnType<typeof createClient>);


