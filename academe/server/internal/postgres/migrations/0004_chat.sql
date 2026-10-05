CREATE TABLE chat_threads (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    mode       text NOT NULL CHECK (mode IN ('explain', 'solve', 'quiz')),
    title      text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX chat_threads_account_updated_idx ON chat_threads (account_id, updated_at DESC);

CREATE TABLE chat_messages (
    id         bigserial PRIMARY KEY,
    thread_id  uuid NOT NULL REFERENCES chat_threads (id) ON DELETE CASCADE,
    role       text NOT NULL CHECK (role IN ('student', 'pebby')),
    body       text NOT NULL,
    rating     smallint CHECK (rating IN (-1, 1)),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX chat_messages_thread_idx ON chat_messages (thread_id, id);
