-- User Service Schema (Postgres)
CREATE DATABASE user_service;
\c user_service;

-- Extensions for case-insensitive text and encryption
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enumerations
CREATE TYPE customer_role AS ENUM ('customer','poster','moderator','admin');
CREATE TYPE kyc_status AS ENUM ('pending','verified','rejected');
CREATE TYPE payment_type AS ENUM ('credit_card','debit_card','upi','wallet','bank_account');
CREATE TYPE payment_status AS ENUM ('active','expired','blocked','verification_pending','tokenized');

-- Customers
CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email CITEXT UNIQUE NOT NULL,
    mobile TEXT UNIQUE,
    role customer_role NOT NULL DEFAULT 'customer',
    email_verified_at TIMESTAMPTZ,
    mobile_verified_at TIMESTAMPTZ,
    kyc_status kyc_status NOT NULL DEFAULT 'pending',
    locale TEXT,
    timezone TEXT,
    currency TEXT,
    marketing_opt_in BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    deactivated_at TIMESTAMPTZ,
    deactivated_by BIGINT,
    exact_location BYTEA,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Consent and audit
CREATE TABLE consent_records (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    channel TEXT,
    purpose TEXT,
    granted_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ
);

CREATE TABLE pii_access_log (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    accessor_id BIGINT,
    field TEXT,
    accessed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Provider catalogs
CREATE TABLE issuers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE card_networks (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE wallet_providers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE upi_psps (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO card_networks (name) VALUES ('Visa'), ('Mastercard'), ('RuPay');
INSERT INTO issuers (name) VALUES ('HDFC Bank'), ('ICICI Bank');
INSERT INTO wallet_providers (name) VALUES ('Paytm'), ('PhonePe');
INSERT INTO upi_psps (name) VALUES ('PhonePe'), ('Google Pay');

-- Payment methods
CREATE TABLE payment_methods (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    type payment_type NOT NULL,
    status payment_status NOT NULL DEFAULT 'active',
    issuer_id BIGINT REFERENCES issuers(id),
    network BIGINT REFERENCES card_networks(id),
    last4 TEXT,
    expiry_month INTEGER,
    expiry_year INTEGER,
    name_on_card TEXT,
    billing_address_id BIGINT,
    vault_token TEXT,
    provider_token TEXT,
    token_provider TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- UPI accounts
CREATE TABLE upi_accounts (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    vpa TEXT UNIQUE,
    psp_id BIGINT REFERENCES upi_psps(id),
    verified_at TIMESTAMPTZ,
    last_verified_at TIMESTAMPTZ
);

-- Wallet accounts
CREATE TABLE wallet_accounts (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    provider_id BIGINT REFERENCES wallet_providers(id),
    kyc_tier TEXT,
    balance_snapshot_at TIMESTAMPTZ,
    linked_mobile TEXT
);

-- Bank accounts
CREATE TABLE bank_accounts (
    payment_method_id BIGINT PRIMARY KEY REFERENCES payment_methods(id),
    account_type TEXT,
    account_number_last4 TEXT,
    ifsc TEXT,
    branch_metadata JSONB
);

-- Memberships
CREATE TABLE membership_providers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    plan_tier TEXT,
    region TEXT
);

CREATE TABLE user_memberships (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    provider_id BIGINT REFERENCES membership_providers(id),
    start_at TIMESTAMPTZ,
    expiry_at TIMESTAMPTZ,
    auto_renew BOOLEAN DEFAULT FALSE,
    verification_proof TEXT
);

CREATE TABLE offer_eligibility_tags (
    id BIGSERIAL PRIMARY KEY,
    provider_id BIGINT REFERENCES membership_providers(id),
    tag TEXT NOT NULL
);

INSERT INTO membership_providers (name, plan_tier, region) VALUES ('Prime', 'standard', 'IN');
INSERT INTO offer_eligibility_tags (provider_id, tag) VALUES (1, 'Prime-Only');

-- Devices and notifications
CREATE TABLE devices (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    os TEXT,
    app_version TEXT,
    push_token TEXT,
    last_seen TIMESTAMPTZ,
    revoked BOOLEAN DEFAULT FALSE,
    risk_marker TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notification_prefs (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    channel TEXT,
    topic TEXT,
    frequency TEXT,
    quiet_start TIME,
    quiet_end TIME,
    geo_radius INTEGER
);

CREATE TABLE device_notifications (
    id BIGSERIAL PRIMARY KEY,
    device_id BIGINT REFERENCES devices(id),
    channel TEXT,
    allowed BOOLEAN DEFAULT TRUE,
    language TEXT
);

-- Follows and watchlists
CREATE TABLE follows (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    entity_type TEXT,
    entity_id BIGINT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE watchlists (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    name TEXT
);

CREATE TABLE watch_conditions (
    id BIGSERIAL PRIMARY KEY,
    watchlist_id BIGINT REFERENCES watchlists(id),
    product_id BIGINT,
    price_threshold NUMERIC(12,2),
    keyword TEXT,
    merchant TEXT,
    region TEXT
);

CREATE TABLE watch_alerts (
    id BIGSERIAL PRIMARY KEY,
    watch_condition_id BIGINT REFERENCES watch_conditions(id),
    channel TEXT,
    frequency TEXT,
    expires_at TIMESTAMPTZ
);

-- Indexes for hot paths
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_mobile ON customers(mobile);
CREATE INDEX idx_payment_methods_customer ON payment_methods(customer_id, type, status);
CREATE INDEX idx_devices_customer_last_seen ON devices(customer_id, last_seen);
CREATE INDEX idx_user_memberships_customer ON user_memberships(customer_id, provider_id, expiry_at);
CREATE INDEX idx_notification_prefs_customer ON notification_prefs(customer_id, topic, channel);
