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

-- Per-user daily metrics
CREATE TABLE user_metrics (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    date DATE,
    deals_posted INTEGER DEFAULT 0,
    comments_made INTEGER DEFAULT 0,
    votes_cast INTEGER DEFAULT 0,
    rewards_earned NUMERIC(12,2) DEFAULT 0
);
