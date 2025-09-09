-- Merchant Directory Service Schema (Postgres)
CREATE DATABASE merchant_service;
\c merchant_service;

CREATE TABLE merchants (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    trust_score NUMERIC(3,2),
    return_policy TEXT,
    shipping_policy TEXT,
    website TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE merchant_reviews (
    id BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT REFERENCES merchants(id),
    user_id BIGINT,
    rating INTEGER,
    review TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE merchant_offers (
    merchant_id BIGINT REFERENCES merchants(id),
    offer_id BIGINT,
    PRIMARY KEY(merchant_id, offer_id)
);
