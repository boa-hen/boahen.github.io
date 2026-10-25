# Validation Report

**Every script in this repository was re-run from scratch on a clean MySQL server, statement by statement, and every result was recorded and checked.** This page explains how, what matched, and what the process uncovered.

> [!NOTE]
> **Transparency:** This validation was carried out in an isolated sandbox with the help of an AI assistant (Claude, by Anthropic), which ran the scripts, compared results with my notes, and wrote independent cross-check queries. The learning, the original scripts and the analysis choices are mine; the sandbox runs are what let me prove the numbers. I then re-run everything and corrected all the mistakes I was unable to discover on my own. I also modified some queries that run well but could be improved based on some inspirations given by the AI assistant.

## TL;DR

| | |
|---|---|
| Scripts executed | **31 scripts, 456 statements** (plus 3 test files, 23 statements) |
| Unexpected failures | **0** |
| Errors raised | **10**: **9 deliberate teaching errors** reproduced exactly as my comments describe, plus **1 environment-specific** one (a binary-log file name that exists only on my PC) |
| Headline numbers independently re-computed | all match (Python / pandas / SciPy) |
| Real issues found | **9** (listed below), each explained and, where possible, fixed |

## 1 · Method

### Environment

| Setting | Value | Why |
|---|---|---|
| Server | **MySQL 8.0.46** | same version as my local Workbench |
| SQL mode | default (`ONLY_FULL_GROUP_BY`, `STRICT_TRANS_TABLES` …) | same strictness as a normal install |
| `lower_case_table_names` | `1` | my scripts mix `Parks_and_Recreation` and `parks_and_recreation`, which works on Windows; this setting reproduces that on Linux |
| Collation | `utf8mb4_0900_ai_ci` (default) | case- and accent-insensitive, matters for `DISTINCT` counts |
| Event scheduler | `ON` | needed for lesson 15 |
| Binary logging | `ON` (row format) | needed for the recovery demonstration |

### Procedure

1. **Build the databases** with the set-up scripts: Parks and Recreation, the nine-table `eda_practice`, and `world_layoffs` (import of `layoffs.csv`, 2,361 rows).
2. **Run each script statement by statement** with a small runner that understands `DELIMITER` blocks, strings and comments, and records for every statement: rows returned, rows affected, warnings, or the exact error code and message.
3. **Run in the same order I learned them:** lessons 1 to 15 on one database, layoffs lesson 16 then 17, then the practice scripts.
4. **Compare** every claim in my script comments (for example "this returns 6 rows" or "this gives an error") with what actually happened.
5. **Cross-check** headline results using independent methods (different SQL, or Python/pandas/SciPy).
6. **Rebuild the database before practice scripts** (see issue 2) so results do not depend on leftovers from earlier lessons.

## 2 · Results by script

| Script | Statements | Errors | Notes |
|---|---|---|---|
| Parks set-up | 9 | 0 | 3 tables created and populated |
| 1 SELECT | 6 | 0 | |
| 2 WHERE / LIKE | 23 | 0 | every `LIKE` pattern matches my comments |
| 3 GROUP BY / ORDER BY | 14 | 1 | error 1055 (by design) |
| 4 HAVING vs WHERE | 7 | 3 | errors 1111, 1055, 1056 (by design) |
| 5 LIMIT / aliasing | 7 | 0 | |
| 6 Joins | 16 | 2 | error 1052 ×2, ambiguous column (by design) |
| 7 UNION | 7 | 0 | 12 rows distinct, 23 with `UNION ALL` |
| 8 String functions | 9 | 0 | |
| 9 CASE | 4 | 0 | |
| 10 Subqueries | 6 | 0 | |
| 11 Window functions | 9 | 0 | |
| 12 CTEs | 5 | 1 | error 1146, CTE out of scope (by design) |
| 13 Temp tables | 7 | 0 | |
| 14 Stored procedures | 15 | 0 | |
| 15 Triggers and events | 7 | 0 | trigger fired; event deleted Jerry in ≤30 s |
| 16 Data cleaning | 47 | 1 | error 1288, `DELETE` from a CTE (by design) |
| 17 EDA | 15 | 0 | |
| Practice: data cleaning re-do | 38 | 0 | result identical to lesson 16 |
| Practice: layoffs EDA | 26 | 0 | see issue 3 |
| Practice: general | 12 | 0 | |
| Practice: joins | 13 | 0 | |
| Practice: trigger/event rough sheet | 23 | 1 | error 1220: `SHOW BINLOG EVENTS` names a log file that exists only on my PC |
| EDA practice set-up | 29 | 0 | 9 tables |
| EDA: employees | 49 | 0 | |
| EDA: tweets | 12 | 0 | |
| EDA: monthly revenue | 9 | 0 | |
| EDA: users and orders | 10 | 0 | |
| EDA: events | 9 | 0 | |
| Errors and corrections: employees | 8 | 0 | |
| Errors and corrections: events | 5 | 1 | error 1055 (by design) |
| `tests/` (3 files) | 23 | 0 | every check returns its documented value |

## 3 · Independent re-computation of headline numbers

| Result | MySQL (this repo) | Independent method | Match |
|---|---|---|---|
| Raw rows / after dedupe / final | 2,361 / 2,356 / 1,995 | pandas `drop_duplicates` + filters | ✔ |
| Total laid off (cleaned data) | 383,659 | pandas | ✔ |
| Top company (Amazon) | 18,150 | pandas | ✔ |
| Top industry (Consumer) | 45,182 | pandas | ✔ |
| Top country (United States) | 256,559 | pandas | ✔ |
| Year totals 2020 / 2021 / 2022 / 2023 | 80,998 / 15,823 / 160,661 / 125,677 | pandas | ✔ |
| Month peak (Jan 2023) | 84,714 | pandas | ✔ |
| Independent re-do equals guided project | 0 differing rows (`EXCEPT` both ways) | SQL set difference | ✔ |
| Weekday effect in tweets | χ² = 12.21, p = 0.058 | SciPy `chisquare` | ✔ |
| Average monthly revenue growth | 5.49% | closed-form `(18000/10000)^(1/11) − 1` | ✔ |
| Distinct companies | **1,628** | pandas gives 1,633 | ⚠ see issue 9 |

## 4 · Issues found

Each is something I would not have known without running the code on a clean server. None changes the main conclusions, but several change how the numbers should be read.

| # | Issue | Where | Impact | What I did |
|---|---|---|---|---|
| 1 | **Event never dropped.** Lesson 15's `delete_retirees` keeps running every 30 s. A recovered row (Jerry) is deleted again within 30 s | [03](../03-procedures-triggers-events/README.md) | data loss if the lesson is followed literally | documented; add `DROP EVENT IF EXISTS delete_retirees;` |
| 2 | **Practice scripts depend on leftover state.** After lesson 15 the demographics table has an extra person with NULL gender and no Jerry. A `GROUP BY gender` then shows an extra NULL group, and averages and totals shift | [02](../02-intermediate-sql/README.md) | different numbers each time | re-run the set-up script before any practice script ([how-to-run](how-to-run.md)) |
| 3 | **`SUM(funds_raised_millions)` double-counts**: 1,601,450 vs 804,181 correct | [05](../05-layoffs-eda/README.md) | totals almost double | explained; corrected query in `tests/02` |
| 4 | **Netflix funds = 121,900 ($121.9 B)** is 4.7× the next value | [05](../05-layoffs-eda/README.md) | likely a source-data scale error | flagged for verification |
| 5 | **Ranking tie hidden by `LIMIT 5`**: Microsoft and Philips both 10,000 | [05](../05-layoffs-eda/README.md) | one company silently omitted | use `RANK()` |
| 6 | **One undated record** (Blackbaud, 500 people) forms a "NULL year" group | [05](../05-layoffs-eda/README.md) | yearly totals sum to 383,159 + 500 | documented |
| 7 | **"Outputs NULL" depends on SQL mode.** The faulty CTR query returns NULL only with `ONLY_FULL_GROUP_BY` off; on defaults it errors (1055) | [events](../06-eda-practice-database/reports/events.md) | confusing when results differ between machines | documented |
| 8 | **`percentage_laid_off` is stored as text** | [04](../04-layoffs-data-cleaning/README.md) | `MAX()` compares characters; works here, fragile in general | cast to `DECIMAL` for maths |
| 9 | **Collation changes distinct counts.** MySQL's default collation ignores case and accents, so `COUNT(DISTINCT company)` = 1,628, whereas a case-sensitive tool gives 1,633 | [05](../05-layoffs-eda/README.md) | cross-tool comparisons disagree | documented |

### Smaller observations

- **Lesson 4:** MySQL allows aliases in `GROUP BY` for ordinary expressions but not for aggregates, so "the alias doesn't exist yet" is only part of the story.
- **Lessons 10 and 12:** the final numbers are *averages of group averages* (39.89 for age vs the true 40.27; 55,589 for salary vs the true 56,091), which weights groups equally regardless of size.
- **Lesson 9:** employees on exactly 50,000 fall between `<` and `>`. The corrected script returns 50,000 (no raise), which is a policy decision, not just a syntax fix.
- **Triggers:** a trigger with mismatched column counts *creates* successfully and only fails when it fires, which also cancels the original insert.
- **Industry labels:** `Fin-Tech` (3 rows) and `Finance` (239) remain separate.
- **Mean imputation** (employees table) preserves the average but understates the spread.

## 5 · Reproduce it yourself

Follow [`how-to-run.md`](how-to-run.md), then run the three files in [`tests/`](../tests/). Each check states in a comment what a healthy result looks like.
