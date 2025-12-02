-- Q1: Revenue by sales channel
SELECT sales_channel,
  SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;
-- Q2: Top 10 customers
SELECT uid,
  SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;
-- Q3: Month-wise revenue, expense, profit, status
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
-- Q4: Most profitable clinic per city
WITH profit AS (
  SELECT c.city,
    c.cid,
    MONTH(s.datetime) AS mn,
    SUM(s.amount) - COALESCE(
      (
        SELECT SUM(amount)
        FROM expenses e
        WHERE e.cid = c.cid
          AND MONTH(e.datetime) = MONTH(s.datetime)
      ),
      0
    ) AS profit
  FROM clinics c
    JOIN clinic_sales s ON c.cid = s.cid
  GROUP BY c.city,
    c.cid,
    MONTH(s.datetime)
),
ranked AS (
  SELECT *,
    RANK() OVER (
      PARTITION BY city,
      mn
      ORDER BY profit DESC
    ) AS rnk
  FROM profit
)
SELECT *
FROM ranked
WHERE rnk = 1;
-- Q5: Second least profitable clinic per state
WITH profit AS (
  SELECT c.state,
    c.cid,
    MONTH(s.datetime) AS mn,
    SUM(s.amount) - COALESCE(
      (
        SELECT SUM(amount)
        FROM expenses e
        WHERE e.cid = c.cid
          AND MONTH(e.datetime) = MONTH(s.datetime)
      ),
      0
    ) AS profit
  FROM clinics c
    JOIN clinic_sales s ON c.cid = s.cid
  GROUP BY c.state,
    c.cid,
    MONTH(s.datetime)
),
ranked AS (
  SELECT *,
    RANK() OVER (
      PARTITION BY state,
      mn
      ORDER BY profit ASC
    ) AS rnk
  FROM profit
)
SELECT *
FROM ranked
WHERE rnk = 2;