-- CTEs
# CTE stands for Common Table Expression
# A CTE is created by the following syntax.
# Using the 'WITH' function to start followed by the name you want to assign the CTE and the 'AS' keyword, then open parenthesis and type the CTE query, close the parenthesis and now type the main query referencing the CTE.
# Note that you can only use a CTE immediately after you create it, this means if you try to call the CTE in an entirely different query from the one that has the CTE, then it will output error saying the CTE table does not exist in the db(database).
# This is because a CTE is sort of like a temporary result you create in a query so that you can reference it in the main (complex) query.
# In that sense, a CTE is like a subquery in that it is just a query within a query.


WITH CTE_Example as
(
SELECT gender, AVG(salary) as avg_sal, MAX(salary) as max_sal, MIN(salary) as min_sal, COUNT(salary) as count_sal
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_sal)
FROM CTE_Example
;
# CTE_Example is just the name assigned to the CTE in this example. You can name it something else.
# There is not much difference between CTE and subquery but CTE makes the script more presentable and easy to read


SELECT AVG(avg_sal)
FROM (SELECT gender, AVG(salary) as avg_sal, MAX(salary) as max_sal, MIN(salary) as min_sal, COUNT(salary) as count_sal
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender) as subquery_example
;
# This is the same query but in subquery format and not CTE. It is easy to see that this one looks more compact and less spacious as compared to the CTE syntax above.
# Both give the same output though.

SELECT AVG(avg_sal)
FROM CTE_Example;
# This outputs error Table 'parks_and_recreation.cte_example' does not exist which basically means the table CTE_Example does not exist in the db.
# This is because this query does not contain the CTE.

-- Creating multiple CTEs within a query
WITH CTE1 as
(
SELECT employee_id, gender, birth_date
FROM employee_demographics as dem
WHERE birth_date > '1985-01-01'
),
CTE2 as
(
SELECT employee_id, salary
FROM employee_salary as sal
WHERE salary > 50000
)
SELECT *
FROM CTE1
JOIN CTE2
	ON CTE1.employee_id = CTE2.employee_id
;


# Now supposing we want to rename the column names in the CTE query
# We can use aliasing in the select statement to assign new names or
# We can simply do this; open a parenthesis after the CTE name and type the desired new names for the columns respectively.
WITH CTE_Example (GENDER, AVERAGE, MAXIMUM, MINIMUM, COUNT) as
(
SELECT gender, AVG(salary) as avg_sal, MAX(salary) as max_sal, MIN(salary) as min_sal, COUNT(salary) as count_sal
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT *
FROM CTE_Example
;
