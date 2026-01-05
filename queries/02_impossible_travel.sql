-- Active: 1767496267769@@localhost@5433@fraud_db
WITH tx AS (
  SELECT
    tr.txn_id,
    tr.account_id,
    tr.txn_time,
    m.city
  FROM transactions tr
  JOIN merchants m ON m.merchant_id = tr.merchant_id
)
SELECT DISTINCT
  a.account_id
FROM tx a
JOIN tx b
  ON a.account_id = b.account_id
  AND a.txn_id <> b.txn_id
  AND a.city <> b.city
  AND ABS(EXTRACT(EPOCH FROM (a.txn_time - b.txn_time))) <= 3 * 3600
ORDER BY a.account_id;
