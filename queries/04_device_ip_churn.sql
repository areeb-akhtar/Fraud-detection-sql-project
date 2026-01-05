-- Active: 1767496267769@@localhost@5433@fraud_db
SELECT
  account_id,
  DATE(txn_time) AS day,
  COUNT(DISTINCT device_id) AS devices,
  COUNT(DISTINCT ip_address) AS ips
FROM transactions
GROUP BY account_id, DATE(txn_time)
HAVING COUNT(DISTINCT device_id) >= 4 OR COUNT(DISTINCT ip_address) >= 4
ORDER BY account_id, day;
