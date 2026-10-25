-- Subqueries

SELECT *
FROM employee_demographics
WHERE employee_id IN
				(SELECT employee_id
					FROM employee_salary
                    WHERE dept_id = 1)
;
# Note that if you select more than one column in the subquery it won't work. It outputs error 'Operand should contain 1 column(s)'

SELECT first_name, salary,
(SELECT avg(salary)
FROM employee_salary) as Avg_Salary
FROM employee_salary
;
# This outputs the overall average of ALL the salaries

SELECT avg(salary)
FROM employee_salary;
# This confirms the output of the above query

SELECT first_name, salary, avg(salary)
FROM employee_salary
GROUP BY first_name, salary
;
# This outputs the independent average of the individual salaries which is redundant because the answer is the same salary value

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM employee_demographics
GROUP BY gender;

SELECT AVG(avg_age), AVG(max_age), AVG(min_age), AVG(count_age)
FROM
(SELECT gender,
AVG(age) as avg_age,
MAX(age) as max_age,
MIN(age) as min_age,
COUNT(age) as count_age
FROM employee_demographics
GROUP BY gender) as Agg_table
;
