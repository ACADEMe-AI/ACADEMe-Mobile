CREATE TABLE deck_positions (
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    deck_id    text NOT NULL,
    card       integer NOT NULL CHECK (card >= 0),
    updated_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (account_id, deck_id)
);

CREATE TABLE kept_cards (
    account_id    uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    deck_id       text NOT NULL,
    card          integer NOT NULL CHECK (card >= 0),
    reason        text NOT NULL CHECK (reason IN ('kept', 'missed')),
    due_at        timestamptz NOT NULL,
    interval_days integer NOT NULL DEFAULT 0,
    kept_at       timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (account_id, deck_id, card)
);

CREATE INDEX kept_cards_due_idx ON kept_cards (account_id, due_at);

CREATE TABLE chapter_results (
    account_id   uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    chapter_id   text NOT NULL,
    correct      integer NOT NULL CHECK (correct >= 0),
    total        integer NOT NULL CHECK (total > 0),
    completed_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (account_id, chapter_id)
);

CREATE TABLE folders (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    name       text NOT NULL,
    due_on     date,
    reminds    boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX folders_account_idx ON folders (account_id);

CREATE TABLE folder_items (
    id         bigserial PRIMARY KEY,
    folder_id  uuid NOT NULL REFERENCES folders (id) ON DELETE CASCADE,
    chapter_id text,
    note       text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK ((chapter_id IS NULL) <> (note IS NULL)),
    UNIQUE (folder_id, chapter_id)
);

CREATE TABLE folder_todos (
    id         bigserial PRIMARY KEY,
    folder_id  uuid NOT NULL REFERENCES folders (id) ON DELETE CASCADE,
    title      text NOT NULL,
    day        date,
    done_at    timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);
