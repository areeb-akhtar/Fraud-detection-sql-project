-- Active: 1767496267769@@localhost@5433@fraud_db
WITH t AS (
  SELECT
    account_id,
    txn_time,
    COUNT(*) OVER (
      PARTITION BY account_id
      ORDER BY txn_time
      RANGE BETWEEN INTERVAL '5 minutes' PRECEDING AND CURRENT ROW
    ) AS txns_in_5m
  FROM transactions
)
SELECT DISTINCT account_id
FROM t
WHERE txns_in_5m >= 8
ORDER BY account_id;
