-- ============================================================================
-- tests/01_layoffs_cleaning_checks.sql
-- Data-quality checks to run AFTER 04-layoffs-data-cleaning/sql/16. DATA CLEANING.sql
-- Each check states what a healthy result looks like.
-- Run in database: world_layoffs
-- ============================================================================

-- 1. Row reconciliation. Expect: raw 2361, cleaned 1995 (2361 - 5 duplicates - 361 empty rows)
SELECT (SELECT COUNT(*) FROM layoffs)          AS raw_rows,
       (SELECT COUNT(*) FROM layoffs_staging2) AS cleaned_rows;

-- 2. Independent re-do must match the guided project. Expect: 0 and 0
SELECT (SELECT COUNT(*) FROM (SELECT * FROM layoffs_staging2 EXCEPT SELECT * FROM layoffs_clean) a) AS only_in_staging2,
       (SELECT COUNT(*) FROM (SELECT * FROM layoffs_clean EXCEPT SELECT * FROM layoffs_staging2) b) AS only_in_clean;

-- 3. Residual formatting problems. Expect: 0, 0, 0, 0, 0
SELECT SUM(company  <> TRIM(company))  AS untrimmed_company,
       SUM(location <> TRIM(location)) AS untrimmed_location,
       SUM(industry = '')              AS blank_industry,
       SUM(country LIKE '%.')          AS country_with_trailing_dot,
       SUM(industry LIKE 'Crypto%' AND industry <> 'Crypto') AS crypto_variants
FROM layoffs_staging2;

-- 4. Remaining NULLs (informational). Expect: 1 industry (Bally's Interactive) and 1 date (Blackbaud)
SELECT SUM(industry IS NULL) AS null_industry, SUM(`date` IS NULL) AS null_date,
       SUM(total_laid_off IS NULL) AS null_total, SUM(percentage_laid_off IS NULL) AS null_pct
FROM layoffs_staging2;

-- 5. No duplicates re-appear after standardising. Expect: 0
SELECT COUNT(*) AS duplicate_groups FROM (
  SELECT 1 FROM layoffs_staging2
  GROUP BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
  HAVING COUNT(*) > 1) x;

-- 6. Column types. Expect `date` = date. (percentage_laid_off is still TEXT: see 05-layoffs-eda README)
SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.columns
WHERE table_schema = 'world_layoffs' AND table_name = 'layoffs_staging2';

-- 7. Percentages are all valid values between 0 and 1. Expect: 0 rows
SELECT percentage_laid_off, COUNT(*) FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
  AND percentage_laid_off NOT REGEXP '^(0(\\.[0-9]+)?|1(\\.0+)?)$'
GROUP BY percentage_laid_off;

-- 8. Industry labels that may still need a decision. 'Fin-Tech' (3 rows) vs 'Finance' (239 rows)
SELECT industry, COUNT(*) AS n FROM layoffs_staging2 GROUP BY industry ORDER BY industry;
