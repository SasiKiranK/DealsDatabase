-- Voting Service Schema (Postgres)
CREATE DATABASE voting_service;
\c voting_service;

-- Reaction catalog stores supported emoji and their properties
CREATE TYPE reaction_polarity AS ENUM ('positive','negative','neutral');

CREATE TABLE reaction_catalog (
    emoji TEXT PRIMARY KEY,          -- canonical emoji code
    label TEXT NOT NULL,             -- display label
    polarity reaction_polarity NOT NULL,
    default_weight NUMERIC(4,2) NOT NULL DEFAULT 1.0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Individual reaction events (source of truth)
CREATE TABLE reactions (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    emoji TEXT NOT NULL REFERENCES reaction_catalog(emoji),
    polarity reaction_polarity NOT NULL,
    weight NUMERIC(6,3) NOT NULL,           -- effective weight after multipliers
    user_weight_multiplier NUMERIC(4,2) DEFAULT 1.0,
    device_id TEXT,
    app_version TEXT,
    ip_hash TEXT,
    user_risk_score NUMERIC(4,2),
    idempotency_key UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    shadow_banned BOOLEAN DEFAULT FALSE
);

-- Snapshot per (deal,user) storing current direction and counts
CREATE TABLE deal_user_reaction_snapshots (
    deal_id BIGINT,
    user_id BIGINT,
    polarity reaction_polarity NOT NULL,
    emoji_count INTEGER NOT NULL DEFAULT 0,
    last_action_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY(deal_id, user_id)
);

-- Aggregate counters per deal for fast reads
CREATE TABLE deal_reaction_counters (
    deal_id BIGINT PRIMARY KEY,
    positive_total INTEGER DEFAULT 0,
    negative_total INTEGER DEFAULT 0,
    neutral_total INTEGER DEFAULT 0,
    emoji_counts JSONB DEFAULT '{}'::JSONB,
    deal_exists BOOLEAN DEFAULT TRUE
);

-- Time bucketed series for velocity (hourly buckets)
CREATE TABLE deal_reaction_hourly_counters (
    deal_id BIGINT,
    bucket_start TIMESTAMPTZ,
    positive_total INTEGER DEFAULT 0,
    negative_total INTEGER DEFAULT 0,
    neutral_total INTEGER DEFAULT 0,
    emoji_counts JSONB DEFAULT '{}'::JSONB,
    PRIMARY KEY(deal_id, bucket_start)
);

-- Derived trending scores per deal
CREATE TABLE deal_scores (
    deal_id BIGINT PRIMARY KEY,
    hot_score NUMERIC(12,4) DEFAULT 0,
    last_scored_at TIMESTAMPTZ,
    is_hot BOOLEAN DEFAULT FALSE
);

-- Audit log for reaction mutations
CREATE TYPE reaction_action AS ENUM ('add','remove','clear','switch');

CREATE TABLE reaction_events (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT,
    user_id BIGINT,
    emoji TEXT,
    action reaction_action NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Helpful indexes for hot paths
CREATE UNIQUE INDEX reactions_idempotency_idx ON reactions(idempotency_key);
CREATE UNIQUE INDEX reactions_user_deal_emoji_idx ON reactions(deal_id, user_id, emoji) WHERE deleted_at IS NULL;
CREATE INDEX reactions_deal_idx ON reactions(deal_id);
CREATE INDEX reactions_user_idx ON reactions(user_id);
CREATE INDEX reactions_deal_created_idx ON reactions(deal_id, created_at);
CREATE INDEX reactions_deal_emoji_idx ON reactions(deal_id, emoji);
CREATE INDEX hourly_counters_idx ON deal_reaction_hourly_counters(deal_id, bucket_start);
