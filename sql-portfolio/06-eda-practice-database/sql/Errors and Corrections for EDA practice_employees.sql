-- ERRORS AND CORRECTIONS


SELECT employee_id, `name`, department_id, hire_date, YEAR(hire_date),
ROW_NUMBER() OVER(PARTITION BY YEAR(hire_date) ORDER BY department_id) as year_hires
FROM employees_staging
;
# this appears to give the same answer as the query below but there is a difference
# what we want is to find out how many people were hired per year
# but this query shows a person's position within their year group, ordered by department_id.
# ROW_NUMBER() assigns a different, unique number to every row in a partition — it's built for ranking individual rows, not for counting a group's size

SELECT YEAR(hire_date), COUNT(*) as num_hired
FROM employees_staging
GROUP BY YEAR(hire_date)
ORDER BY YEAR(hire_date)
;
# this is the correct query which shows the number of people hired per year


SELECT `name`, YEAR(hire_date), COUNT(*) as num_hired
FROM employees_staging
GROUP BY `name`, YEAR(hire_date)
;
# the aim of this query is to show more data apart from the year and num of hires for said years
# this query outputs wrong results because grouping by both name and year makes count treat every row as unique instead of grouping rows with the same year into one like above

SELECT employee_id, `name`, department_id, YEAR(hire_date),
COUNT(*) OVER(PARTITION BY YEAR(hire_date)) as hires_that_year
FROM employees_staging
;
# this is the right query for the attempt above
# this shows the year, num of hires per year as well as other columns data


# counting the direct reports

SELECT e1.employee_id, e1.`name`, COUNT(e2.employee_id) as direct_reports
FROM employees_staging as e1
LEFT JOIN employees_staging as e2
	ON e1.employee_id = e2.manager_id
GROUP BY e1.employee_id, e1.`name`
;
# in this query we are considering all the employees from table e1 as potential managers and finding matches for their employee_id in table e2 manager_id column
# hence we join on e1.employee_id = e2.manager_id and not e1.manager_id = e2.employee_id like we did with the inner join

SELECT e1.employee_id, e1.`name`, COUNT(e2.manager_id) as direct_reports
FROM employees_staging as e1
LEFT JOIN employees_staging as e2
	ON e1.employee_id = e2.manager_id
GROUP BY e1.employee_id, e1.`name`
;
# find out why the results for this are the same as the above


# average salary_estimates for the each year

SELECT YEAR(hire_date), AVG(salary_estimate)
FROM employees_staging
GROUP BY YEAR(hire_date)
;


# when creating the year_tenure bucket/grouping/classes

SELECT YEAR(hire_date), AVG(salary_estimate),
CASE
	WHEN hire_date < '2019-01-01' THEN 'Veteran'
    WHEN hire_date < '2022-01-01' THEN 'Mid-Tenure'
    ELSE 'Recent'
END as year_tenure
FROM employees_staging
GROUP BY YEAR(hire_date), year_tenure
;
/* the results from the output does not group the years into the 3 different classes as we want
adding YEAR(hire_date) to GROUP BY causes mysql consider all the years when grouping
hence the results show all the unique row values under the hire_date paired with their respective class
instead of just the 3 year_tenure classes */
 
