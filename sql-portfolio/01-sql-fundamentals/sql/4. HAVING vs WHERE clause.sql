-- HAVING Vs WHERE

SELECT gender, avg(age)
FROM parks_and_recreation.employee_demographics
WHERE avg(age) > 40
GROUP BY gender;
#This query outputs error, see explanation for the reason at the bottom of the script

SELECT gender, avg(age)
FROM parks_and_recreation.employee_demographics
GROUP BY gender
HAVING avg(age) > 40;

SELECT occupation, avg(salary)
FROM employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING avg(salary) > 75000;

SELECT occupation, avg(salary)
FROM employee_salary
WHERE occupation LIKE '%manager'
GROUP BY occupation;

SELECT occupation, salary
FROM employee_salary
GROUP BY occupation;
# This results in error because the salary column may contain multiple unique values for the same occupation and this causes SQL to not know which one to pick and group with the occupation

SELECT occupation, avg(salary) as avg_salary
FROM employee_salary
GROUP BY occupation;
# This query works because the statement avg(salary) as avg_salary directly creates a new average salary column which contains the averaged value of all the multiple values with the same occupation
# This takes care of the error that occured from having multiple values for the same occupation

SELECT occupation, avg(salary) as avg_salary
FROM employee_salary
GROUP BY avg_salary;
/*This query gives error because of SQL's Order of Operations.
The GROUP BY function executes before SELECT, so avg_salary as an alias doesn't even exist yet when GROUP BY is processed.
MySQL can't reference something that hasn't been computed yet.


/* NOTES:
The moment you introduce an aggregated column in the SELECT statement then the GROUP BY function should also be included in the query
The HAVING function works with aggregated columns and comes after the GROUP BY function
The WHERE function MUST come before the GROUP BY function since that is the correct order of SQL syntax
The aggregated function on a column in the SELECT statement (say avg(salary) ) only works after the GROUP BY function has run
So filtering and sorting of aggregated columns with WHERE will not work since the WHERE clause comes before the GROUP BY function per SQL syntax
This is where the HAVING clause comes in. The HAVING clause helps to filter or sort the aggregated function and it works because it comes after the GROUP BY function per SQL syntax
Also note that you cannot GROUP BY an aggregate function
This is the order of operations in SQL; FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
 */
