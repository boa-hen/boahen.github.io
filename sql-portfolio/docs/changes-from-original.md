# Changes From My Original Files

The SQL in this repository is my own study work. To make it safe and tidy to publish, the following **non-logic** changes were made. No query was rewritten.

| Change | Files | Why |
|---|---|---|
| Line endings converted from Windows (CRLF) to Unix (LF) | all `.sql` | cleaner diffs on GitHub |
| Four first/last names in my trigger test replaced with fictional names (Alex Rivera, Sam Carter, Jordan Lee, Taylor Brooks) | `practice - trigger and event rough sheet.sql` | the originals were real-looking personal names |
| My computer's name removed from a binary-log file name (`…-bin.000003` → `YOUR-PC-bin.000003`) | same file | avoid publishing a machine identifier |
| Duplicate copies of lessons 1 to 3 left out (`SELECT STATEMENT Tutorial.sql`, `WHERE and LIKE Clause Tutorial.sql`, `GROUP BY and ORDER BY Tutorial.sql`) | n/a | identical or near-identical to the numbered versions |
| `mysqlbackup.sql` (3.9 MB Workbench export) left out | n/a | mostly the default `world`, `sakila` and `sys` sample databases; the Parks database is in `setup/` |
| Files grouped into one folder per project and prefixed `practice - ` where they were my own extension | all | navigation |

## Added for this repository

| Addition | Purpose |
|---|---|
| `setup/03_import_layoffs.sql` | reproducible import of the layoffs CSV |
| `tests/` (3 files) | data-quality checks and the corrected queries |
| `docs/` | validation report, debugging log, glossary, how-to-run |
| `images/` | charts generated from the validated queries |
| every `README.md` | the write-ups |

## Suggestions I have *not* applied to the SQL

| Suggestion | File |
|---|---|
| Add `DROP EVENT IF EXISTS delete_retirees;` at the end | `15. TRIGGERS and EVENTS.sql` |
| Use `MAX` per company (not `SUM`) for funds, and `DISTINCT` for single-company answers | `practice - eda practice sheet 1.sql` |
| Order the early rolling total by `month_start` | `EDA practice_monthly _revenue.sql` |
| Replace the machine-specific `SHOW BINLOG EVENTS IN '…'` with a comment | `practice - trigger and event rough sheet.sql` |
