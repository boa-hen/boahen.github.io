-- Case Statements
# Case Statement allows you to add logic to a select statement

SELECT first_name,
last_name,
age,
CASE
	WHEN age <= 30 THEN 'Young'
    WHEN age BETWEEN 31 and 50 THEN 'Old'
    WHEN age >= 50 THEN "Senior"
END as Age_Bracket
FROM employee_demographics;
# Note: You can add multiple WHEN statements in the case statement

-- Pay Increase Scenario
# < 50000 = 5%
# > 50000 = 7%
# Finance = 10% bonus
# Find the new salaries and bonus of the employees given the above preamble

SELECT *
FROM employee_salary;

SELECT *
FROM parks_departments;

SELECT first_name, last_name, salary,
CASE
	WHEN salary < 50000 THEN salary + (salary * 0.05)
    WHEN salary > 50000 THEN salary + (salary * 0.07)
    ELSE salary
END as New_Salary,
CASE
	WHEN dept_id = 6 THEN salary * 0.10
    ELSE salary * 0
END as Bonus
FROM employee_salary;

