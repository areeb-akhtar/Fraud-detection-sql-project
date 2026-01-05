-- Active: 1767496267769@@localhost@5433@fraud_db
WITH stats AS (
  SELECT
    account_id,
    AVG(amount) AS avg_amt
  FROM transactions
  GROUP BY account_id
)
SELECT
  tr.txn_id,
  tr.account_id,
  tr.amount,
  s.avg_amt
FROM transactions tr
JOIN stats s ON s.account_id = tr.account_id
WHERE tr.amount >= 10 * s.avg_amt
ORDER BY tr.account_id, tr.txn_time;
