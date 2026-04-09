-- migrate:up

CREATE TABLE program_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(20) NOT NULL UNIQUE
);

-- migrate:down

DROP TABLE program_types;