-- 📁 migrations/XXXXXXXXXXXXXX_add_fields_to_login_logs.sql
-- migrate:up

ALTER TABLE login_logs ADD COLUMN provider VARCHAR(20);
ALTER TABLE login_logs ADD COLUMN user_agent TEXT;

-- migrate:down

-- SQLite
CREATE TABLE login_logs_temp (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  success BOOLEAN,
  ip_address VARCHAR(40),
  created_at DATETIME
);

INSERT INTO login_logs_temp SELECT id, user_id, success, ip_address, created_at FROM login_logs;
DROP TABLE login_logs;
ALTER TABLE login_logs_temp RENAME TO login_logs;