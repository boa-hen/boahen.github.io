-- Unions
# Note that by default Union is Union DISTINCT so it outputs only unique values

SELECT age, gender
FROM employee_demographics
UNION
SELECT first_name, last_name
FROM employee_salary;
# This combines rows of data instead of columns as in joins. It is advised to union similar rows
# age and gender are different from first_name and last_name so when combined the data given is messy 

SELECT first_name, last_name
FROM employee_demographics
UNION
SELECT first_name, last_name
FROM employee_salary;

SELECT first_name, last_name
FROM employee_demographics
UNION DISTINCT
SELECT first_name, last_name
FROM employee_salary;
# This gives the same output as the above query.

SELECT first_name, last_name
FROM employee_demographics
UNION ALL
SELECT first_name, last_name
FROM employee_salary;
# This outputs everything including the duplicate values

SELECT first_name, last_name, 'Old' as Label
FROM employee_demographics
WHERE age > 50;

SELECT first_name, last_name, 'Highly Paid Employee' as Label
FROM employee_salary
WHERE salary > 70000;

SELECT first_name, last_name, 'Old Man' as Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Lady' as Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Highly Paid Employee' as Label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name
;

