-- ═══════════════════════════════════════════════════════════════════════
--  FOCUS ENGINE — Supabase Schema
--  Run this in the Supabase SQL Editor to create all required tables
-- ═══════════════════════════════════════════════════════════════════════

-- Study Days
CREATE TABLE IF NOT EXISTS study_days (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  date TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Study Tasks
CREATE TABLE IF NOT EXISTS study_tasks (
  id TEXT PRIMARY KEY,
  day_id TEXT NOT NULL REFERENCES study_days(id) ON DELETE CASCADE,
  subject TEXT NOT NULL,
  topic TEXT NOT NULL,
  estimated_minutes INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Focus Sessions (progress / analytics)
CREATE TABLE IF NOT EXISTS focus_sessions (
  id TEXT PRIMARY KEY,
  task_id TEXT,
  subject TEXT,
  topic TEXT,
  mode TEXT DEFAULT 'full',
  duration INTEGER DEFAULT 0,
  date TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Question Analytics (per-session question timing data, stored as JSON array)
CREATE TABLE IF NOT EXISTS question_analytics (
  id TEXT PRIMARY KEY,
  "sessionId" TEXT,
  subject TEXT,
  topic TEXT,
  date TEXT,
  questions JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Personal Tasks
CREATE TABLE IF NOT EXISTS personal_tasks (
  id TEXT PRIMARY KEY,
  text TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  date TEXT,
  frequency TEXT DEFAULT 'once',
  priority TEXT DEFAULT 'none',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Push Subscriptions
CREATE TABLE IF NOT EXISTS push_subscriptions (
  endpoint TEXT PRIMARY KEY,
  p256dh TEXT,
  auth TEXT,
  user_id TEXT DEFAULT 'anonymous',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_study_tasks_day_id ON study_tasks(day_id);
CREATE INDEX IF NOT EXISTS idx_focus_sessions_date ON focus_sessions(date);
CREATE INDEX IF NOT EXISTS idx_focus_sessions_task_id ON focus_sessions(task_id);
CREATE INDEX IF NOT EXISTS idx_question_analytics_session_id ON question_analytics("sessionId");
CREATE INDEX IF NOT EXISTS idx_personal_tasks_date ON personal_tasks(date);

-- Enable Row Level Security (optional — adjust policies as needed)
ALTER TABLE study_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE focus_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

-- Allow public access (for anon key usage)
-- ⚠️ WARNING: These policies allow unrestricted access. For production,
-- replace with user-scoped policies tied to auth.uid() or similar.
CREATE POLICY "Allow all access" ON study_days FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON study_tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON focus_sessions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON question_analytics FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON personal_tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all access" ON push_subscriptions FOR ALL USING (true) WITH CHECK (true);
