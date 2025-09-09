-- Recommendation Data Schema (Postgres)
CREATE DATABASE recommendation_service;
\c recommendation_service;

-- Users can save deals
CREATE TABLE saved_deals (
    user_id BIGINT,
    deal_id BIGINT,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    list_id BIGINT,
    PRIMARY KEY(user_id, deal_id)
);
CREATE INDEX idx_saved_deals_deal ON saved_deals(deal_id);

-- Users can hide deals
CREATE TABLE deal_hides (
    user_id BIGINT,
    deal_id BIGINT,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY(user_id, deal_id)
);

-- High-volume view events
CREATE TABLE deal_views (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    deal_id BIGINT,
    viewed_at TIMESTAMPTZ DEFAULT NOW(),
    dwell_bucket TEXT,
    surface TEXT,
    device_id BIGINT,
    referrer TEXT
);
CREATE INDEX idx_deal_views_user ON deal_views(user_id);
CREATE INDEX idx_deal_views_deal ON deal_views(deal_id);
