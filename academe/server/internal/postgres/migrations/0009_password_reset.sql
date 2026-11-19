CREATE TABLE password_reset_codes (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id        uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    code_hash         bytea NOT NULL,
    attempts          integer NOT NULL DEFAULT 0,
    expires_at        timestamptz NOT NULL,
    used_at           timestamptz,
    reset_token_hash  bytea UNIQUE,
    completed_at      timestamptz,
    created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX password_reset_codes_account_idx ON password_reset_codes (account_id, created_at DESC);
