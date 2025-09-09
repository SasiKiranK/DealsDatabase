-- Deals Service Schema (Postgres)
CREATE DATABASE deals_service;
\c deals_service;

-- Enumerations
CREATE TYPE deal_status AS ENUM ('prohibited','active','expired');
CREATE TYPE deal_environment AS ENUM ('online','instore');
CREATE TYPE store_channel AS ENUM ('online','instore','both');
CREATE TYPE deal_moderation_state AS ENUM ('pending','reviewed','blocked');
CREATE TYPE link_type AS ENUM ('original','affiliate','short');

-- Stores maintain basic info and policies
CREATE TABLE stores (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE,
    domains TEXT[],
    logo TEXT,
    trust_score NUMERIC(3,2),
    return_policy TEXT,
    shipping_policy TEXT,
    channel store_channel,
    region TEXT,
    country TEXT,
    contact JSONB,
    affiliate_program_id BIGINT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Map legacy names/domains/ids to canonical stores
CREATE TABLE store_aliases (
    id SERIAL PRIMARY KEY,
    store_id INTEGER REFERENCES stores(id),
    alias_name TEXT,
    domain TEXT,
    legacy_id TEXT
);

-- Categories for organizing deals
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Deal types like product, membership, services, gift card, sample, freebies
CREATE TABLE deal_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Core deals table
CREATE TABLE deals (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    product_name TEXT,
    product_id BIGINT,
    original_price NUMERIC(12,2),
    discounted_price NUMERIC(12,2),
    store_id INTEGER REFERENCES stores(id),
    link TEXT,
    store_url_original TEXT,
    affiliate_url TEXT,
    short_redirect_url TEXT,
    url_normalized TEXT,
    affiliate_program_id BIGINT,
    campaign_id BIGINT,
    utm_bundle JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    start_date TIMESTAMPTZ,
    expiry_date TIMESTAMPTZ,
    last_update TIMESTAMPTZ DEFAULT NOW(),
    upvote_count INTEGER DEFAULT 0,
    downvote_count INTEGER DEFAULT 0,
    total_comment_count INTEGER DEFAULT 0,
    last_comment_at TIMESTAMPTZ,
    comment_velocity NUMERIC(10,2) DEFAULT 0,
    status deal_status NOT NULL DEFAULT 'active',
    original_owner_id BIGINT,
    merged_into_deal_id BIGINT REFERENCES deals(id),
    credit_awarded BOOLEAN DEFAULT FALSE,
    redirect_enabled BOOLEAN DEFAULT TRUE,
    is_flagged BOOLEAN DEFAULT FALSE,
    moderation_state deal_moderation_state DEFAULT 'pending',
    owner_id BIGINT,
    category_id INTEGER REFERENCES categories(id),
    deal_type_id INTEGER REFERENCES deal_types(id),
    environment deal_environment,
    location TEXT,
    description TEXT,
    how_to_avail TEXT,
    has_no_cost_emi BOOLEAN DEFAULT FALSE,
    vfm_score NUMERIC(5,2),
    vfm_reason TEXT,
    draft_progress JSONB,
    is_90_day_low BOOLEAN DEFAULT FALSE,
    badges JSONB
);

CREATE UNIQUE INDEX uniq_deals_url_normalized ON deals(url_normalized);
CREATE INDEX idx_deals_live ON deals(created_at)
    WHERE status = 'active' AND (expiry_date IS NULL OR expiry_date > NOW());
CREATE INDEX idx_deals_store ON deals(store_id);
CREATE INDEX idx_deals_category ON deals(category_id);
CREATE INDEX idx_deals_type ON deals(deal_type_id);

-- Tags like VFM, hot, loot, lightning, missed
CREATE TABLE title_tags (
    id SERIAL PRIMARY KEY,
    tag TEXT UNIQUE
);

CREATE TABLE deal_title_tags (
    deal_id BIGINT REFERENCES deals(id),
    tag_id INTEGER REFERENCES title_tags(id),
    PRIMARY KEY(deal_id, tag_id)
);

-- Bridge to offers service; foreign key omitted due to cross-db nature
CREATE TABLE deal_offers (
    deal_id BIGINT REFERENCES deals(id),
    offer_id BIGINT,
    PRIMARY KEY(deal_id, offer_id)
);

-- Click tracking for original/affiliate/short links
CREATE TABLE deal_clicks (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT REFERENCES deals(id),
    user_id BIGINT,
    clicked_at TIMESTAMPTZ DEFAULT NOW(),
    link_type link_type,
    device_id BIGINT,
    referrer TEXT
);
CREATE INDEX idx_deal_clicks_deal ON deal_clicks(deal_id);
CREATE INDEX idx_deal_clicks_user ON deal_clicks(user_id);
CREATE INDEX idx_deal_clicks_user_time ON deal_clicks(user_id, clicked_at);

-- Images associated with a deal
CREATE TABLE deal_images (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT REFERENCES deals(id) ON DELETE CASCADE,
    storage_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    alt_text TEXT,
    source TEXT NOT NULL CHECK (source IN ('upload','store','screenshot')),
    width INTEGER,
    height INTEGER,
    checksum TEXT,
    nsfw_suspect BOOLEAN DEFAULT FALSE,
    dmca_status TEXT,
    editor_verified BOOLEAN DEFAULT FALSE,
    thumb_id TEXT,
    card_id TEXT,
    hero_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE UNIQUE INDEX uniq_deal_primary_image ON deal_images(deal_id) WHERE is_primary;
CREATE INDEX idx_deal_images_deal ON deal_images(deal_id, sort_order);

-- Duplicate and merge lineage
CREATE TABLE duplicate_groups (
    id BIGSERIAL PRIMARY KEY,
    canonical_deal_id BIGINT REFERENCES deals(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE duplicate_group_members (
    group_id BIGINT REFERENCES duplicate_groups(id),
    deal_id BIGINT REFERENCES deals(id),
    PRIMARY KEY(group_id, deal_id)
);

-- Value Added Services like insurance or extended warranty
CREATE TABLE vas_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE value_added_services (
    id BIGSERIAL PRIMARY KEY,
    vas_type_id INTEGER REFERENCES vas_types(id),
    provider TEXT,
    cost NUMERIC(12,2),
    description TEXT
);

CREATE TABLE deal_vas (
    deal_id BIGINT REFERENCES deals(id),
    vas_id BIGINT REFERENCES value_added_services(id),
    PRIMARY KEY(deal_id, vas_id)
);
