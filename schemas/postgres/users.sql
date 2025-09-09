-- User Service Schema (Postgres)
CREATE DATABASE user_service;
\c user_service;

CREATE TYPE customer_type AS ENUM ('customer','poster');

CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    mobile TEXT,
    customer_type customer_type NOT NULL DEFAULT 'customer',
    city TEXT,
    exact_location TEXT,
    is_shadowbanned BOOLEAN DEFAULT FALSE,
    deal_submission_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Devices owned by a customer
CREATE TABLE devices (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    device_type TEXT,
    os TEXT,
    push_token TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TYPE payment_type AS ENUM ('credit_card','debit_card','upi','wallet','bank_account','coin');

-- Payment methods attached to a customer
CREATE TABLE payment_methods (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    type payment_type NOT NULL,
    provider TEXT,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Credit card details
CREATE TABLE credit_cards (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    bank TEXT,
    last4 TEXT,
    expiry_month INTEGER,
    expiry_year INTEGER,
    annual_fee_waiver BOOLEAN DEFAULT FALSE
);

-- Debit card details
CREATE TABLE debit_cards (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    bank TEXT,
    last4 TEXT,
    expiry_month INTEGER,
    expiry_year INTEGER
);

-- Wallet accounts
CREATE TABLE wallets (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    wallet_id TEXT,
    balance NUMERIC(12,2) DEFAULT 0
);

-- UPI accounts
CREATE TABLE upi_accounts (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    upi_id TEXT
);

-- Bank accounts
CREATE TABLE bank_accounts (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    account_number_last4 TEXT,
    ifsc TEXT
);

-- Coin wallets
CREATE TABLE coins (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    provider TEXT,
    balance NUMERIC(12,2) DEFAULT 0
);

-- Membership accounts separate from payment methods
CREATE TABLE memberships (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    provider TEXT,
    membership_id TEXT,
    expiry_date DATE,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Hot-path cache of payment options
CREATE TABLE user_payment_options_flat (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES customers(id),
    type payment_type,
    provider TEXT,
    last4 TEXT,
    expiry_month INTEGER,
    expiry_year INTEGER,
    status TEXT,
    issuer TEXT,
    network TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_user_payment_options_user ON user_payment_options_flat(user_id);
CREATE INDEX idx_user_payment_options_status ON user_payment_options_flat(status);
CREATE INDEX idx_user_payment_options_type ON user_payment_options_flat(type);
