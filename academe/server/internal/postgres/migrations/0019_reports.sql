CREATE TABLE chat_reports (
    message_id bigint NOT NULL REFERENCES chat_messages (id) ON DELETE CASCADE,
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    reason     text NOT NULL CHECK (reason IN ('wrong', 'harmful', 'offensive', 'other')),
    note       text NOT NULL DEFAULT '',
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (message_id, account_id)
);

CREATE INDEX chat_reports_created_idx ON chat_reports (created_at DESC);

CREATE TABLE deletion_requests (
    id         bigserial PRIMARY KEY,
    email      text NOT NULL,
    ip         text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX deletion_requests_created_idx ON deletion_requests (created_at DESC);
