-- Q1: Last booked room per user
SELECT user_id,
  room_no
FROM (
    SELECT user_id,
      room_no,
      ROW_NUMBER() OVER (
        PARTITION BY user_id
        ORDER BY booking_date DESC
      ) AS rnk
    FROM bookings
  ) t
WHERE rnk = 1;
-- Q2: Booking + billing amount for Nov 2021
SELECT b.booking_id,
  SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM bookings b
  JOIN booking_commercials bc ON b.booking_id = bc.booking_id
  JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(b.booking_date) = 11
  AND YEAR(b.booking_date) = 2021
GROUP BY b.booking_id;
-- Q3: Bills > 1000 in Oct 2021
SELECT bc.bill_id,
  SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
  JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 10
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;
-- Q4: Most & least ordered items per month (2021)
WITH monthly AS (
  SELECT MONTH(bill_date) AS mn,
    item_id,
    SUM(item_quantity) AS qty
  FROM booking_commercials
  WHERE YEAR(bill_date) = 2021
  GROUP BY MONTH(bill_date),
    item_id
),
ranked AS (
  SELECT *,
    RANK() OVER (
      PARTITION BY mn
      ORDER BY qty DESC
    ) AS rk_desc,
    RANK() OVER (
      PARTITION BY mn
      ORDER BY qty ASC
    ) AS rk_asc
  FROM monthly
)
SELECT mn,
  item_id,
  qty,
  'MOST' AS type
FROM ranked
WHERE rk_desc = 1
UNION ALL
SELECT mn,
  item_id,
  qty,
  'LEAST' AS type
FROM ranked
WHERE rk_asc = 1;
-- Q5: Second highest bill per month
WITH bills AS (
  SELECT bill_id,
    MONTH(bill_date) AS mn,
    SUM(item_quantity * i.item_rate) AS amount
  FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
  GROUP BY bill_id,
    MONTH(bill_date)
),
ranked AS (
  SELECT *,
    DENSE_RANK() OVER (
      PARTITION BY mn
      ORDER BY amount DESC
    ) AS rnk
  FROM bills
)
SELECT *
FROM ranked
WHERE rnk = 2;