-- ============================================================================
-- tests/03_eda_practice_checks.sql
-- Independent cross-checks for the eda_practice database.
-- ============================================================================
USE eda_practice;

-- employees: raw table untouched (2 NULL salaries) and every non-imputed value copied correctly. Expect: 2, 0
SELECT (SELECT SUM(salary IS NULL) FROM employees) AS raw_null_salaries,
       (SELECT COUNT(*) FROM employees e JOIN employees_staging s USING (employee_id)
        WHERE e.salary IS NOT NULL AND e.salary <> s.salary_estimate) AS mismatched_values;

-- tweets: weekday totals (Sun..Sat). Expect 70, 53, 70, 45, 51, 58, 53 (sum 400)
SELECT DAYOFWEEK(tweet_date) AS dow, DAYNAME(tweet_date) AS day_name, COUNT(*) AS tweets
FROM tweets GROUP BY dow, day_name ORDER BY dow;
-- Chi-square test vs. "equal per calendar day" (Sun occurs 12x, other days 13x in the 90-day span):
-- statistic = 12.21, 6 degrees of freedom, p = 0.0575 (not significant at 5%). Calculated in Python (scipy).

-- monthly_revenue: totals and quarter-on-quarter. Expect 156,600 total; quarters 30,600 / 35,800 / 41,000 / 49,200
SELECT QUARTER(month_start) AS q, SUM(monthly_revenue) AS revenue FROM monthly_revenue GROUP BY q;

-- events: pooled CTR across all apps = 4 clicks / 11 impressions = 36.36%
SELECT SUM(event_type = 'click') AS clicks, SUM(event_type = 'impression') AS impressions,
       ROUND(100 * SUM(event_type = 'click') / SUM(event_type = 'impression'), 2) AS pooled_ctr_pct
FROM events;

-- events: why averaging daily rates is wrong. App 1: daily CTRs are 33.33% and 100%.
-- Their average is 66.67%, but the true CTR is 3 clicks / 5 impressions = 60%.
SELECT ROUND((100/3 + 100) / 2, 2) AS average_of_daily_rates, ROUND(100 * 3 / 5, 2) AS true_rate;

-- job_listings: a PARTITION BY that includes the primary key can never find duplicates. Expect MAX = 1
SELECT MAX(rn) AS max_row_number FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY job_id, company_id, title, description ORDER BY job_id) AS rn
  FROM job_listings) t;
