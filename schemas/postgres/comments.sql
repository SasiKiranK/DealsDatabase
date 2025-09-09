-- Comment Service Schema (Postgres)
CREATE DATABASE comments_service;
\c comments_service;

CREATE TYPE moderation_state AS ENUM ('pending','approved','blocked');

CREATE TABLE comments (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT,
    parent_id BIGINT REFERENCES comments(id),
    author_id BIGINT,
    body TEXT NOT NULL,
    edited_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    moderation_state moderation_state NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE comment_reactions (
    comment_id BIGINT REFERENCES comments(id),
    user_id BIGINT,
    type TEXT,
    PRIMARY KEY (comment_id, user_id, type)
);

CREATE TABLE comment_votes (
    comment_id BIGINT REFERENCES comments(id),
    user_id BIGINT,
    vote SMALLINT,
    PRIMARY KEY (comment_id, user_id)
);

CREATE TABLE comment_reports (
    id BIGSERIAL PRIMARY KEY,
    comment_id BIGINT REFERENCES comments(id),
    reporter_id BIGINT,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE comment_mentions (
    id BIGSERIAL PRIMARY KEY,
    comment_id BIGINT REFERENCES comments(id),
    mentioned_user_id BIGINT
);

CREATE INDEX idx_comments_deal ON comments(deal_id);
CREATE INDEX idx_comments_author ON comments(author_id);
CREATE INDEX idx_comments_body_fts ON comments USING GIN (to_tsvector('english', body));
