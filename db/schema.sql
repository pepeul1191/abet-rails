CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(128) primary key);
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(40) NOT NULL UNIQUE,
  password_digest VARCHAR(80) NOT NULL,
  image_url VARCHAR(255),
  active BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
, provider VARCHAR(20), uid VARCHAR(255), google_token TEXT, google_refresh_token TEXT, last_login_at DATETIME);
CREATE TABLE login_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  success BOOLEAN NOT NULL,
  ip_address VARCHAR(40),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP, provider VARCHAR(20), user_agent TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX idx_login_logs_user_id ON login_logs(user_id);
CREATE INDEX idx_users_provider ON users(provider);
CREATE INDEX idx_users_uid ON users(uid);
CREATE INDEX idx_users_last_login_at ON users(last_login_at);
CREATE INDEX idx_users_provider_uid ON users(provider, uid);
CREATE TABLE periods (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(10) NOT NULL
);
CREATE TABLE task_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(25) NOT NULL,
    description VARCHAR(100),
    video_url VARCHAR(255)
);
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(40) NOT NULL,
    description TEXT,
    data TEXT,
    zip_path VARCHAR(255),
    status VARCHAR(20),
    user_id INTEGER NOT NULL, -- Asumo que no debe ser nulo por ser FK
    task_type_id INTEGER NOT NULL,
    period_id INTEGER NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_type_id) REFERENCES task_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (period_id) REFERENCES periods(id) ON DELETE RESTRICT
);
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('20260409125609'),
  ('20260409125616'),
  ('20260416125233'),
  ('20260430132323'),
  ('20260430133116'),
  ('20260522204052'),
  ('20260522204107'),
  ('20260522204115'),
  ('20260522204218'),
  ('20260603013009'),
  ('20260604012322'),
  ('20260604141544');
