-- Messages Service Schema (Postgres)
CREATE DATABASE message_service;
\c message_service;

CREATE TABLE message_threads (
    id BIGSERIAL PRIMARY KEY,
    subject TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    thread_id BIGINT REFERENCES message_threads(id),
    sender_id BIGINT,
    receiver_id BIGINT,
    content TEXT NOT NULL,
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    read_at TIMESTAMPTZ
);
