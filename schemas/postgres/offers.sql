-- Offers Service Schema (Postgres)
CREATE DATABASE offers_service;
\c offers_service;

-- Types like coupon code, credit card, debit card, wallet, bank offer, etc.
CREATE TABLE offer_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Per-offer-type fields with required/optional flags
CREATE TABLE offer_type_fields (
    id SERIAL PRIMARY KEY,
    offer_type_id INTEGER REFERENCES offer_types(id),
    field_name TEXT NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT FALSE
);

-- Benefit types for offers
CREATE TABLE offer_benefit_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Requirement types specifying needed payment method or membership
CREATE TABLE requirement_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE offers (
    id BIGSERIAL PRIMARY KEY,
    offer_type_id INTEGER REFERENCES offer_types(id),
    title TEXT,
    description TEXT,
    spec JSONB,
    code TEXT,
    store_id INTEGER,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    link TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Benefits associated with an offer (discount %, cashback, free shipping, etc.)
CREATE TABLE offer_benefits (
    id BIGSERIAL PRIMARY KEY,
    offer_id BIGINT REFERENCES offers(id),
    benefit_type_id INTEGER REFERENCES offer_benefit_types(id),
    value NUMERIC(12,2),
    cap NUMERIC(12,2)
);

-- Requirements like specific credit card or membership
CREATE TABLE offer_requirements (
    id BIGSERIAL PRIMARY KEY,
    offer_id BIGINT REFERENCES offers(id),
    requirement_type_id INTEGER REFERENCES requirement_types(id),
    provider TEXT,
    details JSONB
);

-- Offers may relate to many deals across services
CREATE TABLE offer_deals (
    offer_id BIGINT REFERENCES offers(id),
    deal_id BIGINT,
    PRIMARY KEY(offer_id, deal_id)
);

-- Seed canonical offer types
INSERT INTO offer_types (name) VALUES
    ('coupon'),
    ('credit_card'),
    ('emi'),
    ('cashback'),
    ('wallet'),
    ('membership'),
    ('exchange');

-- Define required and optional fields for each offer type
INSERT INTO offer_type_fields (offer_type_id, field_name, is_required) VALUES
    ((SELECT id FROM offer_types WHERE name = 'coupon'), 'code', TRUE),
    ((SELECT id FROM offer_types WHERE name = 'coupon'), 'min_cart', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'coupon'), 'max_uses', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'coupon'), 'category_includes', FALSE),

    ((SELECT id FROM offer_types WHERE name = 'credit_card'), 'issuer', TRUE),
    ((SELECT id FROM offer_types WHERE name = 'credit_card'), 'card_type', TRUE),
    ((SELECT id FROM offer_types WHERE name = 'credit_card'), 'network', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'credit_card'), 'bin_ranges', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'credit_card'), 'category_includes', FALSE),

    ((SELECT id FROM offer_types WHERE name = 'emi'), 'issuer', TRUE),
    ((SELECT id FROM offer_types WHERE name = 'emi'), 'tenure_options', TRUE),
    ((SELECT id FROM offer_types WHERE name = 'emi'), 'no_cost', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'emi'), 'processing_fee', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'emi'), 'subvention_party', FALSE),

    ((SELECT id FROM offer_types WHERE name = 'cashback'), 'cashback_amount', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'cashback'), 'cashback_percent', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'cashback'), 'cashback_type', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'cashback'), 'cap', FALSE),

    ((SELECT id FROM offer_types WHERE name = 'wallet'), 'wallet_provider', TRUE),
    ((SELECT id FROM offer_types WHERE name = 'wallet'), 'user_segment', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'wallet'), 'platform', FALSE),

    ((SELECT id FROM offer_types WHERE name = 'membership'), 'program_name', TRUE),
    ((SELECT id FROM offer_types WHERE name = 'membership'), 'tier', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'membership'), 'user_segment', FALSE),

    ((SELECT id FROM offer_types WHERE name = 'exchange'), 'accepted_categories', TRUE),
    ((SELECT id FROM offer_types WHERE name = 'exchange'), 'brand_includes', FALSE),
    ((SELECT id FROM offer_types WHERE name = 'exchange'), 'condition_tiers', FALSE);

-- For cashback offers, at least one of cashback_amount or cashback_percent should be supplied.
