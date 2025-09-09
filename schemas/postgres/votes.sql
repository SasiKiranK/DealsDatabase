-- Voting Service Schema (Postgres)
CREATE DATABASE voting_service;
\c voting_service;

CREATE TYPE vote_type AS ENUM ('upvote','downvote');

CREATE TABLE votes (
    deal_id BIGINT,
    user_id BIGINT,
    type vote_type NOT NULL,
    emoji TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY(deal_id, user_id, emoji)
);
