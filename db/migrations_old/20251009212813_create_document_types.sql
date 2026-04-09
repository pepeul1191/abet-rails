-- migrate:up

CREATE TABLE document_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(22) NOT NULL UNIQUE
);

-- migrate:down

DROP TABLE document_types;