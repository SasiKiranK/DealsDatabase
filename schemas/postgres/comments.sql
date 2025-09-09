-- Comments Service Schema (Postgres)
CREATE DATABASE comment_service;
\c comment_service;

-- Moderation states for comments
CREATE TYPE comment_moderation_state AS ENUM ('pending','approved','blocked');

-- Core comments table
CREATE TABLE comments (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT,
    author_id BIGINT,
    body TEXT,
    parent_id BIGINT REFERENCES comments(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    edited_at TIMESTAMPTZ,
    is_deleted BOOLEAN DEFAULT FALSE,
    moderation_state comment_moderation_state DEFAULT 'pending',
    visibility BOOLEAN DEFAULT TRUE,
    search_vector TSVECTOR
);

-- Indexes for hot paths
CREATE INDEX idx_comments_deal ON comments(deal_id, created_at DESC);
CREATE INDEX idx_comments_parent ON comments(parent_id, created_at ASC);
CREATE INDEX idx_comments_author ON comments(author_id, created_at DESC);
CREATE INDEX idx_comments_search ON comments USING GIN (search_vector);

-- Comment reactions (e.g., thumbs up, fire)
CREATE TABLE comment_reactions (
    comment_id BIGINT REFERENCES comments(id),
    user_id BIGINT,
    reaction_type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY(comment_id, user_id, reaction_type)
);

-- Comment votes separate from deal votes
CREATE TABLE comment_votes (
    comment_id BIGINT REFERENCES comments(id),
    user_id BIGINT,
    vote SMALLINT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY(comment_id, user_id)
);

-- Mentions and hashtags
CREATE TABLE comment_mentions (
    comment_id BIGINT REFERENCES comments(id),
    mentioned_user_id BIGINT,
    PRIMARY KEY(comment_id, mentioned_user_id)
);

CREATE TABLE comment_hashtags (
    comment_id BIGINT REFERENCES comments(id),
    hashtag TEXT,
    PRIMARY KEY(comment_id, hashtag)
);

-- Reporting flow for comments
CREATE TABLE comment_reports (
    id BIGSERIAL PRIMARY KEY,
    comment_id BIGINT REFERENCES comments(id),
    reporter_id BIGINT,
    reason_code TEXT,
    status TEXT DEFAULT 'pending',
    resolver_id BIGINT,
    resolved_at TIMESTAMPTZ,
    action_taken TEXT
);
