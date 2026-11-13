ALTER TABLE password_reset_codes ADD COLUMN link_hash bytea UNIQUE;
