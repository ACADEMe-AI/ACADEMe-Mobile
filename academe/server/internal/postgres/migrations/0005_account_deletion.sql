ALTER TABLE accounts
    ADD COLUMN deletion_requested_at timestamptz,
    ADD COLUMN deletion_reason text;

CREATE INDEX accounts_deletion_requested_idx ON accounts (deletion_requested_at)
    WHERE deletion_requested_at IS NOT NULL;
