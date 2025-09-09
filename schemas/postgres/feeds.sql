-- Feeds Service Schema (Postgres)
CREATE DATABASE feed_service;
\c feed_service;

CREATE TABLE feed_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE feeds (
    id BIGSERIAL PRIMARY KEY,
    feed_type_id INTEGER REFERENCES feed_types(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE feed_items (
    feed_id BIGINT REFERENCES feeds(id),
    deal_id BIGINT,
    position INTEGER,
    PRIMARY KEY(feed_id, deal_id)
);
