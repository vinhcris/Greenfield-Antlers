-- Individual profile data: payments are read from fund_transactions.
-- This table stores goals and assists per member per match.
INSERT INTO members (name, password, is_admin, is_gk)
VALUES ('Đức Minh', '123456', false, false)
ON CONFLICT (name) DO NOTHING;

CREATE TABLE IF NOT EXISTS member_match_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id uuid NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  member_name text NOT NULL,
  goals integer NOT NULL DEFAULT 0 CHECK (goals >= 0),
  assists integer NOT NULL DEFAULT 0 CHECK (assists >= 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (match_id, member_name)
);

ALTER TABLE member_match_stats ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_select_member_match_stats" ON member_match_stats;
CREATE POLICY "anon_select_member_match_stats" ON member_match_stats FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "anon_insert_member_match_stats" ON member_match_stats;
CREATE POLICY "anon_insert_member_match_stats" ON member_match_stats FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "anon_update_member_match_stats" ON member_match_stats;
CREATE POLICY "anon_update_member_match_stats" ON member_match_stats FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "anon_delete_member_match_stats" ON member_match_stats;
CREATE POLICY "anon_delete_member_match_stats" ON member_match_stats FOR DELETE TO anon, authenticated USING (true);

ALTER PUBLICATION supabase_realtime ADD TABLE member_match_stats;
