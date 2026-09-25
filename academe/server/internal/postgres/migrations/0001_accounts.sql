CREATE TABLE accounts (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name    text NOT NULL,
    last_name     text NOT NULL,
    email         text NOT NULL UNIQUE,
    password_hash text NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sessions (
    token_hash bytea PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    expires_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX sessions_account_id_idx ON sessions (account_id);
