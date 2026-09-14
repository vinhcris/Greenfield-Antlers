/*
# Seed Greenfield Antlers Members and Sample Data

## Overview
Inserts the 24 official team members with default password '123456',
marks admins (Tiến Vinh, Khắc Thành) and goalkeepers (Đức Hiếu, Quốc Huy, Quốc An),
creates a sample match, and seeds sample votes + fund transactions.

## Data
- 24 members inserted (idempotent via ON CONFLICT DO NOTHING)
- Admins: Tiến Vinh, Khắc Thành
- Goalkeepers: Đức Hiếu, Quốc Huy, Quốc An
- 1 sample match (next Sunday 19:00)
- 5 sample votes
- 3 sample fund transactions
*/

INSERT INTO members (name, password, is_admin, is_gk) VALUES
  ('Tiến Vinh', '123456', true, false),
  ('Đức Hiếu', '123456', false, true),
  ('Nhật Nam', '123456', false, false),
  ('Thuận Nam', '123456', false, false),
  ('Bảo Hoàng', '123456', false, false),
  ('Hữu Thành', '123456', false, false),
  ('Gia Huy', '123456', false, false),
  ('Minh Quân', '123456', false, false),
  ('Huy Anh', '123456', false, false),
  ('Minh Cường', '123456', false, false),
  ('Hồng Minh', '123456', false, false),
  ('Khánh Duy', '123456', false, false),
  ('Nam Khánh', '123456', false, false),
  ('Quốc Huy', '123456', false, true),
  ('Hải Đăng', '123456', false, false),
  ('Khắc Thành', '123456', true, false),
  ('Tạ Quang Minh', '123456', false, false),
  ('Nguyễn Quang Minh', '123456', false, false),
  ('Quốc An', '123456', false, true),
  ('Trí Thành', '123456', false, false),
  ('Minh Tân', '123456', false, false),
  ('Khánh An', '123456', false, false),
  ('Trung Hiếu', '123456', false, false),
  ('Hải Hà', '123456', false, false)
ON CONFLICT (name) DO NOTHING;

-- Insert a sample match if none exists
INSERT INTO matches (match_date, description)
SELECT
  (date_trunc('week', now()) + interval '7 days')::timestamptz + interval '19 hours',
  'Sân bóng Greenfield — 7h tối'
WHERE NOT EXISTS (SELECT 1 FROM matches);

-- Seed sample votes (idempotent — only if no votes exist)
DO $$
DECLARE
  m_id uuid;
BEGIN
  SELECT id INTO m_id FROM matches ORDER BY created_at DESC LIMIT 1;
  IF m_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM votes) THEN
    INSERT INTO votes (match_id, member_name, status) VALUES
      (m_id, 'Tiến Vinh', 'yes'),
      (m_id, 'Đức Hiếu', 'yes'),
      (m_id, 'Bảo Hoàng', 'yes'),
      (m_id, 'Minh Quân', 'maybe'),
      (m_id, 'Huy Anh', 'no')
    ON CONFLICT (match_id, member_name) DO NOTHING;
  END IF;
END $$;

-- Seed sample fund transactions (idempotent)
INSERT INTO fund_transactions (type, member_name, amount, note, created_by)
SELECT 'income', 'Tiến Vinh', 100000, 'Nộp quỹ tháng 9', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM fund_transactions);

INSERT INTO fund_transactions (type, member_name, amount, note, created_by)
SELECT 'income', 'Nhật Nam', 100000, 'Nộp quỹ tháng 9', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM fund_transactions WHERE member_name = 'Nhật Nam' AND type = 'income');

INSERT INTO fund_transactions (type, member_name, amount, note, created_by)
SELECT 'expense', '', 150000, 'Thuê sân tập', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM fund_transactions WHERE type = 'expense');
