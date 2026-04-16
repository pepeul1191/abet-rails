CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(128) primary key);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(40) NOT NULL UNIQUE,
  password_digest VARCHAR(80) NOT NULL,
  image_url VARCHAR(255),
  active BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE login_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  success BOOLEAN NOT NULL,
  ip_address VARCHAR(40),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX idx_login_logs_user_id ON login_logs(user_id);
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('20260409125609'),
  ('20260409125616'),
  ('20260416125233');
