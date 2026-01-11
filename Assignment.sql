use test

-- "Raw data Profiling"
Select * from customers;
select * from [dbo].[events]
select * from [dbo].[subscriptions]
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM events;
SELECT COUNT(*) FROM subscriptions;

-- Task 1- checking Duplicates 
-- customer_copy
SELECT customer_id, signup_date, segment, COUNT(*) AS cnt
FROM customers
GROUP BY customer_id, signup_date, segment
HAVING COUNT(*) > 1;

-- Subcriptions
SELECT subscription_id, customer_id, start_date, end_date, COUNT(*) AS cnt
FROM subscriptions
GROUP BY subscription_id, customer_id, start_date, end_date
HAVING COUNT(*) > 1;
-- Evnets
SELECT event_id, customer_id, event_type, event_date,COUNT(*) AS cnt
FROM events
GROUP BY event_id, customer_id, event_type, event_date
HAVING COUNT(*) > 1;

--- Task 1 – Step 2: Missing Values Profiling
-- Customers – NULL check-- Before
SELECT
 SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
 SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS null_signup_date,
 SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS null_segment
FROM customers;

-- Subscriptions – NULL check-- before
SELECT
 SUM(CASE WHEN subscription_id IS NULL THEN 1 ELSE 0 END) AS null_subscription_id,
 SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
 SUM(CASE WHEN start_date IS NULL THEN 1 ELSE 0 END) AS null_start_date,
 SUM(CASE WHEN end_date IS NULL THEN 1 ELSE 0 END) AS null_end_date
FROM subscriptions;

-- Events – NULL check-- before
SELECT
 SUM(CASE WHEN event_id IS NULL THEN 1 ELSE 0 END) AS null_event_id,
 SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
 SUM(CASE WHEN event_type IS NULL THEN 1 ELSE 0 END) AS null_event_type
FROM events;

-- clean customers
-- Assumption: Missing customer segments indicate unclassified users and are labeled as 'Unknown'
-- Signup dates are left NULL to preserve historical accuracy

SELECT
    customer_id,
    signup_date,
    COALESCE(segment, 'Unknown') AS segment
INTO customers_clean
FROM customers;

select * from customers_clean

--Clean Subscriptions
-- Assumption: NULL end_date indicates an active subscription

SELECT
    subscription_id,
    customer_id,
    start_date,
    end_date,
    CASE 
        WHEN end_date IS NULL THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS subscription_status
INTO subscriptions_clean
FROM subscriptions;

-- Events (No transformation)
SELECT *
INTO events_clean
FROM events;

-- Quick cross check of null in newlly cleaned tables
---- Customers – NULL check- After
SELECT
 SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
 SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS null_signup_date,
 SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS null_segment
FROM customers_clean;

-- Subscriptions – NULL check--After
SELECT subscription_id, customer_id, start_date, end_date, COUNT(*) AS cnt
FROM subscriptions_clean
GROUP BY subscription_id, customer_id, start_date, end_date
HAVING COUNT(*) > 1;

-- Events – NULL check - After
SELECT
 SUM(CASE WHEN event_id IS NULL THEN 1 ELSE 0 END) AS null_event_id,
 SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
 SUM(CASE WHEN event_type IS NULL THEN 1 ELSE 0 END) AS null_event_type
FROM events_clean;

-- validation check
SELECT
 SUM(CASE WHEN end_date IS NULL THEN 1 ELSE 0 END) AS active_subscriptions,
 SUM(CASE WHEN subscription_status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_flagged
FROM subscriptions_clean;


-- Task 2 

-- Metric 1: Monthly MRR
-- Assumption: Full monthly price is counted if subscription is active for at least one day in the month

-- Monthly MRR calculation
-- Assumption: Full monthly price is counted if subscription is active for at least one day in the month

WITH months AS (
    SELECT DISTINCT
        DATEFROMPARTS(YEAR(d), MONTH(d), 1) AS month_start,
        EOMONTH(d) AS month_end
    FROM (
        SELECT start_date AS d FROM subscriptions
        UNION
        SELECT end_date FROM subscriptions WHERE end_date IS NOT NULL
    ) x
)
SELECT
    m.month_start,
    SUM(s.monthly_price) AS monthly_mrr
FROM months m
JOIN subscriptions s
  ON s.start_date <= m.month_end
 AND (s.end_date IS NULL OR s.end_date >= m.month_start)
GROUP BY m.month_start
ORDER BY m.month_start;

-- Metric 2: ARR (Annual Recurring Revenue)
-- ARR = MRR × 12
-- ARR calculation based on Monthly MRR
-- -- Assumption: ARR is annualized from current MRR without forecasting growth or churn.


WITH months AS (
    SELECT DISTINCT
        DATEFROMPARTS(YEAR(d), MONTH(d), 1) AS month_start,
        EOMONTH(d) AS month_end
    FROM (
        SELECT start_date AS d FROM subscriptions
        UNION
        SELECT end_date FROM subscriptions WHERE end_date IS NOT NULL
    ) x
),
mrr AS (
    SELECT
        m.month_start,
        SUM(s.monthly_price) AS monthly_mrr
    FROM months m
    JOIN subscriptions s
      ON s.start_date <= m.month_end
     AND (s.end_date IS NULL OR s.end_date >= m.month_start)
    GROUP BY m.month_start
)
SELECT
    month_start,
    monthly_mrr,
    monthly_mrr * 12 AS arr
FROM mrr
ORDER BY month_start;


-- Metric 3: Customer (Logo) Churn Rate
-- Business Understanding(A churned customer is a customer who had at least one active subscription in the previous month 
                          --and zero active subscriptions in the current month.)

-- Rationale: This avoids: * Counting new customers as churn  * Double-counting customers with multiple subscriptions

-- Customer (Logo) Churn Rate
WITH months AS (
    SELECT DISTINCT
        DATEFROMPARTS(YEAR(d), MONTH(d), 1) AS month_start,
        EOMONTH(d) AS month_end
    FROM (
        SELECT start_date AS d FROM subscriptions
        UNION
        SELECT end_date FROM subscriptions WHERE end_date IS NOT NULL
    ) x
),
active_customers AS (
    SELECT DISTINCT
        m.month_start,
        s.customer_id
    FROM months m
    JOIN subscriptions s
      ON s.start_date <= m.month_end
     AND (s.end_date IS NULL OR s.end_date >= m.month_start)
),
churn_calc AS (
    SELECT
        curr.month_start AS month_start,
        COUNT(DISTINCT prev.customer_id) AS prev_active_customers,
        COUNT(DISTINCT CASE
            WHEN curr.customer_id IS NULL THEN prev.customer_id
        END) AS churned_customers
    FROM active_customers prev
    LEFT JOIN active_customers curr
      ON prev.customer_id = curr.customer_id
     AND curr.month_start = DATEADD(MONTH, 1, prev.month_start)
    GROUP BY curr.month_start
)
SELECT
    month_start,
    prev_active_customers,
    churned_customers,
    CAST(churned_customers * 1.0 / prev_active_customers AS DECIMAL(10,4)) AS customer_churn_rate
FROM churn_calc
WHERE prev_active_customers > 0
ORDER BY month_start;

-- Metric 4 : Revenue Churn Rate
-- BUsiness understanding : Revenue churn rate measures the proportion of recurring revenue lost compared to the previous month.

-- Revenue Churn Rate using LAG
-- Assumption: Revenue churn is calculated as lost MRR compared to previous month

WITH months AS (
    SELECT DISTINCT
        DATEFROMPARTS(YEAR(d), MONTH(d), 1) AS month_start,
        EOMONTH(d) AS month_end
    FROM (
        SELECT start_date AS d FROM subscriptions
        UNION
        SELECT end_date FROM subscriptions WHERE end_date IS NOT NULL
    ) x
),
mrr AS (
    SELECT
        m.month_start,
        SUM(s.monthly_price) AS monthly_mrr
    FROM months m
    JOIN subscriptions s
      ON s.start_date <= m.month_end
     AND (s.end_date IS NULL OR s.end_date >= m.month_start)
    GROUP BY m.month_start
),
mrr_with_lag AS (
    SELECT
        month_start,
        monthly_mrr,
        LAG(monthly_mrr) OVER (ORDER BY month_start) AS prev_month_mrr
    FROM mrr
)
SELECT
    month_start,
    monthly_mrr,
    prev_month_mrr,
    CASE
        WHEN prev_month_mrr IS NULL THEN NULL
        WHEN monthly_mrr < prev_month_mrr
             THEN (prev_month_mrr - monthly_mrr) * 1.0 / prev_month_mrr
        ELSE 0
    END AS revenue_churn_rate
FROM mrr_with_lag
ORDER BY month_start;


-- Metric 5- Average Revenue per Customer (ARPC)
-- Logic: ARPC = Monthly MRR ÷ Total number of customers

-- Average Revenue per Customer (ARPC)
-- Assumption: ARPC is calculated using total customer base (not only active customers)

WITH months AS (
    SELECT DISTINCT
        DATEFROMPARTS(YEAR(d), MONTH(d), 1) AS month_start,
        EOMONTH(d) AS month_end
    FROM (
        SELECT start_date AS d FROM subscriptions
        UNION
        SELECT end_date FROM subscriptions WHERE end_date IS NOT NULL
    ) x
),
mrr AS (
    SELECT
        m.month_start,
        SUM(s.monthly_price) AS monthly_mrr
    FROM months m
    JOIN subscriptions s
      ON s.start_date <= m.month_end
     AND (s.end_date IS NULL OR s.end_date >= m.month_start)
    GROUP BY m.month_start
),
customer_count AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers
    FROM customers
)
SELECT
    m.month_start,
    m.monthly_mrr,
    c.total_customers,
    CAST(m.monthly_mrr * 1.0 / c.total_customers AS DECIMAL(10,2)) AS arpc
FROM mrr m
CROSS JOIN customer_count c
ORDER BY m.month_start;


-- Task 3- Funnel Analysis

-- Sanity check - Confirm funnel event names - to avoid wrong assumptions about data

SELECT DISTINCT event_type
FROM events
ORDER BY event_type;

-- Funnel required-- Signup → Trial → Activated → Paid → Churned

-- Funnel analysis
-- Assumption:
-- Paid users are identified via presence of a subscription
-- Funnel is customer-level (each stage counted once per customer)

WITH funnel AS (
    SELECT
        c.customer_id,

        MAX(CASE WHEN e.event_type = 'signup' THEN 1 ELSE 0 END) AS signup,
        MAX(CASE WHEN e.event_type = 'trial_start' THEN 1 ELSE 0 END) AS trial,
        MAX(CASE WHEN e.event_type = 'activated' THEN 1 ELSE 0 END) AS activated,
        MAX(CASE WHEN s.subscription_id IS NOT NULL THEN 1 ELSE 0 END) AS paid,
        MAX(CASE WHEN e.event_type = 'churned' THEN 1 ELSE 0 END) AS churned

    FROM customers c
    LEFT JOIN events e
        ON c.customer_id = e.customer_id
    LEFT JOIN subscriptions s
        ON c.customer_id = s.customer_id
    GROUP BY c.customer_id
)
SELECT
    SUM(signup) AS signup_users,
    SUM(trial) AS trial_users,
    SUM(activated) AS activated_users,
    SUM(paid) AS paid_users,
    SUM(churned) AS churned_users
FROM funnel;


-- Funnel conversion rates
WITH funnel AS (
    SELECT
        c.customer_id,
        MAX(CASE WHEN e.event_type = 'signup' THEN 1 ELSE 0 END) AS signup,
        MAX(CASE WHEN e.event_type = 'trial_start' THEN 1 ELSE 0 END) AS trial,
        MAX(CASE WHEN e.event_type = 'activated' THEN 1 ELSE 0 END) AS activated,
        MAX(CASE WHEN s.subscription_id IS NOT NULL THEN 1 ELSE 0 END) AS paid
    FROM customers c
    LEFT JOIN events e ON c.customer_id = e.customer_id
    LEFT JOIN subscriptions s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id
)
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(signup) AS signup_users,
    SUM(trial) AS trial_users,
    SUM(activated) AS activated_users,
    SUM(paid) AS paid_users,

    CAST(SUM(trial) * 1.0 / NULLIF(SUM(signup), 0) AS DECIMAL(10,2)) AS signup_to_trial_rate,
    CAST(SUM(activated) * 1.0 / NULLIF(SUM(trial), 0) AS DECIMAL(10,2)) AS trial_to_activated_rate,
    CAST(SUM(paid) * 1.0 / NULLIF(SUM(activated), 0) AS DECIMAL(10,2)) AS activated_to_paid_rate
FROM funnel;


