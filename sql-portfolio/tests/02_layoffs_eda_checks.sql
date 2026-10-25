-- ============================================================================
-- tests/02_layoffs_eda_checks.sql
-- Cross-checks and corrected versions of a few EDA queries.
-- Run in database: world_layoffs (after the cleaning scripts)
-- ============================================================================

-- A. Funds raised: SUM across layoff rows double-counts. funds_raised_millions describes the
--    COMPANY, but it is repeated on every layoff row, so summing it multiplies it.
--    Naive total: 1,601,450  |  Correct (one value per company): 804,181
SELECT (SELECT SUM(funds_raised_millions) FROM layoffs_clean) AS naive_sum_of_all_rows,
       (SELECT SUM(mx) FROM (SELECT company, MAX(funds_raised_millions) AS mx
                             FROM layoffs_clean GROUP BY company) t) AS sum_of_company_max;

-- A2. Company-level view: rows, naive sum, and the value to use
SELECT company, COUNT(*) AS layoff_rows, SUM(funds_raised_millions) AS naive_sum,
       MAX(funds_raised_millions) AS funds_raised_correct
FROM layoffs_clean GROUP BY company ORDER BY naive_sum DESC LIMIT 8;

-- A3. Country level, corrected (one value per company per country)
SELECT country, SUM(mx) AS funds_raised_millions
FROM (SELECT country, company, MAX(funds_raised_millions) AS mx FROM layoffs_clean GROUP BY country, company) t
GROUP BY country ORDER BY funds_raised_millions DESC LIMIT 5;

-- B. "Which company raised the most?" returns one row PER LAYOFF EVENT (Netflix x4).
--    Add DISTINCT (or LIMIT 1) to get one answer.
SELECT DISTINCT company FROM layoffs_clean
WHERE funds_raised_millions = (SELECT MAX(funds_raised_millions) FROM layoffs_clean);

-- C. Ties: the 5th-largest total is a tie (Microsoft and Philips, both 10,000).
--    LIMIT 5 would silently drop one of them; RANK() shows both.
SELECT company, total, RANK() OVER (ORDER BY total DESC) AS rnk FROM (
  SELECT company, SUM(total_laid_off) AS total FROM layoffs_staging2 GROUP BY company) t
ORDER BY total DESC LIMIT 7;

-- D. Rows with no date fall into a NULL year bucket (Blackbaud, 500 people)
SELECT YEAR(`date`) AS yr, SUM(total_laid_off) AS total, COUNT(*) AS events
FROM layoffs_staging2 GROUP BY YEAR(`date`) ORDER BY yr;

-- E. percentage_laid_off is TEXT. MAX() on text compares characters, not numbers.
--    It happens to work here, but a numeric cast is safer:
SELECT MAX(percentage_laid_off) AS text_max,
       MAX(CAST(percentage_laid_off AS DECIMAL(4,2))) AS numeric_max
FROM layoffs_staging2;

-- F. Collation effect: MySQL's default collation ignores case and accents, so COUNT(DISTINCT company)
--    returns 1,628, not the 1,633 a case-sensitive tool (e.g. pandas) reports.
SELECT COUNT(DISTINCT company) AS distinct_companies FROM layoffs_clean;
