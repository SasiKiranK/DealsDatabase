-- Deals Service Schema (Postgres)
CREATE DATABASE deals_service;
\c deals_service;

-- Stores maintain basic info and policies
CREATE TABLE stores (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    trust_score NUMERIC(3,2),
    return_policy TEXT,
    shipping_policy TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories for organizing deals
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Deal types like product, membership, services, gift card, sample, freebies
CREATE TABLE deal_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Brands referenced by deals
CREATE TABLE brands (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);

-- Duplicate groups for merged deals
CREATE TABLE duplicate_groups (
    id BIGSERIAL PRIMARY KEY,
    canonical_deal_id BIGINT
);

CREATE TYPE deal_state AS ENUM ('draft','moderation','live','expired','blocked','deleted');
CREATE TYPE deal_environment AS ENUM ('online','instore');
CREATE TYPE moderation_action AS ENUM ('approve','reject','request_changes','flag');
CREATE TYPE tag_type AS ENUM ('manual','system','editorial');
CREATE TYPE image_source AS ENUM ('user','system','store');

-- Core deals table
CREATE TABLE deals (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    product_name TEXT,
    product_id BIGINT,
    original_price NUMERIC(12,2),
    discounted_price NUMERIC(12,2),
    currency CHAR(3),
    store_id INTEGER REFERENCES stores(id),
    link TEXT,
    affiliate_url TEXT,
    coupon_code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    start_date TIMESTAMPTZ,
    expiry_date TIMESTAMPTZ,
    last_update TIMESTAMPTZ DEFAULT NOW(),
    upvote_count INTEGER DEFAULT 0,
    downvote_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    comment_velocity NUMERIC(10,2) DEFAULT 0,
    state deal_state NOT NULL DEFAULT 'draft',
    owner_id BIGINT,
    original_owner_id BIGINT,
    category_id INTEGER REFERENCES categories(id),
    deal_type_id INTEGER REFERENCES deal_types(id),
    brand_id INTEGER REFERENCES brands(id),
    external_product_id BIGINT,
    environment deal_environment,
    city TEXT,
    pincode TEXT,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    description TEXT,
    how_to_avail TEXT,
    attrs JSONB,
    net_effective_price NUMERIC(12,2),
    price_breakdown JSONB,
    dedup_signature TEXT,
    normalized_url TEXT,
    duplicate_group_id BIGINT,
    merged_from BIGINT REFERENCES deals(id),
    is_frontpage BOOLEAN DEFAULT FALSE,
    frontpage_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT
);

ALTER TABLE duplicate_groups
    ADD CONSTRAINT duplicate_groups_canonical_fk FOREIGN KEY (canonical_deal_id) REFERENCES deals(id);

ALTER TABLE deals
    ADD CONSTRAINT deals_duplicate_group_fk FOREIGN KEY (duplicate_group_id) REFERENCES duplicate_groups(id);

-- Tags system
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE,
    type tag_type NOT NULL DEFAULT 'manual'
);

CREATE TABLE deal_tags (
    deal_id BIGINT REFERENCES deals(id),
    tag_id INTEGER REFERENCES tags(id),
    applied_by BIGINT,
    applied_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY(deal_id, tag_id)
);

-- Bridge to offers service; foreign key omitted due to cross-db nature
CREATE TABLE deal_offers (
    deal_id BIGINT REFERENCES deals(id),
    offer_id BIGINT,
    PRIMARY KEY(deal_id, offer_id)
);

-- Image gallery for deals
CREATE TABLE deal_images (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT REFERENCES deals(id),
    url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    position INTEGER,
    alt_text TEXT,
    source image_source,
    created_at TIMESTAMPTZ DEFAULT NOW()
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

-- Audit trail for state changes
CREATE TABLE deal_state_audit (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT REFERENCES deals(id),
    from_state deal_state,
    to_state deal_state,
    changed_by BIGINT,
    reason TEXT,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Moderation actions
CREATE TABLE moderation_actions (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT REFERENCES deals(id),
    moderator_id BIGINT,
    action moderation_action,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Comments on deals
CREATE TABLE comments (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT REFERENCES deals(id),
    user_id BIGINT,
    content TEXT NOT NULL,
    parent_comment_id BIGINT REFERENCES comments(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Editorial promotions
CREATE TABLE editorial_promotions (
    id BIGSERIAL PRIMARY KEY,
    deal_id BIGINT REFERENCES deals(id),
    editor_id BIGINT,
    checklist JSONB,
    promoted_at TIMESTAMPTZ DEFAULT NOW()
);

-- Helpful indexes
CREATE INDEX deals_state_idx ON deals(state);
CREATE INDEX deals_expiry_idx ON deals(expiry_date);
CREATE INDEX deals_store_idx ON deals(store_id);
CREATE INDEX deals_category_idx ON deals(category_id);
CREATE INDEX deals_created_idx ON deals(created_at);
CREATE INDEX deals_url_norm_idx ON deals(normalized_url);
CREATE INDEX deals_net_price_idx ON deals(net_effective_price);
CREATE INDEX deals_search_idx ON deals USING GIN (to_tsvector('english', title || ' ' || COALESCE(description, '')));
