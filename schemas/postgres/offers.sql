-- Offers Service Schema (Postgres)
CREATE DATABASE offers_service;
\c offers_service;

-- Types like coupon code, credit card, debit card, wallet, bank offer, etc.
CREATE TABLE offer_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Benefit types for offers
CREATE TABLE offer_benefit_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Requirement types specifying needed payment method or membership
CREATE TABLE requirement_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE offers (
    id BIGSERIAL PRIMARY KEY,
    offer_type_id INTEGER REFERENCES offer_types(id) NOT NULL,
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
CREATE INDEX idx_offers_start_date ON offers(start_date);
CREATE INDEX idx_offers_end_date ON offers(end_date);

-- Benefits associated with an offer (discount %, cashback, free shipping, etc.)
CREATE TABLE offer_benefits (
    id BIGSERIAL PRIMARY KEY,
    offer_id BIGINT REFERENCES offers(id),
    benefit_type_id INTEGER REFERENCES offer_benefit_types(id),
    value NUMERIC(12,2),
    cap NUMERIC(12,2)
);
CREATE INDEX idx_offer_benefits_offer ON offer_benefits(offer_id);

-- Requirements like specific credit card or membership
CREATE TABLE offer_requirements (
    id BIGSERIAL PRIMARY KEY,
    offer_id BIGINT REFERENCES offers(id),
    requirement_type_id INTEGER REFERENCES requirement_types(id),
    provider TEXT,
    details JSONB
);
CREATE INDEX idx_offer_requirements_offer ON offer_requirements(offer_id);

-- Offers may relate to many deals across services
CREATE TABLE offer_deals (
    offer_id BIGINT REFERENCES offers(id),
    deal_id BIGINT,
    PRIMARY KEY(offer_id, deal_id)
);
