-- Offers Service Schema (Postgres)
CREATE DATABASE offers_service;
\c offers_service;

-- Types like coupon code, credit card, debit card, wallet, bank offer, etc.
CREATE TABLE offer_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
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
