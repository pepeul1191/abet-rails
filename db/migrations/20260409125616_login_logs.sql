-- migrate:up

CREATE TABLE login_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  success BOOLEAN NOT NULL,
  ip_address VARCHAR(40),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_login_logs_user_id ON login_logs(user_id);

-- migrate:down

DROP TABLE IF EXISTS login_logs;