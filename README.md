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
## Detection rules

Each detection rule is a standalone SQL query in the `queries` folder. Every rule scans the transaction history and returns only the accounts or transactions that look suspicious.

### Burst spending

File name `01_burst_spending.sql`.

This rule uses a window function to count how many transactions an account performs in a rolling five minute window. If the count within that window exceeds a chosen threshold, for example eight transactions in five minutes, the account is flagged. In the seeded data this rule identifies account `2002`, which makes a rapid series of small purchases that look like card testing or automated fraud.

### Impossible travel

File name `02_impossible_travel.sql`.

This rule attaches city information to each transaction by joining to the merchants table, then compares pairs of transactions for the same account. If the same account appears in different cities within a short time gap, for example three hours, the movement is considered impossible and the account is flagged. In the seeded data this rule identifies account `2003`, which transacts in St Johns and Toronto within two hours.

### Amount outlier

File name `03_amount_outlier.sql`.

This rule computes the average transaction amount for each account and then compares every transaction with that account specific baseline. Any transaction that is much larger than the usual spend for that account is flagged as a simple amount outlier. In the seeded data this rule highlights a very large electronics purchase on account `2004` relative to its normal small daily spending.

### Device and IP churn

File name `04_device_ip_churn.sql`.

This rule groups transactions by account and calendar day and counts how many distinct device identifiers and IP addresses were used. Accounts that use many devices or many IPs in a single day are flagged, since this pattern is consistent with account takeover, credential sharing, or scripted attacks. In the seeded data this rule identifies account `2005`, which cycles through several devices and IPs during the same night.

## Risk scoring

File name `05_risk_score_view.sql`.

Fraud analysts usually do not look at raw rule outputs. Instead, they work from a prioritised queue of accounts with risk scores. The view `account_risk_scores` provides this queue.

The view performs four steps. First, it reruns each detection rule internally and assigns a point value to every rule that an account triggers, for example four points for impossible travel, three points for burst spending, and so on. Second, it unifies all of those rule outputs into a single set of flags. Third, it aggregates the flags by account and computes a total `risk_score` along with a count of `rules_triggered`. Finally, it orders accounts by descending risk score so that the most suspicious accounts appear at the top.

You can inspect the ranked results with

```sql
SELECT *
FROM account_risk_scores
ORDER BY risk_score DESC NULLS LAST;

