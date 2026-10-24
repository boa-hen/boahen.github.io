# 01 · SQL Fundamentals

**Lessons 1 to 7 · MySQL 8.0 · Parks and Recreation sample database**

> **In plain English:** this is where I learned to *ask a database questions*. A database is a set of tables (like spreadsheets). SQL is the language used to pick out rows, filter them, group them, sort them and combine tables. Everything on this page was run on a real MySQL 8.0 server and the results shown are the actual output.

| | |
|---|---|
| **Skills** | `SELECT` · `DISTINCT` · `WHERE` · `LIKE` · `AND/OR/NOT` · `GROUP BY` · `HAVING` · `ORDER BY` · `LIMIT` · aliases · `INNER/LEFT/RIGHT JOIN` · self join · `UNION` |
| **Data** | 3 tables, 11 to 12 rows each: `employee_demographics`, `employee_salary`, `parks_departments` |
| **Scripts** | [`sql/`](sql/) (one file per lesson, plus a joins practice script) |
| **Setup** | [`setup/01_create_parks_and_recreation.sql`](../setup/01_create_parks_and_recreation.sql) |

## The data

| Table | What it holds | Rows |
|---|---|---|
| `employee_demographics` | who each employee is: name, age, gender, birth date | 11 |
| `employee_salary` | what they do and earn: occupation, salary, department | 12 |
| `parks_departments` | the department names | 6 |

Both employee tables share `employee_id`. Ron Swanson (ID 2) is in the salary table but **not** the demographics table. That deliberate gap is what makes the join lessons interesting.

---

## Lesson 1 · SELECT: asking for data

**Goal:** pull data out of a table, including simple calculations.

```sql
SELECT first_name, last_name, birth_date, age, (age + 10) * 10
FROM parks_and_recreation.employee_demographics;
```


| first_name | last_name | birth_date | age | (age+10)*10 |
|---|---|---|---|---|
| Leslie | Knope | 1979-09-25 | 44 | 540 |
| Tom | Haverford | 1987-03-04 | 36 | 460 |
| April | Ludgate | 1994-03-27 | 29 | 390 |
| Jerry | Gergich | 1962-08-28 | 61 | 710 |

<sub>Showing the first 4 of 11 rows.</sub>

**What I learned**
- SQL follows normal maths order (brackets first), so `(age + 10) * 10` = 540 for Leslie.
- `SELECT DISTINCT` removes repeats. On *several* columns it returns unique **combinations**: `DISTINCT first_name, gender` gives 11 rows (every name is already unique), while `DISTINCT gender` alone gives just 2.

---

## Lesson 2 · WHERE and LIKE: filtering

**Goal:** keep only the rows that match a condition.

```sql
SELECT * FROM employee_demographics
WHERE (first_name = 'Leslie' AND age = 44) OR age > 55;
```


| employee_id | first_name | last_name | age | gender | birth_date |
|---|---|---|---|---|---|
| 1 | Leslie | Knope | 44 | Female | 1979-09-25 |
| 5 | Jerry | Gergich | 61 | Male | 1962-08-28 |

**Pattern matching with `LIKE`** (`%` = any number of characters, `_` = exactly one):

| Pattern | Meaning | Result (validated) |
|---|---|---|
| `'Jer%'` | starts with "Jer" | Jerry |
| `'%pr%'` | contains "pr" | April |
| `'a__'` | "a" + exactly 2 more characters | Ann |
| `'a___'` | "a" + exactly 3 more | Andy |
| `'a___%'` | "a" + at least 3 more | April, Andy |
| `birth_date LIKE '1985%'` | born in 1985 | Ben |

**What I learned**
- Brackets change which rows pass an `AND`/`OR` mix. Without them, `AND` is evaluated first.
- Dates are written `YYYY-MM-DD`, and `LIKE '1985%'` finds a whole year without knowing the month or day.

---

## Lesson 3 · GROUP BY and ORDER BY: summarising and sorting

**Goal:** turn many rows into one summary row per category.

```sql
SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM employee_demographics
GROUP BY gender;
```


| gender | AVG(age) | MAX(age) | MIN(age) | COUNT(age) |
|---|---|---|---|---|
| Female | 38.5000 | 46 | 29 | 4 |
| Male | 41.2857 | 61 | 34 | 7 |

**What I learned**
- Every column in `SELECT` must be either in the `GROUP BY` or wrapped in an aggregate (`AVG`, `MAX`...). I tested the failure on purpose:

```sql
SELECT first_name FROM employee_demographics GROUP BY gender;
```

> **MySQL error 1055:** `Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'parks_and_recreation.employee_demographics.first_name' which is not fu`

- `ORDER BY gender, age DESC` sorts by gender first, then by age within each gender. `ORDER BY 5, 4` (by column position) works but breaks silently if the column order changes, so I avoid it.

---

## Lesson 4 · HAVING vs WHERE

**Goal:** understand *when* each filter runs.

> [!TIP]
> **WHERE** filters individual rows **before** grouping. **HAVING** filters the **groups** after the maths is done. You cannot use `AVG()` in a `WHERE`.

```sql
SELECT gender, AVG(age) FROM employee_demographics WHERE AVG(age) > 40 GROUP BY gender;
```

> **MySQL error 1111:** `Invalid use of group function`

The fix is `HAVING`:

```sql
SELECT gender, AVG(age) FROM employee_demographics GROUP BY gender HAVING AVG(age) > 40;
```

| gender | avg(age) |
|---|---|
| Male | 41.2857 |

Combining all three clauses, "which job titles containing *manager* pay more than 75,000 on average?":


```sql
SELECT occupation, avg(salary)
FROM employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING avg(salary) > 75000;
```


| occupation | avg(salary) |
|---|---|
| City Manager | 90000.0000 |

**Another error I reproduced:** grouping by an alias of an aggregate (`GROUP BY avg_salary`) fails.

> **MySQL error 1056:** `Can't group on 'avg_salary'`

> [!NOTE]
> MySQL does allow aliases in `GROUP BY` for ordinary columns, but not for aggregates like `AVG()`, because the aggregate is calculated *after* grouping. This is a MySQL nuance that the plain "order of operations" explanation hides.

---

## Lesson 5 · LIMIT and aliasing

**Goal:** return only the top few rows and give columns friendly names.

```sql
SELECT * FROM employee_demographics ORDER BY age DESC LIMIT 3, 1;   -- skip 3 rows, return 1
```

| employee_id | first_name | last_name | age | gender | birth_date |
|---|---|---|---|---|---|
| 8 | Chris | Traeger | 43 | Male | 1980-11-11 |

- `LIMIT 3` returns the first 3 rows. `LIMIT 3, 1` **skips 3, then returns 1**. With ages sorted high to low, `LIMIT 2, 1` gives Leslie Knope (44) and `LIMIT 3, 1` gives Chris Traeger (43), exactly as expected.
- `AS` is optional: `AVG(age) AS avg_age` and `AVG(age) avg_age` both work.

---

## Lesson 6 · Joins: combining tables

**Goal:** stitch two or three tables together using a shared column.

```sql
SELECT dem.employee_id, age, occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal ON dem.employee_id = sal.employee_id;
```

| Join type | Keeps | Rows returned (validated) |
|---|---|---|
| `INNER JOIN` | only employees found in **both** tables | **11** |
| `LEFT JOIN` demographics → salary | every demographics row | **11** |
| `RIGHT JOIN` demographics → salary | every salary row (Ron appears with NULL demographics) | **12** |
| `LEFT JOIN` salary → demographics | every salary row | **12** |


| first_name | age | first_name | occupation |
|---|---|---|---|
| Leslie | 44 | Leslie | Deputy Director of Parks and Recreation |
| NULL | NULL | Ron | Director of Parks and Recreation |
| Tom | 36 | Tom | Entrepreneur |
| April | 29 | April | Assistant to the Director of Parks and Recreation |
| Jerry | 61 | Jerry | Office Manager |
| Donna | 46 | Donna | Office Manager |
| Ann | 35 | Ann | Nurse |
| Chris | 43 | Chris | City Manager |
| Ben | 38 | Ben | State Auditor |
| Andy | 34 | Andy | Shoe Shiner and Musician |
| Mark | 40 | Mark | City Planner |
| Craig | 37 | Craig | Parks Director |

**Errors I hit and explained**
- Joining on `employee_id = employee_id` with no table names: 
> **MySQL error 1052:** `Column 'employee_id' in on clause is ambiguous`
- Selecting `employee_id` without saying which table: 
> **MySQL error 1052:** `Column 'employee_id' in field list is ambiguous`

**Fix:** give each table an alias (`dem`, `sal`) and prefix shared columns (`dem.employee_id`).

**Self join: "Secret Santa".** Joining a table to itself pairs each employee with the *next* ID:

```sql
SELECT emp1.employee_id AS emp_santa, emp1.first_name AS first_name_santa,
       emp2.employee_id AS emp_id,    emp2.first_name AS first_name_recipient
FROM employee_salary AS emp1 JOIN employee_salary AS emp2 ON emp1.employee_id + 1 = emp2.employee_id;
```

**Three tables.** `employee_demographics` and `parks_departments` share no column, so the department name is reached *through* the salary table. Result: 10 rows (Ron has no demographics row and Andy has no department).

---

## Lesson 7 · UNION: stacking results

**Goal:** put the rows of two queries on top of each other (joins add *columns*, unions add *rows*).

| Keyword | Duplicates | Rows (validated) |
|---|---|---|
| `UNION` / `UNION DISTINCT` | removed | 12 |
| `UNION ALL` | kept | 23 |

A practical use: **labelling groups**, then combining them.


```sql
SELECT first_name, last_name, 'Old Man' as Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Lady' as Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Highly Paid Employee' as Label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name;
```


| first_name | last_name | Label |
|---|---|---|
| Chris | Traeger | Old Man |
| Chris | Traeger | Highly Paid Employee |
| Donna | Meagle | Old Lady |
| Jerry | Gergich | Old Man |
| Leslie | Knope | Old Lady |
| Leslie | Knope | Highly Paid Employee |

Chris Traeger appears twice (once per label). That is correct, because `UNION` removes only rows that are *identical in every column*.

> [!WARNING]
> Both queries must return the same number of columns of compatible meaning. My experiment `SELECT age, gender ... UNION SELECT first_name, last_name ...` ran without error but produced meaningless output (ages mixed with names in one column).

---

## Extra practice: joins, tested both ways

[`sql/practice - Joins Practice Script.sql`](sql/practice%20-%20Joins%20Practice%20Script.sql) repeats the lesson with the tables in **both orders** under `LEFT` and `RIGHT` joins. I confirmed the rule that the table *named first* (in `FROM`) is the "left" table:

| Query | Rows |
|---|---|
| demographics `INNER JOIN` salary | 11 |
| demographics `RIGHT JOIN` salary | 12 (keeps Ron) |
| salary `RIGHT JOIN` demographics | 11 |
| demographics `LEFT JOIN` salary | 11 |
| salary `LEFT JOIN` demographics | 12 (keeps Ron) |

> [!IMPORTANT]
> A `RIGHT JOIN` is just a `LEFT JOIN` with the tables swapped. Most analysts stick to `LEFT JOIN` for readability.

---

## Validation summary

| Lesson | Statements run | Deliberate errors reproduced |
|---|---|---|
| 1 SELECT | 6 | none |
| 2 WHERE / LIKE | 23 | none |
| 3 GROUP BY / ORDER BY | 14 | 1 (error 1055) |
| 4 HAVING vs WHERE | 7 | 3 (errors 1111, 1055, 1056) |
| 5 LIMIT / aliasing | 7 | none |
| 6 Joins | 16 | 2 (error 1052, ambiguous column) |
| 7 UNION | 7 | none |

Full method and results: [`docs/validation-report.md`](../docs/validation-report.md).

**Next:** [02 · Intermediate SQL →](../02-intermediate-sql/)
