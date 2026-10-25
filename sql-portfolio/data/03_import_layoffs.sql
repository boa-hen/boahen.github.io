-- ============================================================================
-- 03_import_layoffs.sql
-- Creates the world_layoffs database and loads data/layoffs.csv into `layoffs`.
--
-- Two ways to load the data:
--   A) MySQL Workbench: right-click the `layoffs` table > Table Data Import Wizard
--      (this is how the original course does it), or
--   B) the LOAD DATA statement below (command line / any client with local_infile on).
--
-- The CSV writes missing values as the text NULL, so NULLIF() turns them into real NULLs.
-- Column types mirror the import wizard's output (text for most columns, int for counts).
-- ============================================================================
DROP DATABASE IF EXISTS world_layoffs;
CREATE DATABASE world_layoffs;
USE world_layoffs;

CREATE TABLE layoffs (
  company               TEXT,
  location              TEXT,
  industry              TEXT,
  total_laid_off        INT DEFAULT NULL,
  percentage_laid_off   TEXT,
  `date`                TEXT,
  stage                 TEXT,
  country               TEXT,
  funds_raised_millions INT DEFAULT NULL
);

-- Adjust the path to wherever data/layoffs.csv lives on your machine.
-- Needs: SET GLOBAL local_infile = 1;  and a client started with --local-infile=1
LOAD DATA LOCAL INFILE 'data/layoffs.csv'
INTO TABLE layoffs
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'            -- use '\n' if your copy of the file has Unix line endings
IGNORE 1 LINES
(@company, @location, @industry, @total, @pct, @date, @stage, @country, @funds)
SET company               = NULLIF(@company,  'NULL'),
    location              = NULLIF(@location, 'NULL'),
    industry              = NULLIF(@industry, 'NULL'),
    total_laid_off        = NULLIF(@total,    'NULL'),
    percentage_laid_off   = NULLIF(@pct,      'NULL'),
    `date`                = NULLIF(@date,     'NULL'),
    stage                 = NULLIF(@stage,    'NULL'),
    country               = NULLIF(@country,  'NULL'),
    funds_raised_millions = NULLIF(@funds,    'NULL');

-- Sanity check: should return 2361 rows, 1 NULL industry, 3 blank industries, 1 NULL date
SELECT COUNT(*) AS total_rows,
       SUM(industry IS NULL) AS null_industry,
       SUM(industry = '')    AS blank_industry,
       SUM(`date` IS NULL)   AS null_date
FROM layoffs;
