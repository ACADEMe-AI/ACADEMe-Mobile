ALTER TABLE accounts ADD COLUMN google_email text;

UPDATE accounts SET google_email = email WHERE google_subject IS NOT NULL;
