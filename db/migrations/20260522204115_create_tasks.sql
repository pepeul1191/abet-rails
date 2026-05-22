-- migrate:up
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(40) NOT NULL,
    description TEXT,
    data TEXT,
    document_url VARCHAR(255),
    status VARCHAR(20),
    user_id INTEGER NOT NULL, -- Asumo que no debe ser nulo por ser FK
    task_type_id INTEGER NOT NULL,
    period_id INTEGER NOT NULL,
    FOREIGN KEY (task_type_id) REFERENCES task_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (period_id) REFERENCES periods(id) ON DELETE RESTRICT
);

-- migrate:down
DROP TABLE IF EXISTS tasks;