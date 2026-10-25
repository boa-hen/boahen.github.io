-- Data Cleaning

-- Steps to note
#1 Remove Duplicates
#2 Standardize the data
#3 Null values or Blank values (clearing blank and null values or replacing them)
# Remove Columns or Rows (sometimes we might have to remove useless rows and columns)

# lets create our new db world_layoffs and import our layoffs table after which we can begin to clean our data
# we have to create a copy of our layoffs table and name it layoffs_staging, on which we will clean and implement all the neccesary changes
# this is good practice beacuse in the real workplace our original data may have certain complex processes and editing it may cause problems
# also it helps to have the original data so that in case we make an irreversble mistake it does not affect our original data

SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Removing Duplicates
# in this scenario our table does not have a column with unique row identifiers like an ID column
# so we have to create some sort of identifier that can help us single out duplicate entries
# we can do this by using row_number

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;
# it is important to partition by all the columns just to be safe
# note that the date in this query is the column 'date' in our table and not the keyword
# to avoid this confusion we can simply put it in a backtick `date` or select column date from the options that show when typing

WITH duplicate_cte as
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
# this shows the duplicates in our table

SELECT *
FROM layoffs_staging
WHERE company = 'Oda';
# initially when creating the row_num column I partitioned by some columns and not everything
# because of that when we created our cte to identify the duplicate values, one of the entries for the company 'Oda' appeared as a duplicate
# I then ran the query above to confirm if there really was a duplicate entry for 'Oda' and found that there was not any
# this made me understand that a mistake was made by not partitioning by all the columns, hence a correction was made

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';
# this helped to confirm the presence of a duplicate among the entries for 'Casper'
# we can now confirm that our cte works as intended with no issues

# now we have to remove ONLY the duplicate values from our table
WITH duplicate_cte as
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;
# the output from this query lets us know that we cannot update the cte
# so we will create a new staging table containing the row_num column and then we can delete the duplicates using row_num as the row identifier

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;
# And now we have finally removed the duplicates from our data


-- Standardizing the Data
# this means finding issues in our data and fixing it

SELECT company, TRIM(company)
FROM layoffs_staging2;
# this removes white spaces from the company column

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
# this query shows all the distinct values in the industry column ordered by the first column
# we can see that there are null and blank rows as well as rows that are similar or are basically the same industry eg, crypto and crytocurrency
# we need to join the similar ones under the same industry

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2;
# this shows all the unique values under the 'industry' column

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
# the output of this query shows an issue, someone added a period to 'United States' leading to another unique entry (United States.)
# since this is the only issue we can write a new query to get rid of the trailing period at the end

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
# doing trim alone does not fix it as it just gets rid of white spaces
# adding 'trailing '.' from country' shows what we want to get rid of and where it is in the data

# now we can update and set the previous one to the corrected one
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

# Notice that the format of the 'date' column in our data is text, hence we have to change it to date format so that we can perform time series analysis in the exploratory data anaysis
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
# remember to learn about date and time formatting in MySQL

UPDATE layoffs_staging2
SET date = STR_TO_DATE(`date`, '%m/%d/%Y');
# now we have updated the date from text format to date format

SELECT `date`
FROM layoffs_staging2;
# running this query again helps to verify that the update we made worked

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
# and now we have finally converted the date column to date


-- Null and Blank Values
# use IS NULL to look at the null values, = NULL will not work
# for null and blank values we try to fill them if we can i.e if we know what values fit the row
# else we remove them entirely if they prove useless to us

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
# this query helps us to identify if there are other entries for 'Airbnb' and what industry it falls under
# so that we can use it as reference to fill the null and blank values for same data

SELECT t1.industry, t2.industry
FROM layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
    AND t1.location = t2.location
    WHERE (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;

# this query simply means, join the table on itself based on the same company and location, then check if there are similar entries where the industry is null or empty and compare it to the entries where the industry is not null
# this helps to identify references that we can use to update the null or blank row entries

# now we are going to update the blanks with the ones that are not blank
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
# the output shows that after running the query 0 rows are affected, this means there is an issue we need to fix
# so what we did is we tried to set all the blank values in the industry column to null, the reasoning behind this is that
# after joining the layoffs_staging2 table to itself, the blank values are matched to 2 possible options i.e rows with entry values or blank values
# and we know that whenever there are multiple possible options that one value can be matched to, SQL is unable decide by itself which one to choose
# so if we are to set all the blank values to NULL then SQL will have only one option to match to. Lets try this and see if it works

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
    AND t1.location = t2.location
    WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;
# Notice the difference between the query this time, because there are no more blank values we have removed 't1.industry = '' ' from the query
# now the output matches the null values to the values that are not null, previously it matched to other blank values as well

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT t1.industry, t2.industry
FROM layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
    AND t1.location = t2.location
    WHERE (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;
# running this query again the output shows only the columns and no values, this means there are no matches where the values in t1 are null but are not null in t2
# this indicates to us that our update worked and now the null values in the industry column have been updated with matching values that have similar or same data

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
# the results in the output of this query is proof, the blank value that was present in the industry column previously has changed to become 'Travel' which matches other similar data for the company 'Airbnb'

SELECT *
FROM layoffs_staging2
WHERE company = 'Juul';
# same thing applies to the 'Juul' company as well as the others that had blank and null values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
# The only company that still has NULL values in the industry column is 'Bally's Interactive'

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';
# the output shows that there was only 1 data entry for this company
# hence SQL did not have any reference(populated row that has similar or same data but whose industry column is not NULL) to update the respective NULL values with


-- Removing Columns and Rows
# we delete rows and columns that we do not consider relevant for the purpose which we clean our data for
# in this case we are cleaning and preparing our data so that we can perform exploratory data analysis

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
# the results from this query shows us data for which the columns total_laid_off and percentage_laid_off are NULL
# this makes them useless to us since we cannot use such data in our analysis
# therefore we can delete them

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;
# notice that we still have the row_num column in our table, but we do not need it anymore so we can delete it as well

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
# this deletes the row_num column from our layoffs_staging2 table

# FINALLY we have our cleaned data!!!
SELECT *
FROM layoffs_staging2;
