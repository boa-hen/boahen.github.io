# How to Run This Repository

Everything runs on **MySQL 8.0 or later** (window functions and CTEs need 8.0+). I used MySQL Workbench on Windows, but any MySQL 8 client works.

## 1 · Prerequisites

| Need | Notes |
|---|---|
| MySQL Server 8.0+ | [dev.mysql.com/downloads](https://dev.mysql.com/downloads/mysql/) |
| A client | MySQL Workbench, the `mysql` command line, DBeaver… |
| Privilege to create databases | `root` is fine locally |
| *(Linux/macOS only)* `lower_case_table_names=1` | my scripts mix `Parks_and_Recreation` and `parks_and_recreation`, which is fine on Windows but case-sensitive on Linux. Set this option when you **initialise** the server, or change the names to lowercase |

## 2 · Build the three databases

Run these from the repository root, in order:

```bash
mysql -u root -p < setup/01_create_parks_and_recreation.sql    # Parks and Recreation (lessons 1 to 15)
mysql -u root -p < setup/02_create_eda_practice.sql            # nine-table practice database
mysql --local-infile=1 -u root -p < setup/03_import_layoffs.sql  # world_layoffs (needs data/layoffs.csv)
```

In MySQL Workbench you can instead open each file and press the lightning-bolt button. For the layoffs data you can also use the **Table Data Import Wizard** (right-click `layoffs` → *Table Data Import Wizard*) instead of `LOAD DATA`.

If `LOAD DATA LOCAL INFILE` is rejected, enable it once with `SET GLOBAL local_infile = 1;` and start the client with `--local-infile=1`.

Sanity check, which should show **2,361 rows**:

```sql
SELECT COUNT(*) FROM world_layoffs.layoffs;
```

## 3 · Run the lessons in order

| Order | Folder | Database |
|---|---|---|
| 1 | `01-sql-fundamentals/sql/` | `parks_and_recreation` |
| 2 | `02-intermediate-sql/sql/` | `parks_and_recreation` |
| 3 | `03-procedures-triggers-events/sql/` | `parks_and_recreation` |
| 4 | `04-layoffs-data-cleaning/sql/` | `world_layoffs` |
| 5 | `05-layoffs-eda/sql/` | `world_layoffs` (needs project 4 first) |
| 6 | `06-eda-practice-database/sql/` | `eda_practice` |

Open one script at a time and run it statement by statement (Workbench: *Ctrl+Enter* runs the current statement). Several scripts contain **deliberate errors** to demonstrate a lesson. If you run a whole file from the command line, add `--force` so it continues past them:

```bash
mysql -u root -p --force parks_and_recreation < "01-sql-fundamentals/sql/4. HAVING vs WHERE clause.sql"
```

### Errors you should expect

| Script | Expected error | Meaning |
|---|---|---|
| 3. GROUP BY | 1055 | column not grouped or aggregated |
| 4. HAVING vs WHERE | 1111, 1055, 1056 | aggregate in `WHERE`; ungrouped column; grouping on an aggregate alias |
| 6. Joins | 1052 (twice) | ambiguous column |
| 12. CTEs | 1146 | CTE used outside its statement |
| 16. Data cleaning | 1288 | cannot `DELETE` from a CTE |
| Errors and Corrections (events) | 1055 | `ONLY_FULL_GROUP_BY` |
| trigger/event rough sheet | 1220 | `SHOW BINLOG EVENTS` names a log file that exists only on my PC. Run `SHOW BINARY LOGS;` and use one of *your* file names |

## 4 · Important: reset between exercises

> [!WARNING]
> Lesson 15 creates a **trigger** and an **event** that change the Parks data, and the event keeps running every 30 seconds. Before you do any practice script, or whenever results look different from this repo:
> ```sql
> DROP EVENT IF EXISTS delete_retirees;
> ```
> then re-run `setup/01_create_parks_and_recreation.sql`, which drops and rebuilds the whole database (including triggers, events and procedures).

## 5 · Check your results

Run the files in [`tests/`](../tests/). Each query has a comment saying what a healthy result looks like.

## 6 · Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Unknown database 'parks_and_recreation'` on Linux | case-sensitive names | see prerequisites |
| `Error 1175` (safe update mode) in Workbench | Workbench blocks `UPDATE/DELETE` without a key | *Edit → Preferences → SQL Editor →* untick **Safe Updates**, then reconnect |
| A query shows NULL where this repo shows an error (or vice versa) | different `sql_mode` | `SELECT @@sql_mode;` |
| `COUNT(DISTINCT company)` differs from another tool | collation (case/accent-insensitive) | expected, see [validation report](validation-report.md) |
| Event never fires | scheduler off | `SET GLOBAL event_scheduler = ON;` |
