-- 📁 migrations/XXXXXXXXXXXXXX_add_oauth_fields_to_users.sql
-- migrate:up

-- Agregar nuevas columnas
ALTER TABLE users ADD COLUMN provider VARCHAR(20);
ALTER TABLE users ADD COLUMN uid VARCHAR(255);
ALTER TABLE users ADD COLUMN google_token TEXT;
ALTER TABLE users ADD COLUMN google_refresh_token TEXT;
ALTER TABLE users ADD COLUMN last_login_at DATETIME;

-- SQLite no soporta CREATE INDEX después de ALTER TABLE en la misma transacción?
-- Crear índices (SQLite soporta índices normales, NO soporta CREATE UNIQUE INDEX con NULLs)
CREATE INDEX idx_users_provider ON users(provider);
CREATE INDEX idx_users_uid ON users(uid);
CREATE INDEX idx_users_last_login_at ON users(last_login_at);
CREATE INDEX idx_users_provider_uid ON users(provider, uid);

-- migrate:down

-- SQLite no soporta DROP INDEX directamente, hay que usar DROP INDEX si existe
DROP INDEX IF EXISTS idx_users_provider;
DROP INDEX IF EXISTS idx_users_uid;
DROP INDEX IF EXISTS idx_users_last_login_at;
DROP INDEX IF EXISTS idx_users_provider_uid;

-- SQLite NO soporta DROP COLUMN directamente
-- Hay que recrear la tabla sin las columnas
-- Migrar datos a tabla temporal y recrear

CREATE TABLE users_temp (
  id INTEGER PRIMARY KEY,
  username VARCHAR(20),
  email VARCHAR(40),
  password_digest VARCHAR(80),
  image_url VARCHAR(255),
  active BOOLEAN,
  created_at DATETIME,
  updated_at DATETIME
);

INSERT INTO users_temp SELECT 
  id, username, email, password_digest, image_url, active, created_at, updated_at 
FROM users;

DROP TABLE users;
ALTER TABLE users_temp RENAME TO users;