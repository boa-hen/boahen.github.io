-- WHERE CLAUSE

SELECT *
FROM parks_and_recreation.employee_salary
WHERE first_name = 'Leslie';

SELECT *
FROM employee_salary
WHERE salary > 50000;

SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT *
FROM employee_salary
WHERE salary < 50000;

SELECT *
FROM employee_salary
WHERE salary <= 50000;


SELECT *
FROM employee_demographics
WHERE gender = 'Female';

SELECT *
FROM employee_demographics
WHERE gender != 'Female';


SELECT *
FROM employee_demographics
WHERE birth_date = '1985-01-01';

SELECT *
FROM employee_demographics
WHERE birth_date > '1985-01-01';

-- Note that default Date format in MySQL is Year-Month-Day


-- AND OR NOT -- Logical Operators
SELECT *
FROM employee_demographics
WHERE birth_date >'1985-01-01'
AND gender = 'male';

SELECT *
FROM employee_demographics
WHERE birth_date >'1985-01-01'
OR gender = 'male';

SELECT *
FROM employee_demographics
WHERE birth_date >'1985-01-01'
OR NOT gender = 'male';
# This means give results for birth date greater than 1985 or results for people with the gender male

SELECT *
FROM employee_demographics
WHERE first_name = 'Leslie' AND age = 44;
# AND - The output must meet both conditions

SELECT *
FROM employee_demographics
WHERE first_name = 'Leslie' OR age > 44;
# OR - The output must satisfy either any of the conditions or both

SELECT *
FROM employee_demographics
WHERE (first_name = 'Leslie' AND age = 44) OR age > 55;

SELECT *
FROM employee_demographics
WHERE (first_name = 'Leslie' OR age > 44) OR age > 55;
-- SQL follows the order of PEMDAS 
-- It executes the contents of the parathensis first before looking at anything that comes after the bracket


-- LIKE Statement
-- NOTE: % means anything else and _ means a specific value
SELECT *
FROM employee_demographics
WHERE first_name = 'Jerry';

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'Jer%';
# This means output values for first names that start with Jer followed by anything else 

SELECT *
FROM employee_demographics
WHERE first_name LIKE '%pr%';
# This means output values for the first names that begin with anything else but has 'pr' in the middle followed by anything else

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'a__';
# This means output values for the first names that start with 'a' followed by exactly two other letters. This implies that the name cannot be longer than 3 characters
# This outputs the name Ann

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'a___%';
# The output must be a name that starts with 'a' followed by exactly 3 other characters followed by anyhting else
# This outputs the names Andy and April because the % allows for April to be part of the output

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'a___';
# The output must be a name that starts with 'a' followed by exactly 3 other characters so the only result for this is Andy

SELECT *
FROM employee_demographics
WHERE birth_date LIKE '1985%';
# This outputs values for people with birth dates from the year 1985 so even if we don't know the specific month and year it will gives all results for 1985 birt dates


