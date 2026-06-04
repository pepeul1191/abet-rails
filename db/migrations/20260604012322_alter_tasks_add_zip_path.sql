-- migrate:up

ALTER TABLE tasks RENAME COLUMN document_url TO zip_path;

-- migrate:down

ALTER TABLE tasks RENAME COLUMN zip_path TO document_url;