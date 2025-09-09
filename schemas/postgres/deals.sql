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

-- Enumerations
CREATE TYPE deal_status AS ENUM ('prohibited','active','expired');
CREATE TYPE deal_environment AS ENUM ('online','instore');

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
    created_at TIMESTAMPTZ DEFAULT NOW(),
    start_date TIMESTAMPTZ,
    expiry_date TIMESTAMPTZ,
    last_update TIMESTAMPTZ DEFAULT NOW(),
    upvote_count INTEGER DEFAULT 0,
    downvote_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    comment_velocity NUMERIC(10,2) DEFAULT 0,
    status deal_status NOT NULL DEFAULT 'active',
    owner_id BIGINT,
    category_id INTEGER REFERENCES categories(id),
    deal_type_id INTEGER REFERENCES deal_types(id),
    environment deal_environment,
    location TEXT,
    description TEXT,
    how_to_avail TEXT
);

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
