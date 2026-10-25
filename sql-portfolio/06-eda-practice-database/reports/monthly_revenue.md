# Report · `monthly_revenue`

[← Back to project 06](../README.md)

> **Overview:** We have one revenue figure per month for 2023. The main point is that "revenue grew 80%". The question is whether that story hides anything.

**Script:** [`EDA practice_monthly _revenue.sql`](../sql/EDA%20practice_monthly%20_revenue.sql)

![Revenue](../../images/revenue_mom_ma.png)

| Column | Meaning |
|---|---|
| `month_start` | first day of the month, Jan to Dec 2023 |
| `monthly_revenue` | revenue for that month |

## 1 · Quality checks

| Check | Result |
|---|---|
| Duplicate months | none |
| NULLs / zero / negative revenue | none |
| Completeness | 12 rows for a 12-month span (checked by comparing the row count with the month span, not by row count alone, so a *missing* month would be caught) |

## 2 · Month-over-month growth with `LAG`

`LAG()` looks at the **previous row**, which is exactly what "last month" means.

```sql
WITH lag_month AS (
    SELECT month_start, monthly_revenue,
           LAG(monthly_revenue) OVER (ORDER BY month_start) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT month_start, monthly_revenue, prev_month_revenue,
       (monthly_revenue - prev_month_revenue) / prev_month_revenue * 100 AS mom_growth_pct
FROM lag_month;
```

| monthly_revenue | prev_month_revenue | (monthly_revenue - prev_month_revenue)/prev_month_revenue * 100 |
|---|---|---|
| 10000.00 | NULL | NULL |
| 10800.00 | 10000.00 | 8.000000 |
| 9800.00 | 10800.00 | -9.259259 |
| 11200.00 | 9800.00 | 14.285714 |
| 12500.00 | 11200.00 | 11.607143 |
| 12100.00 | 12500.00 | -3.200000 |
| 13000.00 | 12100.00 | 7.438017 |
| 14200.00 | 13000.00 | 9.230769 |
| 13800.00 | 14200.00 | -2.816901 |
| 15000.00 | 13800.00 | 8.695652 |
| 16200.00 | 15000.00 | 8.000000 |
| 18000.00 | 16200.00 | 11.111111 |

*Note that January has no previous month, so its growth is NULL.*

**What this reveals**

| | |
|---|---|
| Start to end | 10,000 to 18,000 = **+80%** |
| Average monthly growth | about **5.5%** a month |
| Down months | **March -9.26%, June -3.20%, September -2.82%** |
| Best month | April +14.29% |

- Revenue also rose **every quarter**; Q1 30,600 -> Q2 35,800 -> Q3 41,000 -> Q4 49,200, with short-term fluctuations (dips) inside a rising trend.

## 3 · The 3-month moving average

```sql
AVG(monthly_revenue) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
```

| month | monthly_revenue | rolling_3momth_avg |
|---|---|---|
| 1 | 10000.00 | 10000.000000 |
| 2 | 10800.00 | 10400.000000 |
| 3 | 9800.00 | 10200.000000 |
| 4 | 11200.00 | 10600.000000 |
| 5 | 12500.00 | 11166.666667 |
| 6 | 12100.00 | 11933.333333 |
| 7 | 13000.00 | 12533.333333 |
| 8 | 14200.00 | 13100.000000 |
| 9 | 13800.00 | 13666.666667 |
| 10 | 15000.00 | 14333.333333 |
| 11 | 16200.00 | 15000.000000 |
| 12 | 18000.00 | 16400.000000 |

- A moving average smooths short-term noise and shows direction. However **it also hides the dips**; it registers March only faintly (10,400 -> 10,200, a 2% dip against a 9% fall in revenue), and the June and September falls **disappear completely** because the average keeps rising through both. So use it to read the trend and use month-over-month growth to find problem months. January and February average over only 1 and 2 points, because there is no earlier data.

> [!WARNING]
> **A mistake I corrected.** An early exploratory query built a "rolling total" with `SUM(...) OVER (ORDER BY monthly_revenue)`. That orders by the **revenue amount**, not by **date**, so the accumulation ran from the smallest month to the largest (March first). A rolling total over time must be ordered by `month_start`.
