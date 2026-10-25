# Glossary: SQL Terms in Plain English

Written for readers who have never used SQL.

| Term | Plain-English meaning | Example in this repo |
|---|---|---|
| **Database** | an organised collection of tables | `parks_and_recreation` |
| **Table** | a grid of rows and columns, like a spreadsheet tab | `employee_salary` |
| **Row / record** | one entry in a table | one employee |
| **Column / field** | one attribute shared by all rows | `salary` |
| **Query** | a question you ask the database | `SELECT … FROM …` |
| **Primary key** | a column whose value is unique for each row | `employee_id` |
| **NULL** | "no value / unknown" (not the same as 0 or blank text) | Bally's Interactive has a NULL industry |
| **Alias** | a temporary nickname for a column or table | `AVG(age) AS avg_age` |
| **Aggregate function** | collapses many values into one (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`) | total layoffs per company |
| **GROUP BY** | make one summary row per category | layoffs per country |
| **WHERE vs HAVING** | filter rows *before* grouping vs filter groups *after* | [Lesson 4](../01-sql-fundamentals/README.md) |
| **Join** | combine columns from two tables using a shared key | salary + demographics |
| **Inner / left / right join** | keep only matches / keep all left rows / keep all right rows | [Lesson 6](../01-sql-fundamentals/README.md) |
| **Self join** | join a table to itself | employee → manager |
| **Anti-join** | find rows with *no* match in another table | users who never ordered |
| **UNION** | stack the results of two queries (rows, not columns) | labelled employee groups |
| **Subquery** | a query inside another query | company average next to each salary |
| **CTE** | a named, temporary result used by the next query (`WITH … AS`) | top-5 per year |
| **Window function** | calculates across related rows *without* collapsing them (`OVER`) | rank within a department |
| **PARTITION BY** | splits the "window" into groups | rank *within each year* |
| **ROW_NUMBER / RANK / DENSE_RANK** | numbering rows; they differ only for ties | [Lesson 11](../02-intermediate-sql/README.md) |
| **LAG** | looks at the previous row's value | last month's revenue |
| **Rolling total / moving average** | running sum / average over recent rows | cumulative layoffs |
| **CASE** | if/then logic inside a query | age brackets |
| **Temporary table** | a table that disappears when your session ends | `salary_over_50k` |
| **Stored procedure** | a saved query you run with `CALL` | `emp_id_data(4)` |
| **Trigger** | runs automatically when data changes | new salary row → new demographics row |
| **Event** | runs automatically on a schedule | delete retirees every 30 s |
| **Binary log** | the server's record of every data change, used for recovery | recovering Jerry |
| **Staging table** | a working copy so the raw data stays untouched | `layoffs_staging2` |
| **Data cleaning** | fixing duplicates, typos, inconsistent labels, wrong types | [project 04](../04-layoffs-data-cleaning/README.md) |
| **Imputation** | filling a missing value with an estimate | department-average salary |
| **EDA** | exploratory data analysis: investigating data to find patterns and problems | [projects 05 and 06](../05-layoffs-eda/README.md) |
| **CTR** | click-through rate = clicks ÷ impressions | [events](../06-eda-practice-database/reports/events.md) |
| **Outlier** | a value far from the rest | Netflix's funding figure |
| **p-value** | how likely a pattern is to appear by pure chance; below 0.05 is usually called "significant" | weekday tweets, p = 0.058 |
| **Collation** | the rules for comparing text (case, accents) | why 1,628 ≠ 1,633 |
| **SQL mode** | server setting controlling how strict MySQL is | `ONLY_FULL_GROUP_BY` |
