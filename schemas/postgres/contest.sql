-- Contest Service Schema (Postgres)
CREATE DATABASE contest_service;
\c contest_service;

CREATE TABLE contests (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    rules TEXT,
    eligibility TEXT,
    tie_breakers TEXT,
    fraud_checks TEXT
);

CREATE TABLE contest_prizes (
    contest_id BIGINT REFERENCES contests(id),
    rank INTEGER,
    prize TEXT,
    PRIMARY KEY(contest_id, rank)
);

CREATE TABLE contest_participants (
    contest_id BIGINT REFERENCES contests(id),
    user_id BIGINT,
    score INTEGER DEFAULT 0,
    PRIMARY KEY(contest_id, user_id)
);
