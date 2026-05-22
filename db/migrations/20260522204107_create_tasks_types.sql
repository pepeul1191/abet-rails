-- migrate:up
CREATE TABLE task_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(25) NOT NULL,
    description VARCHAR(100),
    video_url VARCHAR(255)
);

-- migrate:down
DROP TABLE IF EXISTS task_types;