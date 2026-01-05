# Fraud Detection in Transaction Data with PostgreSQL and SQL

This project is a small rule based fraud and anomaly detection system built purely on PostgreSQL and SQL.  
It simulates card transactions for a few customer accounts, injects realistic fraudulent behaviour, then uses analytic SQL queries to flag suspicious accounts and rank them by risk.

The goal is to show strong data modelling and SQL skills rather than heavy use of frameworks.

---

## Project overview

The system models a payment environment with customers, accounts, merchants, and transactions.  
Most accounts behave normally. A few accounts have clearly suspicious patterns such as very fast spending, impossible travel between cities, or frequent device changes.

Detection is done with SQL only.  
Each detection rule is a query that scans historical data and produces a list of suspicious accounts or transactions.  
A final risk scoring view combines these rules into one ranked list for investigation.

---

## Tech stack

PostgreSQL  
SQL window functions, joins, common table expressions  
Docker Compose for local database setup  
VS Code and a SQL client extension for running queries

---

## Repository structure

`docker-compose.yml`  
Defines a local PostgreSQL service with database `fraud_db`.

`sql/schema.sql`  
Creates the relational schema for customers, accounts, merchants, and transactions, including foreign keys and indexes.

`sql/seed.sql`  
Inserts a small synthetic dataset, with both normal behaviour and intentionally injected anomalies.

`queries/01_burst_spending.sql`  
Flags accounts with very high transaction volume in a short time window.

`queries/02_impossible_travel.sql`  
Flags accounts that transact in different cities within an unrealistic travel time.

`queries/03_amount_outlier.sql`  
Flags transactions that are much larger than the account usual spend.

`queries/04_device_ip_churn.sql`  
Flags accounts that switch between many devices or IP addresses in one day.

`queries/05_risk_score_view.sql`  
Creates a view that aggregates fraud signals from all rules into a simple risk score per account.

---

## Data model

The schema follows a simple transactional design.

Customers  
Basic customer information and a coarse risk tier.

Accounts  
One account per customer in this mini dataset, with status and creation time.

Merchants  
Merchants with category and city so that rules can reason about geography and spending context.

Transactions  
The core fact table, each row represents a card transaction with account id, merchant id, timestamp, amount, channel, status, device id, and IP address.

You can inspect the tables with for example

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
``
SELECT *
FROM transactions
LIMIT 10;
```

Running the project locally

Prerequisites

Docker and Docker Compose installed
Any SQL client that can connect to PostgreSQL on localhost

Start PostgreSQL

docker compose up -d


This starts a PostgreSQL container with database fraud_db, user app, password apppass.

Apply schema and seed data

Connect to fraud_db on localhost port 5432 with your SQL client, then run in order

\i sql/schema.sql;
\i sql/seed.sql;


If your client does not support \i, just open each file and execute its contents.

Run detection rules

Execute each query file in the queries folder and inspect the results.

Finally, create the risk score view and query it.

\i queries/05_risk_score_view.sql;

SELECT *
FROM account_risk_scores
ORDER BY risk_score DESC NULLS LAST;
