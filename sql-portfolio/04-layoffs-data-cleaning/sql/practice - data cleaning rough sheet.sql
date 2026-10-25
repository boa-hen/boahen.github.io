-- testing to see if I understood data cleaning
# I am going to try to clean the layoffs data following the steps used in the tutorial
# my staging data will be named layoffs_dc

CREATE TABLE layoffs_dc
LIKE layoffs;

SELECT *
FROM layoffs_dc;

INSERT INTO layoffs_dc
SELECT *
FROM layoffs;

-- removing duplicates 

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_dc
;

WITH duplicates_cte as
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_dc
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;

# since we cannot directly update the cte, we must create a new table that contains the row_num column so that we can do what we need to do
# which is to delete the duplicate from the table

CREATE TABLE `layoffs_clean` (
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

# now we insert into our new table the select statement including the row_num data

INSERT INTO layoffs_clean
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_dc;

SELECT *
FROM layoffs_clean;

# now we can delete the duplicates from the table

DELETE
FROM layoffs_clean
WHERE row_num > 1;

SELECT *
FROM layoffs_clean
WHERE row_num > 1;


-- Standardizing the data

SELECT *
FROM layoffs_clean;

SELECT company, TRIM(company)
FROM layoffs_clean;

UPDATE layoffs_clean
SET company = TRIM(company);

SELECT *
FROM layoffs_clean
WHERE country LIKE '%.';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_clean
ORDER BY 1;

UPDATE layoffs_clean
SET country = TRIM(TRAILING '.' FROM country);

SELECT DISTINCT industry
FROM layoffs_clean
ORDER BY 1;
# we can see that apart from the null and blank values there is another issue, which 'Crypto' and 'Cryptocurrency'
# these are the same and should be under one value, the different entries however places them under different values
# so we have to correct this 

SELECT DISTINCT industry
FROM layoffs_clean
WHERE industry LIKE 'Crypto%';
# there are separate values but they are all similar so it is safe to say that they should be one

UPDATE layoffs_clean
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
# and DONE

# now we want to change the data format from text to date

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_clean;

UPDATE layoffs_clean
SET `date` = str_to_date(`date`, '%m/%d/%Y');
# we are not done yet

ALTER TABLE layoffs_clean
MODIFY COLUMN `date` date;
# now we are done converting the date column from text to date
# always remember to modify the date column to date after you finish changing the date format


-- Null and Blank values
# with the issue of null and blank values, we either try to find references so we can populate the respective rows
# or we delete them if the turn out to be useless
# what we mean by references are rows that have similar(or exactly the same) data as the blank or null rows
# by comparing these rows we can deduce what value is missing and use it to fill the blank and null ones

SELECT *
FROM layoffs_clean
WHERE industry IS NULL
OR industry = '';
# the output of this query shows us that there is only one entry under the 'industry' column that has a null value
# that is an entry for the company 'Bally's Interactive', now we need to check and see if we can find a reference for this data
# however there are multiple blank values as well, they correspond to these values in the company column: 'Airbnb','Carvana','Juul'
# we need to find references for them and try to fill the blank values

## before we proceed there is one thing we must do, we must SET ALL BLANK VALUES TO NULL
# this will not disrupt anything in our data and we can therefore focus only on NULL values

UPDATE layoffs_clean
SET industry = NULL
WHERE industry = '';

## METHOD 1
# we run queries to identify references for the null values in the industry column manually (one by one)
# this involves basing on their respective company values to identify the industry values that fit
# and use them to fill the null values

SELECT *
FROM layoffs_clean
WHERE company = 'Airbnb';
# from the results we can see that there is a similar row entry and it shows the industry under which the company 'Airbnb' belongs
# that is the 'Travel' industry, we can therefore use this to update our table and set all industry values for this company to 'Travel'

UPDATE layoffs_clean
SET industry = 'Travel'
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_clean
WHERE company = 'Carvana';
# the results show us 2 references for the industry and they are all the same value, 'Transportation'
# we can safely go ahead and make the update

UPDATE layoffs_clean
SET industry = 'Transportation'
WHERE company = 'Carvana';

SELECT *
FROM layoffs_clean
WHERE company = 'Juul';
# the results show one reference and the value for the industry is 'Consumer'

UPDATE layoffs_clean
SET industry = 'Consumer'
WHERE company = 'Juul';

SELECT *
FROM layoffs_clean
WHERE company LIKE 'Bally%';
# the result for this query shows all the entries for the company 'Bally's Interactive' that are present in our data
# notice that there is only one row entry, this means we cannot find a reference and therefore cannot do anything about this particular null value

# now we run the query to identify null or blank values again to see if we missed any

SELECT *
FROM layoffs_clean
WHERE industry IS NULL
OR industry = '';
# the only result is for the company 'Bally's Interactive' so we can conclude that we have dealt with all the null and blank values

## METHOD 2
# we can simply join the table of null values to itself, matching the rows whose industry column are null values to similar rows whose industry column are not null
# the tables must be joined on the same column(present in both) that is relevant enough to help us find references
# in this case that is the company column

SELECT *
FROM layoffs_clean as t1
JOIN layoffs_clean as t2
	ON t1.company = t2.company
    WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;
# this query joins the layoffs_clean table to itself based on the company column and matches the rows whose industry value is null to the rows whose industry value is not null
# this automatically shows us the references for what the null values should be without having to manually find out query after query
# this method is therefore better than method 1, especially in cases where we have large datasets

UPDATE layoffs_clean as t1
JOIN layoffs_clean as t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;



-- Removing Rows and Columns

SELECT *
FROM layoffs_clean;

# since we do not need the row_num column anymore we can delete it from the table
# it does not hurt to keep it but it was not part of the original data anyway

ALTER TABLE layoffs_clean
DROP COLUMN row_num;

# there are some data entries that have null values for relevant columns and whose references cannot be found
# such data we can do without, so deleting them will not hinder our later analysis in any way
# in this case such data are entries whose total_laid_off and percentage_laid_off columns both have null values
# these 2 columns are very relevant for our exploratory data anlaysis, and we do not have enough data(references) to deduce and fill the null and blank values

SELECT *
FROM layoffs_clean
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_clean
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
