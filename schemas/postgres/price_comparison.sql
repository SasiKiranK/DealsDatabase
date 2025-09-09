-- Price Comparison Service Schema (Postgres)
CREATE DATABASE price_comparison_service;
\c price_comparison_service;

CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    brand TEXT,
    specs JSONB
);

CREATE TABLE product_prices (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(id),
    store_id BIGINT,
    price NUMERIC(12,2),
    captured_at TIMESTAMPTZ DEFAULT NOW()
);
