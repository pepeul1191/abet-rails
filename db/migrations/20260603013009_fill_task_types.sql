-- migrate:up

INSERT INTO task_types (id, name) VALUES (1, 'Ejercicio Colaboratio');
INSERT INTO task_types (id, name) VALUES (2, 'Trabajo Grupal');

-- migrate:down

DELETE FROM task_types;