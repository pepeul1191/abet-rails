-- migrate:up

CREATE TABLE industries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(30) NOT NULL UNIQUE
);

-- migrate:down

DROP TABLE industries;