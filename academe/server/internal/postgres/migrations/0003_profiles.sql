CREATE TABLE profiles (
    account_id    uuid PRIMARY KEY REFERENCES accounts (id) ON DELETE CASCADE,
    language      text,
    birth_year    integer,
    class_level   integer,
    board         text,
    setup_done_at timestamptz,
    updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE xp_events (
    id         bigserial PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    amount     integer NOT NULL CHECK (amount > 0),
    reason     text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (account_id, reason)
);
