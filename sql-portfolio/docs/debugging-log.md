# Debugging Log: Mistakes, Errors and What I Learned

I kept a record of every error and every "wrong but silent" result. Silent mistakes are the dangerous ones, because SQL happily returns a number that looks fine. Each entry is a real situation from this repository.

**Legend:** 🔴 query fails with an error · 🟡 query runs but gives a **wrong or misleading** answer

## Fundamentals and intermediate

| | Where | What happened | Why | Fix |
|---|---|---|---|---|
| 🔴 | [Lesson 3](../01-sql-fundamentals/README.md) | `SELECT first_name … GROUP BY gender` → **error 1055** | a selected column is neither grouped nor aggregated | group by it or aggregate it |
| 🔴 | [Lesson 4](../01-sql-fundamentals/README.md) | `WHERE AVG(age) > 40` → **error 1111** | `WHERE` runs before groups exist | use `HAVING` |
| 🔴 | [Lesson 4](../01-sql-fundamentals/README.md) | `GROUP BY avg_salary` → **error 1056** | MySQL cannot group on an alias of an aggregate | group by the real column |
| 🔴 | [Lesson 6](../01-sql-fundamentals/README.md) | `ON employee_id = employee_id` and `SELECT employee_id` → **error 1052** | both tables contain the column | table aliases (`dem.employee_id`) |
| 🟡 | [Lesson 7](../01-sql-fundamentals/README.md) | `UNION` of `age, gender` with `first_name, last_name` ran fine | columns line up by position, not by meaning | check that stacked columns mean the same thing |
| 🟡 | [Lesson 9](../02-intermediate-sql/README.md) | employees on exactly 50,000 got `NULL` new salary | neither `< 50000` nor `> 50000` matched | add `ELSE`, and decide the policy for the boundary |
| 🟡 | [Lesson 10](../02-intermediate-sql/README.md) | "average age" of 39.89 | it is an *average of two averages*; the true mean is 40.27 | aggregate from raw rows |
| 🔴 | [Lesson 10](../02-intermediate-sql/README.md) | `IN (SELECT a, b …)` → **error 1241** | an `IN` subquery must return one column | return a single column |
| 🟡 | [Lesson 11](../02-intermediate-sql/README.md) | `GROUP BY` on every column made each "average" equal the row's own value | each row became its own group | use a window function to keep rows |
| 🔴 | [Lesson 12](../02-intermediate-sql/README.md) | referencing a CTE in the next statement → **error 1146** | a CTE exists only for the statement right after it | repeat the CTE or use a temp table |

## Triggers, events and recovery

| | Where | What happened | Why | Fix |
|---|---|---|---|---|
| 🔴 | [Triggers](../03-procedures-triggers-events/README.md) | **error 1136** when inserting | trigger listed 3 columns but supplied 5 values | match counts, or list all columns and pass `NULL` |
| 🟡 | [Triggers](../03-procedures-triggers-events/README.md) | broken trigger was created without complaint | MySQL checks the insert only when the trigger fires | always test a trigger by firing it |
| 🟡 | [Events](../03-procedures-triggers-events/README.md) | recovered row deleted again within 30 s | lesson 15's `delete_retirees` event was never dropped | `DROP EVENT IF EXISTS delete_retirees;` |
| 🟡 | [Practice scripts](../02-intermediate-sql/README.md) | results differed from the lessons | earlier exercises left extra rows and removed others | rebuild the database first |

## Data cleaning ([project 04](../04-layoffs-data-cleaning/README.md))

| | What happened | Why | Fix |
|---|---|---|---|
| 🟡 | "Oda" flagged as duplicate | partitioned on too few columns; the rows differ in country and percentage | partition on **all** columns, then verify by looking at the rows |
| 🔴 | `DELETE` from a CTE → **error 1288** | a CTE is a temporary result, not a table | write to a staging table with a `row_num` column |
| 🟡 | self-join update affected **0 rows** | blank strings (`''`) are not `NULL` | convert blanks to `NULL` first |
| 🟡 | `TRIM(country)` did not remove "United States." | `TRIM` strips spaces only | `TRIM(TRAILING '.' FROM country)` |
| 🟡 | text dates behaved oddly | `STR_TO_DATE` fixed values, not the column type | follow with `ALTER TABLE … MODIFY COLUMN … DATE` |

## Exploratory analysis ([project 05](../05-layoffs-eda/README.md))

| | What happened | Why | Fix |
|---|---|---|---|
| 🟡 | total funds raised = 1,601,450 (almost double the real 804,181) | company-level value repeated on every layoff row, then summed | `MAX` per company, then sum |
| 🟡 | "company with most funds" returned Netflix ×3 | one row per layoff event | `SELECT DISTINCT` |
| 🟡 | a "top 5" silently dropped Philips | tie at 10,000 with Microsoft | `RANK()` and inspect ties |
| 🟡 | yearly totals did not add up to the grand total | one undated record (500) forms a NULL-year group | account for the NULL group |
| 🟡 | summing `percentage_laid_off` per company | adding percentages of different events is meaningless | removed; use `AVG` or `MAX` |
| 🟡 | distinct counts differed from pandas (1,628 vs 1,633) | case- and accent-insensitive collation | know your tool's comparison rules |

## EDA practice database ([project 06](../06-eda-practice-database/README.md))

| | Where | What happened | Why | Fix |
|---|---|---|---|---|
| 🟡 | job_listings | duplicate check returned `row_num = 1` for every row | `job_id` (unique) was in the `PARTITION BY` | never partition on a primary key; test with `MAX(row_num)` |
| 🟡 | employees | `ROW_NUMBER()` used to count hires per year | it numbers rows, it doesn't count them | `COUNT(*) OVER (PARTITION BY …)` or `GROUP BY` |
| 🟡 | employees | adding `name` to a `GROUP BY year` query gave counts of 1 | every row became its own group | window `COUNT` keeps extra columns |
| 🟡 | employees | adding `YEAR(hire_date)` to the tenure query split the buckets | extra column in `GROUP BY` changes the groups | group by the bucket only |
| 🔴 | employees | `UPDATE … (SELECT … FROM same table)` → **error 1093** | MySQL won't read and write one table in the same statement | compute in a derived table and `JOIN` it |
| 🔴 | employees | `OVER(department_id …)` → **error 3579** | the `PARTITION BY` keyword was missing, so MySQL looked for a named window | `OVER (PARTITION BY department_id …)` |
| 🟡 | employees | correlated subquery returned NULL | inner `AVG` referenced the outer table alias | leave inner columns unqualified |
| 🟡 | tweets | bucket `> 1 AND <= 5` left a gap | strict comparison excludes exactly 1 | `BETWEEN` |
| 🟡 | revenue | "rolling total" accumulated from smallest to largest month | `ORDER BY monthly_revenue` instead of the date | `ORDER BY month_start` |
| 🟡 | events | CTR query returned NULL | `'click' / 'impression'` is text division | conditional aggregation `SUM(event_type = 'click')` |
| 🔴 | events | same query → **error 1055** on default settings | `ONLY_FULL_GROUP_BY` | include non-aggregated columns in `GROUP BY` |
| 🟡 | events | daily CTRs averaged to 66.7% vs a true 60% | averaging rates ignores volume | sum counts, then divide |

## The habits these taught me

1. **Ask what one row represents** before you sum, count or join.
2. **A query that runs is not a query that is right.** Sanity-check every result against something you know.
3. **Test your checks.** Inject a fault and make sure the check catches it.
4. **Check ties, NULLs, blanks and edge values** (exactly 50,000, a missing date, a duplicate that is not one).
5. **Know your environment.** SQL mode, collation and leftover state change results.
