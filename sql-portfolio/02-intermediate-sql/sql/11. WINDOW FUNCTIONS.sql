-- Window Functions

SELECT gender, AVG(salary) as avg_salary
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender;
# The output shows just the collective gender groups and their respective salary average

SELECT gender, AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
# This is a window function with empahsis on the 'AVG(salary) OVER(PARTITION BY gender)' column.
# It shows the respective average of each employee based on their gender group

SELECT dem.first_name, dem.last_name, gender,
AVG(salary) OVER(PARTITION BY gender) as avg_salary
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
# Partition By orders the output by gender regardless of the other columns because the query partitions by gender ONLY.

SELECT dem.first_name, dem.last_name, gender, AVG(salary) as avg_salary
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
GROUP BY dem.first_name, dem.last_name, gender;
# Since we are grouping by all the separate columns, every row appears as a unique value because GROUP BY does not know which column to prioritize.
# This causes even the avg_salary column to return completely different values (which are actually the averages of each unique salary value over itself i.e The output returns the same salary values themselves)

-- Rolling Total
# starts at a specific value and adds on values from subsequent rows based on your table values
# Note that if your query contains a partition then the rolling total(sum) is done in order of the partition

SELECT dem.first_name, dem.last_name, gender, salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) as Rolling_Total_With_Partition
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
# This query is partitioned by gender. The sums therefore are done separately for both male and female.
# For the females, the first person's sum is 75000. The next person's sum is 75000+25000=100000. The following person's sum is 100000+60000=160000. This goes on until the final female row as per the partition.
# The same process applies to the males. The first sum is 50000. Followed by the next person's sum which is 50000+50000=100000. Then 100000+90000=190000. And so on until the final male row.

SELECT dem.first_name, dem.last_name, gender, salary,
SUM(salary) OVER(ORDER BY dem.employee_id) as Rolling_Total_Without_Partition
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
# This query does not partition the output by any column but the rolling total(sum) is done in order of the column employee_id.

-- Row Number
# It assigns numbers to rows based on the order indicated (in the partition by or order by in the window function, or whatever order that is presently active)

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER()
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
# In this query the output rows are numbered by default in ascending order

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender)
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
# This query partitions by gender so the numbering of the rows differ for both genders. Female starts with 1 and ends at 4. Males starts with 1 and ends at 7.
# However this is just by order of how the table was stored i.e after joining both tables based on employee_id.

-- what if we want to rank the gender-partitioned table by order of the highest salary to the lowest

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) as Row_Num,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) as Rank_Num,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) as Dense_Rank_Num
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id;
# There is a difference between rank and row number. There is also a difference between rank and dense rank.
# Row number does not give duplicate values the same number. It just automatically assigns them different numbers based on some other order running in the background.
# When rank encounters duplicate values it gives them the same rank number but the next value after that gets a rank number positionally and not numerically.
# When dense_rank encounters duplicate values it gives them the same rank number but the next value after that gets a rank number numerically and not positionally.


