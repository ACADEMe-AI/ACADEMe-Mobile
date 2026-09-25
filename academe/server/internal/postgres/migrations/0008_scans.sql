CREATE TABLE user_decks (
    id         text PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    deck       jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE folder_items ADD COLUMN deck_id text;
ALTER TABLE folder_items DROP CONSTRAINT folder_items_check;
ALTER TABLE folder_items ADD CONSTRAINT folder_items_one_kind
    CHECK (num_nonnulls(chapter_id, note, deck_id) = 1);

CREATE TABLE scans (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    mode       text NOT NULL CHECK (mode IN ('solve', 'check', 'notes', 'ask')),
    title      text NOT NULL,
    body       text NOT NULL,
    chapter    text NOT NULL DEFAULT '',
    thread_id  uuid,
    folder_id  uuid,
    deck_id    text,
    result     jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX scans_account_created_idx ON scans (account_id, created_at DESC);
