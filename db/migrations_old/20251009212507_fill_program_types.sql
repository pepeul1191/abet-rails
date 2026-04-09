-- migrate:up

INSERT INTO program_types (id, name) VALUES (1, 'Primer Paso');
INSERT INTO program_types (id, name) VALUES (2, 'Aceleración');

-- migrate:down

DELETE FROM program_types;