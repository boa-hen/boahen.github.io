# Data

## `layoffs.csv`

| | |
|---|---|
| **What** | company layoff events, 11 March 2020 to 6 March 2023 |
| **Size** | 2,361 rows × 9 columns |
| **Used in** | [04 · data cleaning](../04-layoffs-data-cleaning/README.md), [05 · EDA](../05-layoffs-eda/README.md) |
| **Source** | the practice dataset supplied with the *"Become a Data Analyst"* SQL bootcamp by AlexTheAnalyst, a compilation of publicly reported layoffs. Please check the original source's terms before redistributing. |

| Column | Type after import | Meaning |
|---|---|---|
| `company` | text | company name |
| `location` | text | city or region of the layoff |
| `industry` | text | industry label |
| `total_laid_off` | int | people laid off (many are missing) |
| `percentage_laid_off` | text | share of the workforce (0 to 1; 1 = 100%) |
| `date` | text → DATE after cleaning | date of the announcement, `m/d/yyyy` in the raw file |
| `stage` | text | funding stage (Post-IPO, Series B, …) |
| `country` | text | country |
| `funds_raised_millions` | int | **company-level** total funding in US$ millions, repeated on every row for that company |

Missing values are written as the text `NULL`; [`setup/03_import_layoffs.sql`](../setup/03_import_layoffs.sql) turns them into real NULLs.

**Known quirks** (all handled or documented in the projects): 5 exact duplicate rows · inconsistent labels (`Crypto`, `Crypto Currency`, `CryptoCurrency`) · a trailing full stop in `United States.` · stray spaces in 11 company names · 3 blank industries · 1 undated row · 361 rows with no layoff numbers · `funds_raised_millions` is per company, not per event.

## Synthetic data

The Parks and Recreation tables ([`setup/01…`](../setup/01_create_parks_and_recreation.sql)) are the course's sample data. The nine `eda_practice` tables ([`setup/02…`](../setup/02_create_eda_practice.sql)) are small, **synthetic** tables I used to practise. They contain fixed values (including the 400 tweets), so every run gives identical results. No real people are represented.
