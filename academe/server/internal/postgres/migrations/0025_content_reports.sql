CREATE TABLE content_reports (
    kind       text NOT NULL CHECK (kind IN ('check', 'lesson')),
    target_id  text NOT NULL,
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    reason     text NOT NULL CHECK (reason IN ('wrong', 'harmful', 'offensive', 'other')),
    note       text NOT NULL DEFAULT '',
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (kind, target_id, account_id)
);

CREATE INDEX content_reports_created_idx ON content_reports (created_at DESC);
