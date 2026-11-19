CREATE TABLE deck_completions (
    account_id   uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    deck_id      text NOT NULL,
    correct      integer NOT NULL CHECK (correct >= 0),
    completed_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (account_id, deck_id)
);
