-- migrate:up

INSERT INTO periods (id, name) VALUES (1, '2026-I');

-- migrate:down

DELETE FROM periods WHERE id = 1;