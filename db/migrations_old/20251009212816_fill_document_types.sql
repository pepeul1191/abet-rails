-- migrate:up

INSERT INTO document_types (id, name) VALUES (1, 'DNI');
INSERT INTO document_types (id, name) VALUES (2, 'Carné de Extranjería');
INSERT INTO document_types (id, name) VALUES (3, 'Pasaporte');

-- migrate:down

DELETE FROM document_types;