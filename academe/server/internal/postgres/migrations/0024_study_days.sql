CREATE TABLE study_days (
    account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    day        date NOT NULL DEFAULT (now() AT TIME ZONE 'Asia/Kolkata')::date,
    PRIMARY KEY (account_id, day)
);
