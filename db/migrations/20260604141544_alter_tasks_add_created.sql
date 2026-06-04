-- migrate:up

ALTER TABLE tasks
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

-- migrate:down

CREATE TABLE tasks_tmp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(40) NOT NULL,
    description TEXT,
    data TEXT,
    zip_path VARCHAR(255),
    status VARCHAR(20),
    user_id INTEGER NOT NULL,
    task_type_id INTEGER NOT NULL,
    period_id INTEGER NOT NULL,
    FOREIGN KEY (task_type_id) REFERENCES task_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (period_id) REFERENCES periods(id) ON DELETE RESTRICT
);

INSERT INTO tasks_tmp (
    id, name, description, data, zip_path, status,
    user_id, task_type_id, period_id
)
SELECT
    id, name, description, data, zip_path, status,
    user_id, task_type_id, period_id
FROM tasks;

DROP TABLE tasks;

ALTER TABLE tasks_tmp RENAME TO tasks;