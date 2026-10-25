SELECT *
FROM employee_demographics as dem;

SELECT gender
FROM employee_demographics
GROUP BY gender;
# To use GROUP BY, the column in the select statement must match the column in the GROUP BY function. However this serves no puurpose and is therefore redundant.

SELECT gender, avg(age) as avg_age, min(age), max(age), count(age)
FROM employee_demographics
GROUP BY gender;

SELECT *
FROM employee_salary;

SELECT occupation, avg(salary), min(salary), max(salary), count(salary)
FROM employee_salary
GROUP BY occupation;

SELECT dem.first_name, dem.last_name, dem.age, sal.occupation, sal.salary
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
    ORDER BY age
;

SELECT first_name, last_name, occupation, salary
FROM employee_salary as sal
ORDER BY first_name;

SELECT *
FROM employee_salary as sal
JOIN employee_demographics as dem
	ON dem.employee_id = sal.employee_id
WHERE dem.age > 20;

SELECT sal.first_name, sal.last_name, dem.age, sal.salary, sal.occupation
FROM employee_salary as sal
JOIN employee_demographics as dem
	ON sal.employee_id = dem.employee_id
    WHERE age/2 >= 20
    ORDER BY dem.age DESC;


SELECT *
FROM employee_salary AS sal
JOIN employee_demographics AS dem
	ON dem.employee_id = sal.employee_id
;

SELECT dept_id, salary, SUM(salary) OVER(PARTITION BY dept_id ORDER BY employee_id) as dept_salary_sum
FROM employee_salary;
# this query shows the sum of the salaries for every department by order of employee_id

WITH Total_Department_Salary_Expenditure as
(
SELECT dept_id, salary, SUM(salary) OVER(PARTITION BY dept_id ORDER BY employee_id) as dept_salary_sum
FROM employee_salary
)
SELECT DISTINCT dept_id, MAX(dept_salary_sum) OVER(PARTITION BY dept_id)
FROM Total_Department_Salary_Expenditure;
# this query shows the total amount spent for the salaries of every department

