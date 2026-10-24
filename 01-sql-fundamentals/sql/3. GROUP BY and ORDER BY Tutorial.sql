-- GROUP BY and ORDER BY

SELECT *
FROM employee_demographics;

SELECT gender
FROM employee_demographics
GROUP BY gender;

SELECT first_name
FROM employee_demographics
GROUP BY gender;
# Note that if you are not using an aggregate function in the SELECT statement when you want to use the GROUP BY clause,
# then the columns being selected should match what is being grouped by else the function will not work

SELECT gender, AVG(age)
FROM employee_demographics
GROUP BY gender;
# This outputs the average ages of the data from the table grouped by gender 

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM employee_demographics
GROUP BY gender;
# The COUNT function shows exactly how many values are in the column that have been grouped


SELECT *
FROM employee_salary;

SELECT occupation
FROM employee_salary
GROUP BY occupation;

SELECT occupation, salary
FROM employee_salary
GROUP BY occupation, salary;


-- ORDER BY - sorts the output in either ascending or descending order
# Note: ASC means Ascending and DESC means Descending
SELECT *
FROM employee_demographics
ORDER BY first_name;
# By default the output is always in ascending order, so for text values that is from A-Z and for numeric values 0-9

SELECT *
FROM employee_demographics
ORDER BY first_name DESC;
# Adding ASC or DESC allows to change the order to what we like

SELECT *
FROM employee_demographics
ORDER BY gender, age;
# This gives a result where the priority order for the output is the gender after which the age is also ordered
# Note that the ORDER BY function orders the output according to the order of arrangement of columns in the statement query

SELECT *
FROM employee_demographics
ORDER BY age, gender;
# This gives a result where the priority order for the output is the age after which the gender is also ordered

SELECT *
FROM employee_demographics
ORDER BY gender, age DESC;
# This outputs the table ordered by gender first in ascending order followed by the age ordered in descending order
#The age is ordered in descending order because we added DESC to the query

# If you already know the order of placement of the columns in the table then you can simply order by their arrangement or placement number instead of using the column name itself
# This is not recommended though as it can cause problems in case there is a change in the position of the columns
SELECT *
FROM employee_demographics
ORDER BY 5,4;


