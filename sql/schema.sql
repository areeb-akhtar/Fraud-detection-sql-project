-- Active: 1767496267769@@localhost@5433@fraud_db
-- PostgreSQL
-- Fraud and anomaly detection mini schema

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id   INT PRIMARY KEY,
  full_name     TEXT NOT NULL,
  email         TEXT UNIQUE NOT NULL,
  home_city     TEXT NOT NULL,
  risk_tier     TEXT NOT NULL CHECK (risk_tier IN ('low','medium','high')),
  created_at    TIMESTAMP NOT NULL
);

CREATE TABLE accounts (
  account_id    INT PRIMARY KEY,
  customer_id   INT NOT NULL REFERENCES customers(customer_id),
  status        TEXT NOT NULL CHECK (status IN ('active','frozen','closed')),
  created_at    TIMESTAMP NOT NULL
);

CREATE TABLE merchants (
  merchant_id    INT PRIMARY KEY,
  merchant_name  TEXT NOT NULL,
  category       TEXT NOT NULL,
  city           TEXT NOT NULL
);

CREATE TABLE transactions (
  txn_id      INT PRIMARY KEY,
  account_id  INT NOT NULL REFERENCES accounts(account_id),
  merchant_id INT NOT NULL REFERENCES merchants(merchant_id),
  txn_time    TIMESTAMP NOT NULL,
  amount      NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  currency    TEXT NOT NULL DEFAULT 'CAD',
  channel     TEXT NOT NULL CHECK (channel IN ('card_present','online')),
  status      TEXT NOT NULL CHECK (status IN ('approved','declined')),
  ip_address  TEXT NOT NULL,
  device_id   TEXT NOT NULL
);

CREATE INDEX idx_txn_account_time ON transactions(account_id, txn_time);
CREATE INDEX idx_txn_merchant ON transactions(merchant_id);
