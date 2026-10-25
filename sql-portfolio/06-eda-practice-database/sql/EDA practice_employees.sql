-- Table 1

SELECT *
FROM employees;


SELECT *,
ROW_NUMBER() OVER(PARTITION BY `name`, salary,
department_id, manager_id, hire_date ORDER BY employee_id) as row_num
FROM employees
;

WITH duplicates as
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `name`, salary,
department_id, manager_id, hire_date ORDER BY employee_id ASC) as row_num
FROM employees
)
SELECT *
FROM duplicates
WHERE row_num > 1;

DROP TABLE IF EXISTS employees_staging;

CREATE TABLE `employees_staging` (
  `employee_id` int NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `salary` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `manager_id` int DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  PRIMARY KEY (`employee_id`),
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT*
FROM employees_staging;

INSERT INTO employees_staging
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `name`, salary,
department_id, manager_id, hire_date ORDER BY employee_id) as row_num
FROM employees
;


SELECT `name`, TRIM(`name`)
FROM employees_staging
;

SELECT `name`, TRIM(`name`), TRIM(TRAILING '.' FROM `name`)
FROM employees_staging
;

ALTER TABLE employees_staging
DROP COLUMN row_num;

SELECT *
FROM employees_staging;

SELECT *
FROM employees_staging
WHERE `name` IS NULL
UNION ALL
SELECT *
FROM employees_staging
WHERE salary IS NULL
UNION ALL
SELECT *
FROM employees_staging
WHERE department_id IS NULL
UNION ALL
SELECT *
FROM employees_staging
WHERE manager_id IS NULL
UNION ALL
SELECT *
FROM employees_staging
WHERE hire_date IS NULL;

SELECT *
FROM employees_staging
ORDER BY department_id;

# dealing with the null values
# NOTE: Not all null values are because of data-quality issues. The presence of a null value does not always imply that it is an error that needs to be fixed.
# Structurally meaningful nulls aren't errors at all and shouldn't be touched or even flagged as a "problem."
# Missing-due-to-process nulls are sometimes estimable, like salary.
# And then there are Genuinely Unknown nulls where nothing in the data can explain it
# there are 2 null values in the salary column (Mia White and Isabella Wilson), we can estimate the values by finding the average salary for the departments they belong to
# however do not update the value with the estimate as it is not the actual value but an estimate
# the manager_id column has 3 null values. these are structurally meaningful nulls and not errors as it can be inferred from the data that these individuals have no manager_id because they are the highest ranked in their departments.


SELECT *
FROM employees_staging
WHERE salary IS NULL;

SELECT *
FROM employees_staging;

ALTER TABLE employees_staging
ADD COLUMN salary_estimate INT;

ALTER TABLE employees_staging
ADD COLUMN salary_is_imputed BOOLEAN DEFAULT FALSE;

SELECT department_id, AVG(salary) as dept_avg
FROM employees_staging
GROUP BY department_id;

SELECT department_id, ROUND(AVG(salary)) as dept_avg
FROM employees_staging
GROUP BY department_id
;

SELECT *
FROM employees_staging as emp_table
JOIN (SELECT department_id, ROUND(AVG(salary)) as dept_avg
	FROM employees_staging
	GROUP BY department_id) as dept_avgs
    ON emp_table.department_id = dept_avgs.department_id
;


UPDATE employees_staging as emp_table
JOIN (
	SELECT department_id, ROUND(AVG(salary)) as dept_avg
	FROM employees_staging
	GROUP BY department_id) as dept_avgs
    ON emp_table.department_id = dept_avgs.department_id
SET salary_estimate = COALESCE(emp_table.salary, dept_avgs.dept_avg),
salary_is_imputed = emp_table.salary IS NULL
;
# COALESCE(a, b) returns a if a is not NULL, otherwise it returns b. It's essentially a built-in "if this is missing, use that instead".

SELECT *
FROM employees_staging;

WITH dept_sal_distr as
(
	SELECT department_id, AVG(salary_estimate), MIN(salary_estimate),
	MAX(salary_estimate), STDDEV(salary_estimate)
	FROM employees_staging
	WHERE department_id = 1
	UNION ALL
	SELECT department_id, AVG(salary_estimate), MIN(salary_estimate),
	MAX(salary_estimate), STDDEV(salary_estimate)
	FROM employees_staging
	WHERE department_id = 2
	UNION ALL
	SELECT department_id, AVG(salary_estimate), MIN(salary_estimate),
	MAX(salary_estimate), STDDEV(salary_estimate)
	FROM employees_staging
	WHERE department_id = 3
)
SELECT *
FROM dept_sal_distr;

SELECT department_id, AVG(salary_estimate), MIN(salary_estimate),
MAX(salary_estimate), SUM(salary_is_imputed)
FROM employees_staging
GROUP BY department_id;

SELECT department_id, COUNT(*) as count_imputed
FROM employees_staging
WHERE salary_is_imputed = TRUE
GROUP BY department_id;

SELECT employee_id, `name`, department_id, salary_estimate, salary_is_imputed,
RANK() OVER(PARTITION BY department_id ORDER BY salary_estimate DESC) as rank_per_dept
FROM employees_staging
;

SELECT employee_id, `name`, department_id, salary_estimate, salary_is_imputed,
RANK() OVER(PARTITION BY department_id ORDER BY salary_estimate desc) as rank_high,
RANK() OVER(PARTITION BY department_id ORDER BY salary_estimate asc) as rank_low
FROM employees_staging
;

WITH Salary_rank as
(
SELECT employee_id, `name`, department_id, salary_estimate, salary_is_imputed,
RANK() OVER(PARTITION BY department_id ORDER BY salary_estimate desc) as rank_high,
RANK() OVER(PARTITION BY department_id ORDER BY salary_estimate asc) as rank_low
FROM employees_staging
)
SELECT *
FROM Salary_rank
WHERE rank_high = 1 OR rank_low = 1
;

SELECT *
FROM employees_staging;

SELECT hire_date, YEAR(hire_date)
FROM employees_staging
;


SELECT DISTINCT YEAR(hire_date), COUNT(*) as num_hired
FROM employees_staging
GROUP BY YEAR(hire_date)
ORDER BY YEAR(hire_date)
;

SELECT employee_id, `name`, department_id, YEAR(hire_date),
COUNT(*) OVER(PARTITION BY YEAR(hire_date)) as num_hires
FROM employees_staging
;

WITH Hire_Per_Year (ID, NAME, department_id, Year_of_Hire, Num_of_Hires) as
(
SELECT employee_id, `name`, department_id, YEAR(hire_date),
COUNT(*) OVER(PARTITION BY YEAR(hire_date)) as num_hires
FROM employees_staging
)
SELECT `name`, department_id, Year_of_Hire, Num_of_Hires
FROM Hire_Per_Year
;

WITH Hire_Per_Year (ID, NAME, department_id, Year_of_Hire, Num_of_Hires) as
(
SELECT employee_id, `name`, department_id, YEAR(hire_date),
COUNT(*) OVER(PARTITION BY YEAR(hire_date), department_id) as num_hires
FROM employees_staging
)
SELECT `name`, department_id, Year_of_Hire, Num_of_Hires
FROM Hire_Per_Year
ORDER BY department_id
;


SELECT *
FROM employees_staging
;

SELECT e1.employee_id as employee_id, e1.`name` as employee_name,
e2.employee_id as manager_id, e2.`name` as manager_name
FROM employees_staging as e1
JOIN employees_staging as e2
	ON e1.manager_id = e2.employee_id
;

SELECT COUNT(e1.manager_id) as num_of_direct_reports, e2.employee_id as manager_id, e2.`name`
FROM employees_staging as e1
JOIN employees_staging as e2
	ON e1.manager_id = e2.employee_id
GROUP BY e2.employee_id, e2.`name`
;

# OR

SELECT COUNT(*) as direct_reports, e2.employee_id as manager_id, e2.`name`
FROM employees_staging as e1
JOIN employees_staging as e2
	ON e1.manager_id = e2.employee_id
GROUP BY e2.employee_id, e2.`name`
;

SELECT *
FROM employees_staging as e1
LEFT JOIN employees_staging as e2
	ON e1.manager_id = e2.employee_id
;

SELECT e1.employee_id as employee_id, e1.`name` as employee_name,
e2.employee_id as manager_id, e2.`name` as manager_name
FROM employees_staging as e1
LEFT JOIN employees_staging as e2
	ON e1.manager_id = e2.employee_id
;

SELECT COUNT(*) as direct_reports, e2.employee_id as manager_id, e2.`name` as manager_name
FROM employees_staging as e1
LEFT JOIN employees_staging as e2
	ON e1.manager_id = e2.employee_id
GROUP BY e2.employee_id, e2.`name`
;


SELECT e1.employee_id, e1.name,
       COUNT(e2.employee_id) AS direct_reports
FROM employees_staging AS e1
LEFT JOIN employees_staging AS e2
    ON e2.manager_id = e1.employee_id
GROUP BY e1.employee_id, e1.name
HAVING COUNT(e2.employee_id) = 0
ORDER BY e1.name;

SELECT *
FROM employees_staging as e1
LEFT JOIN employees_staging as e2
	ON e1.employee_id = e2.manager_id
;


SELECT e1.employee_id, e1.`name`, COUNT(e2.employee_id) as direct_reports
FROM employees_staging as e1
LEFT JOIN employees_staging as e2
	ON e1.employee_id = e2.manager_id
GROUP BY e1.employee_id, e1.`name`
;
# in this query we are considering all the employees from table e1 as potential managers and finding matches for their employee_id in table e2 manager_id column
# hence we join on e1.employee_id = e2.manager_id and not e1.manager_id = e2.employee_id like we did with the inner join


SELECT *
FROM employees_staging
;

SELECT YEAR(hire_date), AVG(salary_estimate)
FROM employees_staging
GROUP BY YEAR(hire_date)
;

SELECT `name`, YEAR(hire_date), hire_date,
AVG(salary_estimate) OVER(PARTITION BY YEAR(hire_date))
FROM employees_staging
;

SELECT AVG(salary_estimate), COUNT(*) as num_of_employees,
CASE
	WHEN hire_date < '2019-01-01' THEN 'Veteran'
    WHEN hire_date < '2022-01-01' THEN 'Mid-Tenure'
    ELSE 'Recent'
END as year_tenure
FROM employees_staging
GROUP BY year_tenure
;

SELECT department_id,
CASE
	WHEN hire_date < '2019-01-01' THEN 'Veteran'
    WHEN hire_date < '2022-01-01' THEN 'Mid-Tenure'
    ELSE 'Recent'
END as year_tenure,
AVG(salary_estimate), COUNT(*) as num_of_employees
FROM employees_staging
GROUP BY department_id, year_tenure
;

