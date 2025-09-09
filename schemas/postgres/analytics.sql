-- Analytics Service Schema (Postgres)
CREATE DATABASE analytics_service;
\c analytics_service;

-- Per-deal daily metrics
CREATE TABLE deal_metrics (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT,
    date DATE,
    views INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    saves INTEGER DEFAULT 0,
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0
);

-- Event log
CREATE TABLE events (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    type TEXT,
    platform TEXT,
    campaign TEXT,
    geo_bucket TEXT,
    payload JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Per-user daily metrics
CREATE TABLE user_metrics (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    date DATE,
    posts INTEGER DEFAULT 0,
    comments INTEGER DEFAULT 0,
    votes INTEGER DEFAULT 0,
    follows INTEGER DEFAULT 0,
    watches INTEGER DEFAULT 0,
    redeems INTEGER DEFAULT 0,
    logins INTEGER DEFAULT 0
);

CREATE INDEX idx_events_user_type ON events(user_id, type);
CREATE INDEX idx_user_metrics_user_date ON user_metrics(user_id, date);

INSERT INTO events (user_id, type, platform, campaign, geo_bucket, payload)
VALUES (1, 'login', 'web', 'summer', 'Delhi', '{}'::jsonb);
