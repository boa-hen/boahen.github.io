-- Joins

SELECT * 
FROM employee_demographics;

SELECT *
FROM employee_salary;

-- Inner Join - Returns rows that are the same in both columns from both tables
# Note: By default SQL considers JOIN as INNER JOIN so there is no need to specifically say INNER JOIN

SELECT *
FROM employee_demographics
INNER JOIN employee_salary
	ON employee_demographics.employee_id = employee_salary.employee_id
    ;
# This means we want to join the employee demographics table to the employee salary table based on the columns employee_id from the demographics table and employee_id from the salary table
# Note: If you don't specify employee_demographics.employee_id and employee_salary.employee_id it's going to return error saying the column 'employee_id' is ambiguous
# This is because you did not specify which table the employee_id column is from. The query below is a clear example.

SELECT *
FROM employee_demographics
INNER JOIN employee_salary
	ON employee_id = employee_id
;
# The output of this query gives an error due to ambiguity of the columns as explained above
    
# Note that the output from the INNER JOIN shows no result for employee_id number 2. This is because the employee_demographics table has no entry for employee_id number 2.
# This is a clear demonstration that shows that INNER JOINS does not just cut and paste the two specified columns together rather it joins rows with SIMILAR values or entries.

# Now we can use aliasing together with joins to shorten the length of the query since it looks a bit long
SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
    ;

SELECT employee_id, age, occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
    ;
# This gives the same error as in the previous query. column 'employee_id' is ambiguous so we have to specify

SELECT dem.employee_id, age, occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
    ;
# This works successfully however there will be no difference whether we use dem.employee_id or sal.employee_id since both are the same column

SELECT sal.employee_id, occupation, age
FROM employee_salary as sal
INNER JOIN employee_demographics as dem
	ON sal.employee_id = dem.employee_id;
    
SELECT sal.employee_id, sal.occupation, age
FROM employee_salary as sal
RIGHT JOIN employee_demographics as dem
	ON sal.employee_id = dem.employee_id;

SELECT sal.employee_id, sal.occupation, age
FROM employee_salary as sal
LEFT JOIN employee_demographics as dem
	ON sal.employee_id = dem.employee_id
;
    
-- Outer Join
# Under outer join we have a left outer join and a right outer join
# Left outer join Returns all rows from the left table, and matched rows from the right table. Where there's no match in the right table, you get NULL values for the right table's columns.
# Right outer join Returns all rows from the right table, and matched rows from the left table. Where there's no match in the left table, you get NULL values for the left table's columns.
# You can simply use LEFT JOIN and RIGHT JOIN without the need to add OUTER


SELECT *
FROM employee_demographics AS dem
LEFT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
    ;
# Note: the left table is the one in the FROM statement i.e the demographics table and the right table is the one in the JOIN statement i.e the salary table
# There should be a common column in both tables on which the join is performed.
# Notice that this gives an output exactly the same as the query with INNER JOIN above. Per the query statement it takes everything from the left table and joins it to the matches from the right table
    
SELECT *
FROM employee_demographics AS dem
RIGHT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
    ;
# The query takes everything from the right table(salary), joins it to the matches from the left table(demographics) and then outputs null for the row with mismatching values.
# Note: The positions of the left and right table are the same as in the left outer join query.
# Because there is no entry for employee_id 2 in the demographics table, right join outputs null in the row that matches employee_id 2 from the salary table

-- Self Join
# This is joining a table to itself

SELECT *
FROM employee_salary as emp1
JOIN employee_salary as emp2
	ON emp1.employee_id = emp2.employee_id;

SELECT emp1.employee_id as emp_santa,
emp1.first_name as first_name_santa,
emp1.last_name as last_name_santa,
emp2.employee_id as emp_id,
emp2.first_name as first_name_emp,
emp2.last_name as last_name_emp
FROM employee_salary as emp1
JOIN employee_salary as emp2
	ON emp1.employee_id + 1 = emp2.employee_id
;

-- Joining multiple tables together

SELECT *
FROM employee_demographics as dem
INNER JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
    INNER JOIN parks_departments as pd
    ON sal.dept_id = pd.department_id;
    
# We cannot join the parks_departments table to the employee_demographics table as they have no common columns
# However both the employee_salary and the parks_department tables have a department id column so they can be joined

SELECT *
FROM parks_departments;

