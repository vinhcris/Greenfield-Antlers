/*
# Greenfield Antlers - Full Schema with RLS

## Overview
Creates the complete database schema for the Greenfield Antlers football team management app.
This is a shared-data app (all members see all data) with a custom login flow that validates
against a `members` table — no Supabase Auth is used. The frontend uses the anon key, so all
policies are scoped to `anon, authenticated` with `USING (true)` since the data is intentionally
shared among all team members.

## New Tables

1. **members** — 24 team members with passwords and admin flags
   - `id` (uuid, PK)
   - `name` (text, unique, not null) — display name
   - `password` (text, not null) — default '123456', changeable per-member
   - `is_admin` (boolean, default false) — admin/captain flag
   - `is_gk` (boolean, default false) — goalkeeper flag
   - `created_at` (timestamptz)

2. **matches** — upcoming match events (single active row at a time)
   - `id` (uuid, PK)
   - `match_date` (timestamptz, not null) — when the match happens
   - `description` (text) — location / opponent notes
   - `created_at` (timestamptz)

3. **votes** — per-member vote status for a match
   - `id` (uuid, PK)
   - `match_id` (uuid, FK to matches, not null)
   - `member_name` (text, not null) — which member voted
   - `status` (text, not null) — 'yes' | 'maybe' | 'no'
   - `created_at` (timestamptz)
   - Unique constraint on (match_id, member_name)

4. **fund_transactions** — income/expense ledger
   - `id` (uuid, PK)
   - `type` (text, not null) — 'income' | 'expense'
   - `member_name` (text) — who paid/received (null for expenses)
   - `amount` (bigint, not null) — amount in VND
   - `note` (text) — reason/description
   - `created_at` (timestamptz)
   - `created_by` (text) — who recorded the transaction

## Security
- RLS enabled on all tables.
- All policies use `TO anon, authenticated` with `USING (true)` / `WITH CHECK (true)`
  because this is a shared-data team app — every member sees and can contribute to all data.
  The login gate is enforced in the frontend by validating against the `members` table.
*/

-- Members table
CREATE TABLE IF NOT EXISTS members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  password text NOT NULL DEFAULT '123456',
  is_admin boolean NOT NULL DEFAULT false,
  is_gk boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_members" ON members;
CREATE POLICY "anon_select_members" ON members FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_members" ON members;
CREATE POLICY "anon_insert_members" ON members FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_members" ON members;
CREATE POLICY "anon_update_members" ON members FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_members" ON members;
CREATE POLICY "anon_delete_members" ON members FOR DELETE
  TO anon, authenticated USING (true);

-- Matches table
CREATE TABLE IF NOT EXISTS matches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  match_date timestamptz NOT NULL,
  description text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_matches" ON matches;
CREATE POLICY "anon_select_matches" ON matches FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_matches" ON matches;
CREATE POLICY "anon_insert_matches" ON matches FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_matches" ON matches;
CREATE POLICY "anon_update_matches" ON matches FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_matches" ON matches;
CREATE POLICY "anon_delete_matches" ON matches FOR DELETE
  TO anon, authenticated USING (true);

-- Votes table
CREATE TABLE IF NOT EXISTS votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id uuid NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  member_name text NOT NULL,
  status text NOT NULL CHECK (status IN ('yes', 'maybe', 'no')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(match_id, member_name)
);

ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_votes" ON votes;
CREATE POLICY "anon_select_votes" ON votes FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_votes" ON votes;
CREATE POLICY "anon_insert_votes" ON votes FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_votes" ON votes;
CREATE POLICY "anon_update_votes" ON votes FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_votes" ON votes;
CREATE POLICY "anon_delete_votes" ON votes FOR DELETE
  TO anon, authenticated USING (true);

-- Fund transactions table
CREATE TABLE IF NOT EXISTS fund_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL CHECK (type IN ('income', 'expense')),
  member_name text DEFAULT '',
  amount bigint NOT NULL,
  note text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  created_by text DEFAULT ''
);

ALTER TABLE fund_transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_fund" ON fund_transactions;
CREATE POLICY "anon_select_fund" ON fund_transactions FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_fund" ON fund_transactions;
CREATE POLICY "anon_insert_fund" ON fund_transactions FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_fund" ON fund_transactions;
CREATE POLICY "anon_update_fund" ON fund_transactions FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_fund" ON fund_transactions;
CREATE POLICY "anon_delete_fund" ON fund_transactions FOR DELETE
  TO anon, authenticated USING (true);

-- Enable realtime for all tables
ALTER PUBLICATION supabase_realtime ADD TABLE members;
ALTER PUBLICATION supabase_realtime ADD TABLE matches;
ALTER PUBLICATION supabase_realtime ADD TABLE votes;
ALTER PUBLICATION supabase_realtime ADD TABLE fund_transactions;
