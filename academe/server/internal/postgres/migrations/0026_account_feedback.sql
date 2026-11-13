CREATE TABLE account_feedback (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    category   text NOT NULL CHECK (category IN ('wrong_answer', 'bug', 'feature')),
    message    text NOT NULL,
    context    jsonb NOT NULL DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX account_feedback_account_created_idx
    ON account_feedback (account_id, created_at DESC);
