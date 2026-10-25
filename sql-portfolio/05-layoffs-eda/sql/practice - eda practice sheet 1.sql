SELECT *
FROM layoffs_clean;

SELECT COUNT(DISTINCT company) as num_of_companies
FROM layoffs_clean;

SELECT COUNT(DISTINCT location) as num_of_locations
FROM layoffs_clean;

SELECT COUNT(DISTINCT industry) as num_of_industries
FROM layoffs_clean;

SELECT COUNT(DISTINCT country) as num_of_countries
FROM layoffs_clean;

SELECT COUNT(DISTINCT stage) as num_of_stages
FROM layoffs_clean;


SELECT MAX(total_laid_off), MIN(total_laid_off), SUM(total_laid_off), AVG(total_laid_off)
FROM layoffs_clean;

SELECT MAX(funds_raised_millions), MIN(funds_raised_millions), SUM(funds_raised_millions) as total_funds_raised, AVG(funds_raised_millions) as avg_funds_raised
FROM layoffs_clean;


SELECT company as Company_With_Max_Layoffs
FROM layoffs_clean
WHERE total_laid_off = (SELECT MAX(total_laid_off) as max_laid_off
						FROM layoffs_clean);
# this query shows the exact company with the most number of layoffs

SELECT company as Company_With_Min_Layoffs
FROM layoffs_clean
WHERE total_laid_off = (SELECT MIN(total_laid_off) as min_laid_off
						FROM layoffs_clean);
# this query shows the exact company with the least number of layoffs

SELECT company as Company_With_Most_Funds_Raised
FROM layoffs_clean
WHERE funds_raised_millions = (SELECT MAX(funds_raised_millions)
								FROM layoffs_clean);
# this query shows the company with the most funds raised

SELECT company as Company_With_Least_Funds_Raised
FROM layoffs_clean
WHERE funds_raised_millions = (SELECT MIN(funds_raised_millions)
								FROM layoffs_clean);
# this query shows the company with the least funds raised

SELECT company, SUM(funds_raised_millions)
FROM layoffs_clean
GROUP BY company
ORDER BY 2 desc;
# this shows the company as well as the total funds raised for said company, however I realized that the output is misleading
# this is because for each event of layoffs entry for the companies, the funds raised is repeated
# this results in an issue of summing the funds raised multiple times, leading to an inflated sum

SELECT company, SUM(DISTINCT funds_raised_millions)
FROM layoffs_clean
GROUP BY company
ORDER BY 2 desc;
# this is the correct query that gives the accurate sum of funds raised for each company

SELECT country, SUM(funds_raised_millions)
FROM layoffs_clean
GROUP BY country
ORDER BY 2 desc;
# this is the initial query I wrote to show the total funds raised per country as I did for companies in the previous one
# however I repeated the same mistake so the correction is the query below

SELECT country, SUM(DISTINCT funds_raised_millions)
FROM layoffs_clean
GROUP BY country
ORDER BY 2 desc;
# this is the correct query that gives the accurate sum of funds raised for each country

WITH total_funds as
(SELECT DISTINCT company, max(funds_raised_millions) funds
FROM layoffs_clean
GROUP BY company
)
SELECT sum(funds)
FROM total_funds
;
# this is total amount of funds that was raised after summing the individual funds raised by all companies.
# the result 876,286 is a more reliable figure than the figure 1,767,276 gotten from naively summing all the funds raised like in the query below and in the aggregates query at the start

SELECT SUM(funds_raised_millions)
from layoffs_clean;
# as noted in the above query, the figure from this output is unreliable since it is a summation involving duplicates.

SELECT company, SUM(total_laid_off)
FROM layoffs_clean
GROUP BY company
ORDER BY 2 desc;
# this shows the company as well as the total number of people laid off for said company

SELECT country, SUM(total_laid_off)
FROM layoffs_clean
GROUP BY country
ORDER BY 2 desc;

SELECT company, industry, location, country
FROM layoffs_clean;

SELECT MAX(`date`), MIN(`date`)
FROM layoffs_clean;

SELECT `date`, company,	total_laid_off
FROM layoffs_clean
WHERE total_laid_off = (SELECT MAX(total_laid_off)
FROM layoffs_clean);
# this shows the date on which the company with the most number of people laid off carried out the exercise

SELECT `date`, company, funds_raised_millions
FROM layoffs_clean
WHERE funds_raised_millions = (SELECT MAX(funds_raised_millions)
FROM layoffs_clean);
# this shows the date on which the company with the most amount of funds raised achieved said goal

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_clean
GROUP BY YEAR(`date`)
ORDER BY 1;
# this shows the total amount laid off for each year present in the data

SELECT SUBSTRING(`date`,1,7) as `MONTH`, `date`
FROM layoffs_clean;

SELECT SUBSTRING(`date`,1,7) as `MONTH`, SUM(total_laid_off) as total_fired
FROM layoffs_clean
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

WITH ROLLING_TOTAL as
(
SELECT SUBSTRING(`date`,1,7) as `MONTH`, SUM(total_laid_off) as total_fired
FROM layoffs_clean
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`, total_fired, SUM(total_fired) OVER(ORDER BY `MONTH`) as rolling_total
FROM ROLLING_TOTAL;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_clean
GROUP BY company, YEAR(`date`)
ORDER BY 3 desc;


WITH Company_Year (company, years, total_fired) as
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_clean
GROUP BY company, YEAR(`date`)
),
Year_Rank as
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_fired desc) as Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Year_Rank
WHERE Ranking <= 3;
