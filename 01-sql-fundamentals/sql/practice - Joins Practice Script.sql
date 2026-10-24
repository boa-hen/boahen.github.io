SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

SELECT*
FROM parks_departments;

SELECT *
FROM employee_demographics as dem
INNER JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
;

SELECT *
FROM employee_salary as sal
INNER JOIN employee_demographics as dem
	ON dem.employee_id = sal.employee_id
;
    
SELECT *
FROM employee_demographics as dem
INNER JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments as pd
	ON pd.department_id = sal.dept_id
;
    
    
SELECT dem.gender, dem.first_name, dem.last_name, dem.age,
sal.occupation, sal.salary,
pd.department_name
FROM employee_demographics as dem
INNER JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments as pd
	ON pd.department_id = sal.dept_id
;



SELECT *
FROM employee_demographics as dem
RIGHT JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
;

SELECT *
FROM employee_salary as sal
RIGHT JOIN employee_demographics as dem
	ON dem.employee_id = sal.employee_id
;
# Note that RIGHT JOIN does not return null for the missing employee_id 2 row from the salary table as you may think it will. This is the explanation;
# In this query RIGHT JOIN takes everything from the demographics table (which does not have employee_id 2), compares it to the salary table and then outputs the matches (which is basically everything excluding the row for empoyee_id 2)
# It does not output null as in the case where dem is the left table and sal is the right table.
# This is because the right table already has no row for employee_id 2 so to the RIGHT JOIN function that row does not exist in the first place.
# However with dem as the left table and sal as the right table, RIGHT JOIN creates a null row in the dem table after it compares the RIGHT table TO the LEFT table since it has identified values in the employee_id 2 row

SELECT *
FROM employee_demographics as dem
LEFT JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
;

SELECT *
FROM employee_salary as sal
LEFT JOIN employee_demographics as dem
	ON dem.employee_id = sal.employee_id
;
# LEFT JOIN returns null for the row in the right table that corresponds to the employee_id 2 row in the left table because there is no match for employee_id 2 in the right table.


SELECT *
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
;

SELECT *
FROM employee_salary as sal
JOIN employee_demographics as dem
	ON sal.employee_id = dem.employee_id
;
