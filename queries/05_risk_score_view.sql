-- Active: 1767496267769@@localhost@5433@fraud_db
CREATE OR REPLACE VIEW account_risk_scores AS
WITH burst AS (
  SELECT DISTINCT account_id, 3 AS points FROM (
    SELECT
      account_id,
      txn_time,
      COUNT(*) OVER (
        PARTITION BY account_id
        ORDER BY txn_time
        RANGE BETWEEN INTERVAL '5 minutes' PRECEDING AND CURRENT ROW
      ) AS c
    FROM transactions
  ) x
  WHERE c >= 8
),
travel AS (
  SELECT DISTINCT a.account_id, 4 AS points
  FROM (
    SELECT tr.account_id, tr.txn_id, tr.txn_time, m.city
    FROM transactions tr JOIN merchants m ON m.merchant_id = tr.merchant_id
  ) a
  JOIN (
    SELECT tr.account_id, tr.txn_id, tr.txn_time, m.city
    FROM transactions tr JOIN merchants m ON m.merchant_id = tr.merchant_id
  ) b
  ON a.account_id = b.account_id
  AND a.txn_id <> b.txn_id
  AND a.city <> b.city
  AND ABS(EXTRACT(EPOCH FROM (a.txn_time - b.txn_time))) <= 3 * 3600
),
outlier AS (
  SELECT DISTINCT tr.account_id, 2 AS points
  FROM transactions tr
  JOIN (
    SELECT account_id, AVG(amount) AS avg_amt
    FROM transactions
    GROUP BY account_id
  ) s
  ON s.account_id = tr.account_id
  WHERE tr.amount >= 10 * s.avg_amt
),
churn AS (
  SELECT DISTINCT account_id, 2 AS points
  FROM transactions
  GROUP BY account_id, DATE(txn_time)
  HAVING COUNT(DISTINCT device_id) >= 4 OR COUNT(DISTINCT ip_address) >= 4
),
all_flags AS (
  SELECT * FROM burst
  UNION ALL SELECT * FROM travel
  UNION ALL SELECT * FROM outlier
  UNION ALL SELECT * FROM churn
)
SELECT
  a.account_id,
  SUM(f.points) AS risk_score,
  COUNT(*) AS rules_triggered
FROM accounts a
LEFT JOIN all_flags f ON f.account_id = a.account_id
GROUP BY a.account_id
ORDER BY risk_score DESC NULLS LAST, rules_triggered DESC, a.account_id;

SELECT *
FROM account_risk_scores
ORDER BY risk_score DESC NULLS LAST;
