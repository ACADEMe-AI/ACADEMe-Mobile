ALTER TABLE accounts
    ADD COLUMN tokens_valid_after timestamptz NOT NULL DEFAULT '1970-01-01 00:00:00+00';
