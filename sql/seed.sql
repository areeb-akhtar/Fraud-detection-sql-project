-- Active: 1767496267769@@localhost@5433@fraud_db
-- Customers
INSERT INTO customers (customer_id, full_name, email, home_city, risk_tier, created_at) VALUES
(101, 'Areeb Akhtar', 'areeb101@example.com', 'St Johns', 'low',    '2025-11-01 10:00:00'),
(102, 'Noah Clarke',  'noah102@example.com',  'St Johns', 'low',    '2025-11-02 11:00:00'),
(103, 'Sara Khan',    'sara103@example.com',  'St Johns', 'medium', '2025-11-03 09:00:00'),
(104, 'Liam Murphy',  'liam104@example.com',  'St Johns', 'low',    '2025-11-04 14:00:00'),
(105, 'Hana Ali',     'hana105@example.com',  'St Johns', 'high',   '2025-11-05 16:00:00'),
(106, 'Omar Aziz',    'omar106@example.com',  'St Johns', 'medium', '2025-11-06 18:00:00');

-- Accounts
INSERT INTO accounts (account_id, customer_id, status, created_at) VALUES
(2001, 101, 'active', '2025-11-01 10:05:00'),
(2002, 102, 'active', '2025-11-02 11:05:00'),
(2003, 103, 'active', '2025-11-03 09:05:00'),
(2004, 104, 'active', '2025-11-04 14:05:00'),
(2005, 105, 'active', '2025-11-05 16:05:00'),
(2006, 106, 'active', '2025-11-06 18:05:00');

-- Merchants
INSERT INTO merchants (merchant_id, merchant_name, category, city) VALUES
(3001, 'Harbour Grocery',     'grocery',     'St Johns'),
(3002, 'Signal Coffee',       'cafe',        'St Johns'),
(3003, 'Avalon Gas',          'fuel',        'St Johns'),
(3004, 'Downtown Pharmacy',   'pharmacy',    'St Johns'),
(3005, 'Electro World',       'electronics', 'St Johns'),
(3006, 'Pearl Diner',         'restaurant',  'St Johns'),
(3007, 'Toronto Tech Mall',   'electronics', 'Toronto'),
(3008, 'Toronto Bistro',      'restaurant',  'Toronto'),
(3009, 'Gift Card Hub',       'gift_cards',  'St Johns'),
(3010, 'Online Market',       'ecommerce',   'Online');

-- Normal baseline transactions
-- Account 2001, normal behavior
INSERT INTO transactions VALUES
(4001, 2001, 3001, '2025-12-20 12:10:00',  24.60, 'CAD', 'card_present', 'approved', '198.51.100.10', 'dev_2001_A'),
(4002, 2001, 3002, '2025-12-21 09:10:00',   6.45, 'CAD', 'card_present', 'approved', '198.51.100.10', 'dev_2001_A'),
(4003, 2001, 3006, '2025-12-22 18:45:00',  32.10, 'CAD', 'card_present', 'approved', '198.51.100.10', 'dev_2001_A'),
(4004, 2001, 3003, '2025-12-23 08:20:00',  51.00, 'CAD', 'card_present', 'approved', '198.51.100.10', 'dev_2001_A');

-- Account 2006, normal online plus occasional decline
INSERT INTO transactions VALUES
(4010, 2006, 3010, '2025-12-20 20:30:00',  19.99, 'CAD', 'online', 'approved', '203.0.113.44', 'dev_2006_A'),
(4011, 2006, 3010, '2025-12-22 21:00:00',  79.95, 'CAD', 'online', 'approved', '203.0.113.44', 'dev_2006_A'),
(4012, 2006, 3010, '2025-12-24 21:05:00', 250.00, 'CAD', 'online', 'declined', '203.0.113.44', 'dev_2006_A'),
(4013, 2006, 3004, '2025-12-25 10:05:00',  14.20, 'CAD', 'card_present', 'approved', '203.0.113.44', 'dev_2006_A');

-- Anomaly 1, burst spending, account 2002
-- Many small approvals in a tight five minute window
INSERT INTO transactions VALUES
(4101, 2002, 3002, '2025-12-26 19:00:10',  4.50, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4102, 2002, 3002, '2025-12-26 19:00:45',  4.50, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4103, 2002, 3002, '2025-12-26 19:01:15',  4.50, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4104, 2002, 3009, '2025-12-26 19:01:40', 25.00, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4105, 2002, 3009, '2025-12-26 19:02:05', 25.00, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4106, 2002, 3001, '2025-12-26 19:02:40', 12.30, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4107, 2002, 3006, '2025-12-26 19:03:10', 18.75, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4108, 2002, 3006, '2025-12-26 19:03:40', 18.75, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4109, 2002, 3003, '2025-12-26 19:04:10',  8.00, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A'),
(4110, 2002, 3003, '2025-12-26 19:04:40',  8.00, 'CAD', 'card_present', 'approved', '198.51.100.20', 'dev_2002_A');

-- Anomaly 2, impossible travel, account 2003
INSERT INTO transactions VALUES
(4201, 2003, 3001, '2025-12-27 10:00:00', 22.10, 'CAD', 'card_present', 'approved', '198.51.100.30', 'dev_2003_A'),
(4202, 2003, 3006, '2025-12-27 10:10:00', 31.80, 'CAD', 'card_present', 'approved', '198.51.100.30', 'dev_2003_A'),
(4203, 2003, 3008, '2025-12-27 12:00:00', 44.00, 'CAD', 'card_present', 'approved', '203.0.113.88', 'dev_2003_A');

-- Anomaly 3, amount outlier, account 2004
-- Baseline small purchases, then one huge electronics transaction
INSERT INTO transactions VALUES
(4301, 2004, 3002, '2025-12-20 08:30:00',  5.25, 'CAD', 'card_present', 'approved', '198.51.100.40', 'dev_2004_A'),
(4302, 2004, 3004, '2025-12-21 11:10:00', 18.90, 'CAD', 'card_present', 'approved', '198.51.100.40', 'dev_2004_A'),
(4303, 2004, 3001, '2025-12-22 17:30:00', 29.10, 'CAD', 'card_present', 'approved', '198.51.100.40', 'dev_2004_A'),
(4304, 2004, 3005, '2025-12-28 15:00:00', 2499.99,'CAD', 'card_present', 'approved', '198.51.100.40', 'dev_2004_A');

-- Anomaly 4, device and IP churn, account 2005
-- Same day, many devices and IPs, mixed with declines
INSERT INTO transactions VALUES
(4401, 2005, 3010, '2025-12-26 02:10:00',  49.99, 'CAD', 'online', 'approved', '203.0.113.10', 'dev_2005_A'),
(4402, 2005, 3010, '2025-12-26 02:30:00',  49.99, 'CAD', 'online', 'declined', '203.0.113.11', 'dev_2005_B'),
(4403, 2005, 3010, '2025-12-26 03:05:00',  49.99, 'CAD', 'online', 'declined', '203.0.113.12', 'dev_2005_C'),
(4404, 2005, 3010, '2025-12-26 03:40:00',  49.99, 'CAD', 'online', 'approved', '203.0.113.13', 'dev_2005_D'),
(4405, 2005, 3010, '2025-12-26 04:10:00', 199.99, 'CAD', 'online', 'approved', '203.0.113.14', 'dev_2005_E');

SELECT *
FROM transactions
LIMIT 5;
