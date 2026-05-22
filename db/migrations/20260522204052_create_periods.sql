-- migrate:up
CREATE TABLE periods (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(10) NOT NULL
);

-- migrate:down
DROP TABLE IF EXISTS periods;