-- Q1: Revenue by sales channel (Yearly)
SELECT sales_channel,
  SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;
-- Q2: Top 10 Most Valuable Customers

SELECT uid,
  SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;
-- Q3: Month-wise Revenue, Expense, Profit, Status
WITH rev AS (
  SELECT MONTH(datetime) AS mn,
    SUM(amount) AS revenue
  FROM clinic_sales
  WHERE YEAR(datetime) = 2021
  GROUP BY MONTH(datetime)
),
exp AS (
  SELECT MONTH(datetime) AS mn,
    SUM(amount) AS expense
  FROM expenses
  WHERE YEAR(datetime) = 2021
  GROUP BY MONTH(datetime)
)
SELECT r.mn,
  r.revenue,
  e.expense,
  (r.revenue - e.expense) AS profit,
  CASE
    WHEN (r.revenue - e.expense) > 0 THEN 'profitable'
    ELSE 'not-profitable'
  END AS status
FROM rev r
  LEFT JOIN exp e ON r.mn = e.mn;

-- Q4: Most Profitable Clinic per City
WITH sales_monthly AS (
    SELECT 
        s.cid,
        MONTH(s.datetime) AS mn,
        SUM(s.amount) AS revenue
    FROM clinic_sales s
    GROUP BY s.cid, MONTH(s.datetime)
),
expenses_monthly AS (
    SELECT 
        e.cid,
        MONTH(e.datetime) AS mn,
        SUM(e.amount) AS expense
    FROM expenses e
    GROUP BY e.cid, MONTH(e.datetime)
),
profit AS (
    SELECT 
        c.city,
        c.cid,
        sm.mn,
        sm.revenue - COALESCE(em.expense, 0) AS profit
    FROM clinics c
    JOIN sales_monthly sm ON c.cid = sm.cid
    LEFT JOIN expenses_monthly em ON sm.cid = em.cid AND sm.mn = em.mn
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY city, mn ORDER BY profit DESC) AS rnk
    FROM profit
)
SELECT *
FROM ranked
WHERE rnk = 1;

-- Q5: Second Least Profitable Clinic per State

WITH sales_monthly AS (
    SELECT 
        s.cid,
        MONTH(s.datetime) AS mn,
        SUM(s.amount) AS revenue
    FROM clinic_sales s
    GROUP BY s.cid, MONTH(s.datetime)
),
expenses_monthly AS (
    SELECT 
        e.cid,
        MONTH(e.datetime) AS mn,
        SUM(e.amount) AS expense
    FROM expenses e
    GROUP BY e.cid, MONTH(e.datetime)
),
profit AS (
    SELECT 
        c.state,
        c.cid,
        sm.mn,
        sm.revenue - COALESCE(em.expense, 0) AS profit
    FROM clinics c
    JOIN sales_monthly sm ON c.cid = sm.cid
    LEFT JOIN expenses_monthly em ON sm.cid = em.cid AND sm.mn = em.mn
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY state, mn ORDER BY profit ASC) AS rnk
    FROM profit
)
SELECT *
FROM ranked
WHERE rnk = 2;
