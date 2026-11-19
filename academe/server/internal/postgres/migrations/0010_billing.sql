CREATE TABLE subscriptions (
    account_id     uuid PRIMARY KEY REFERENCES accounts (id) ON DELETE CASCADE,
    platform       text NOT NULL,
    product_id     text NOT NULL,
    base_plan_id   text NOT NULL,
    purchase_token text NOT NULL,
    state          text NOT NULL,
    expires_at     timestamptz,
    auto_renew     boolean NOT NULL,
    raw            jsonb NOT NULL,
    event_at       timestamptz NOT NULL,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE billing_events (
    id          text PRIMARY KEY,
    received_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE usage_counts (
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    day        date NOT NULL,
    feature    text NOT NULL,
    count      integer NOT NULL CHECK (count >= 0),
    PRIMARY KEY (account_id, day, feature)
);
