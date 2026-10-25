-- Table 5

SELECT *
FROM monthly_revenue
;

SELECT *, ROW_NUMBER() OVER(PARTITION BY month_start, monthly_revenue) as row_num
FROM monthly_revenue
;

SELECT *
FROM monthly_revenue
WHERE month_start IS NULL
;

SELECT *
FROM monthly_revenue
WHERE monthly_revenue IS NULL
;

SELECT MONTH(month_start) as `month`, monthly_revenue
FROM monthly_revenue
;

SELECT *, SUM(monthly_revenue) OVER(ORDER BY monthly_revenue) as rolling_total
FROM monthly_revenue
;

SELECT *, SUM(monthly_revenue) OVER(ORDER BY month_start) as rolling_total
FROM monthly_revenue
;
# this is the accurate rolling total for the entire dataset ordered by month instead of revenue

SELECT MONTH(month_start) as `month`, monthly_revenue,
LAG(monthly_revenue) OVER (ORDER BY month_start) as prev_month_revenue
FROM monthly_revenue
;

WITH Lag_month as
(
SELECT MONTH(month_start) as `month`, monthly_revenue,
LAG(monthly_revenue) OVER (ORDER BY month_start) as prev_month_revenue
FROM monthly_revenue
)
SELECT monthly_revenue, prev_month_revenue,
(monthly_revenue - prev_month_revenue)/prev_month_revenue * 100
FROM Lag_month
;

SELECT MONTH(month_start) as `month`, monthly_revenue,
AVG(monthly_revenue) OVER(ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_3momth_avg
FROM monthly_revenue
;

