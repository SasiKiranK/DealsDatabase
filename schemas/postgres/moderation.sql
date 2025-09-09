-- Moderation Service Schema (Postgres)
CREATE DATABASE moderation_service;
\c moderation_service;

-- Lookup table for moderation/report reasons
CREATE TABLE moderation_reasons (
    code TEXT PRIMARY KEY,
    label TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER
);

-- Reports against deals
CREATE TABLE deal_reports (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT,
    reporter_id BIGINT,
    reason_code TEXT REFERENCES moderation_reasons(code),
    notes TEXT,
    status TEXT DEFAULT 'pending',
    resolver_id BIGINT,
    resolved_at TIMESTAMPTZ,
    action TEXT
);

-- User warnings
CREATE TABLE user_warnings (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    reason_code TEXT REFERENCES moderation_reasons(code),
    severity INTEGER,
    issued_by BIGINT,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    notes TEXT
);

-- Moderation events log
CREATE TABLE moderation_events (
    id BIGSERIAL PRIMARY KEY,
    entity_type TEXT, -- deal/comment/user
    entity_id BIGINT,
    actor_id BIGINT,
    action TEXT,
    payload JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
