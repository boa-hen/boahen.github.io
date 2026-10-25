# 02 · Intermediate SQL

**Lessons 8 to 13 · MySQL 8.0 · Parks and Recreation sample database**

> **Overview:** The fundamentals answer one question at a time. This stage is about answering *harder* questions: cleaning up text, adding "if/then" logic, running a query inside a query, ranking people within groups, and breaking long queries into readable steps.

| | |
|---|---|
| **Techniques** | string functions · `CASE` · subqueries · window functions (`OVER`, `PARTITION BY`, `ROW_NUMBER`, `RANK`, `DENSE_RANK`, running totals) · CTEs · temporary tables |
| **Scripts** | [`sql/`](sql/) (one file per lesson, plus a general practice script) |
| **Data** | same Parks and Recreation tables as [01](../01-sql-fundamentals/) (11 to 12 rows each) |



## Lesson 8 · String functions: cleaning text

**Goal:** inspect and reshape text values. This is the toolkit used later for [data cleaning](../04-layoffs-data-cleaning/).

| Function | What it does | Example (validated) |
|---|---|---|
| `LENGTH('skyfall')` | counts characters | 7 |
| `UPPER('sky')` / `LOWER('SKY')` | changes case | `SKY` / `sky` |
| `TRIM(' sky ')` | removes spaces **both** sides | `sky` |
| `LTRIM` / `RTRIM` | removes spaces left / right only | |
| `LEFT(name, 4)` / `RIGHT(name, 4)` | first / last *n* characters | Leslie → `Lesl` / `slie` |
| `SUBSTRING(name, 3, 2)` | 2 characters starting at position 3 | Leslie → `sl` |

```sql
SELECT first_name, LEFT(first_name, 4), RIGHT(first_name, 4), SUBSTRING(first_name, 3, 2)
FROM employee_demographics;
```

| first_name | LEFT(first_name, 4) | RIGHT(first_name, 4) | substring(first_name, 3, 2) |
|---|---|---|---|
| Leslie | Lesl | slie | sl |
| Tom | Tom | Tom | m |
| April | Apri | pril | ri |
| Jerry | Jerr | erry | rr |

<sub>Showing the first 4 of 11 rows.</sub>

Sorting by `LENGTH(first_name)` put the 3-letter names (Tom, Ann, Ben) first.



## Lesson 9 · CASE: if/then inside a query

**Goal:** create a new column based on rules/conditions.

**Rule set 1: age brackets**

```sql
SELECT first_name,
last_name,
age,
CASE
    WHEN age <= 30 THEN 'Young'
    WHEN age BETWEEN 31 and 50 THEN 'Old'
    WHEN age >= 50 THEN "Senior"
END as Age_Bracket
FROM employee_demographics;
```

| first_name | last_name | age | Age_Bracket |
|---|---|---|---|
| Leslie | Knope | 44 | Old |
| Tom | Haverford | 36 | Old |
| April | Ludgate | 29 | Young |
| Jerry | Gergich | 61 | Senior |
| Donna | Meagle | 46 | Old |
| Ann | Perkins | 35 | Old |
| Chris | Traeger | 43 | Old |
| Ben | Wyatt | 38 | Old |
| Andy | Dwyer | 34 | Old |
| Mark | Brendanawicz | 40 | Old |
| Craig | Middlebrooks | 37 | Old |

**Rule set 2: a pay-rise policy.** Salaries under 50,000 get +5%, over 50,000 get +7%, and Finance (department 6) gets an extra 10% bonus.


```sql
SELECT first_name, last_name, salary,
CASE
    WHEN salary < 50000 THEN salary + (salary * 0.05)
    WHEN salary > 50000 THEN salary + (salary * 0.07)
    ELSE salary
END as New_Salary,
CASE
    WHEN dept_id = 6 THEN salary * 0.10
    ELSE salary * 0
END as Bonus
FROM employee_salary;
```


| first_name | last_name | salary | New_Salary | Bonus |
|---|---|---|---|---|
| Leslie | Knope | 75000 | 80250.00 | 0 |
| Ron | Swanson | 70000 | 74900.00 | 0 |
| Tom | Haverford | 50000 | 50000 | 0 |
| April | Ludgate | 25000 | 26250.00 | 0 |
| Jerry | Gergich | 50000 | 50000 | 0 |
| Donna | Meagle | 60000 | 64200.00 | 0 |
| Ann | Perkins | 55000 | 58850.00 | 0 |
| Chris | Traeger | 90000 | 96300.00 | 0 |
| Ben | Wyatt | 70000 | 74900.00 | 7000.00 |
| Andy | Dwyer | 20000 | 21000.00 | 0 |
| Mark | Brendanawicz | 57000 | 60990.00 | 0 |
| Craig | Middlebrooks | 65000 | 69550.00 | 0 |

> [!NOTE]
> **Here are some key discoveries.** Tom and Jerry earn *exactly* 50,000, which is neither `< 50000` nor `> 50000`. Without an `ELSE`, a `CASE` returns `NULL` for them. My final version adds `ELSE salary`, so they correctly show 50,000, but that quietly means **no raise** for them. In a real project I would confirm with the business whether exactly 50,000 should get 5% or 7%.

`CASE` checks conditions top to bottom and **stops at the first match**, so order matters (a person aged exactly 50 would be labelled "Old", not "Senior").



## Lesson 10 · Subqueries: a query inside a query

**Goal:** use the result of one query as an input to another.

| Where it sits | Example | Result (validated) |
|---|---|---|
| in `WHERE` with `IN` | employees in department 1 | 6 people |
| in `SELECT` | show every salary next to the company average | average 57,250 on each row |
| in `FROM` | average of the per-gender figures | see below |

```sql
SELECT first_name, salary, (SELECT AVG(salary) FROM employee_salary) AS Avg_Salary
FROM employee_salary;
```

| first_name | salary | Avg_Salary |
|---|---|---|
| Leslie | 75000 | 57250.0000 |
| Ron | 70000 | 57250.0000 |
| Tom | 50000 | 57250.0000 |
| April | 25000 | 57250.0000 |

<sub>Showing the first 4 of 12 rows.</sub>

**A subtle trap I verified.** The `FROM`-subquery example returns `AVG(avg_age) = 39.89`. But that is an *average of two group averages*. The real average age of all 11 employees is **40.27**, because the groups are different sizes (4 women, 7 men). Averaging averages weights both groups equally.


| AVG(avg_age) | AVG(max_age) | AVG(min_age) | AVG(count_age) |
|---|---|---|---|
| 39.89285000 | 53.5000 | 31.5000 | 5.5000 |

**Error I documented:** a subquery used with `IN` must return **one** column. Returning two raises `ERROR 1241: Operand should contain 1 column(s)` (I re-ran it to confirm).



## Lesson 11 · Window functions: calculations without collapsing rows

**Goal:** compare each row against its group while keeping every row visible.

> [!TIP]
> `GROUP BY` collapses many rows into one per group. A **window function** keeps all rows and adds the group figure alongside.

```sql
SELECT dem.first_name, dem.last_name, gender,
       AVG(salary) OVER(PARTITION BY gender) AS avg_salary
FROM employee_demographics AS dem
JOIN employee_salary AS sal ON dem.employee_id = sal.employee_id;
```

| first_name | last_name | gender | avg_salary |
|---|---|---|---|
| Leslie | Knope | Female | 53750.0000 |
| April | Ludgate | Female | 53750.0000 |
| Donna | Meagle | Female | 53750.0000 |
| Ann | Perkins | Female | 53750.0000 |
| Tom | Haverford | Male | 57428.5714 |

<sub>Showing the first 5 of 11 rows.</sub>

| Query | Rows | Meaning |
|---|---|---|
| `GROUP BY gender` | 2 (Female 53,750 · Male 57,428.57) | one summary per group |
| `AVG(salary) OVER(PARTITION BY gender)` | 11 | the same averages, repeated on every person |
| `GROUP BY` on **every** column | 11 | each person is their own group, so the "average" equals their own salary (a mistake I made on purpose to see it) |

**Running totals.** Adding `ORDER BY` inside `OVER` makes `SUM` accumulate row by row. With `PARTITION BY gender` the total restarts for each gender:


| first_name | last_name | gender | salary | Rolling_Total_With_Partition |
|---|---|---|---|---|
| Leslie | Knope | Female | 75000 | 75000 |
| April | Ludgate | Female | 25000 | 100000 |
| Donna | Meagle | Female | 60000 | 160000 |
| Ann | Perkins | Female | 55000 | 215000 |

<sub>Showing the first 4 of 11 rows.</sub>

**Ranking functions.** The three ranks differ only when there are **ties**. Tom and Jerry both earn 50,000:

| Employee (male) | Salary | `ROW_NUMBER` | `RANK` | `DENSE_RANK` |
|---|---|---|---|---|
| Chris | 90,000 | 1 | 1 | 1 |
| Ben | 70,000 | 2 | 2 | 2 |
| Craig | 65,000 | 3 | 3 | 3 |
| Mark | 57,000 | 4 | 4 | 4 |
| Tom | 50,000 | 5 | 5 | 5 |
| Jerry | 50,000 | 6 | **5** (tie) | **5** (tie) |
| Andy | 20,000 | 7 | **7** (skips 6) | **6** (no gap) |

- `ROW_NUMBER` never repeats, so ties are broken arbitrarily.
- `RANK` repeats for ties, then **skips** numbers.
- `DENSE_RANK` repeats for ties and does **not** skip.

I use these again in the layoffs and employee analyses: [05](../05-layoffs-eda/) and [06](../06-eda-practice-database/).



## Lesson 12 · CTEs: readable, step-by-step queries

**Goal:** give a sub-result a name so the main query reads like a story.

```sql
WITH CTE1 AS (SELECT employee_id, gender, birth_date FROM employee_demographics WHERE birth_date > '1985-01-01'),
     CTE2 AS (SELECT employee_id, salary FROM employee_salary WHERE salary > 50000)
SELECT * FROM CTE1 JOIN CTE2 ON CTE1.employee_id = CTE2.employee_id;
```

| employee_id | gender | birth_date | employee_id | salary |
|---|---|---|---|---|
| 7 | Female | 1988-12-01 | 7 | 55000 |
| 9 | Male | 1985-07-26 | 9 | 70000 |
| 12 | Male | 1986-07-27 | 12 | 65000 |

*"Employees born after 1985 who earn over 50,000"* → Ann, Ben and Craig.

- A CTE lives only for the **single statement that follows it**. Calling it afterwards fails (I verified this after testing to see if calling the cte in an entirely query works):

> **MySQL error 1146:** `Table 'parks_and_recreation.cte_example' doesn't exist`
- Column names can be set in the header, `WITH CTE_Example (GENDER, AVERAGE, MAXIMUM, MINIMUM, COUNT) AS (...)`, instead of editing the inner query.
- A CTE and a subquery give the same answer here. The CTE is simply easier to read and maintain.



## Lesson 13 · Temporary tables

**Goal:** store an intermediate result for reuse during a session.

```sql
CREATE TEMPORARY TABLE salary_over_50k
SELECT * FROM employee_salary WHERE salary >= 50000;   -- 10 rows

SELECT * FROM salary_over_50k;
```

| Function | When to use |
|---|---|
| **subquery** | the logic is short and used once |
| **CTE** | you want readability, or to reuse a result *inside one query* |
| **temp table** | you run many steps, or query the same result repeatedly in one session |

A temp table disappears when your session closes, which is why it never clutters the database.



## Extra practice: general practice script

[`sql/practice - General Practice Script.sql`](sql/practice%20-%20General%20Practice%20Script.sql) mixes grouping, joins and windows on my own questions.

**"What does each department spend on salaries?"** I built a running salary total per department, then took its maximum, which equals the department total:


| dept_id | MAX(dept_salary_sum) OVER(PARTITION BY dept_id) |
|---|---|
| NULL | 20000 |
| 1 | 395000 |
| 3 | 147000 |
| 4 | 55000 |
| 6 | 70000 |

| Department | Total salary |
|---|---|
| 1 · Parks and Recreation | 395,000 |
| 3 · Public Works | 147,000 |
| 6 · Finance | 70,000 |
| 4 · Healthcare | 55,000 |
| (none) · Andy Dwyer has no department | 20,000 |

I cross-checked these with a plain `GROUP BY dept_id, SUM(salary)`: identical. (A simple `GROUP BY` is shorter, but building it with windows was good window practice.)

Other practice queries: joined employees filtered by `age/2 >= 20` (5 people aged 40+), averages and counts per occupation, and sorted joins.



## Validation summary

| Lesson | Statements run | Deliberate errors reproduced |
|---|---|---|
| 8 String functions | 9 | none |
| 9 CASE | 4 | none |
| 10 Subqueries | 6 | none in the saved script (the 1241 error is described in a comment and was re-tested separately) |
| 11 Window functions | 9 | none |
| 12 CTEs | 5 | 1 (error 1146, CTE out of scope) |
| 13 Temp tables | 7 | none |

Full method and results: [`docs/validation-report.md`](../docs/validation-report.md).

**← Previous:** [01 · Fundamentals](../01-sql-fundamentals/) · **Next:** [03 · Procedures, triggers and events →](../03-procedures-triggers-events/)
