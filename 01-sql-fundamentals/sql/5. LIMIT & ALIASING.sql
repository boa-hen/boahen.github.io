-- Limit & Aliasing

SELECT *
FROM employee_demographics
LIMIT 3;
# This limits the result shown to just 3 outputs in no particular order

SELECT *
FROM employee_demographics
ORDER BY age DESC
LIMIT 3;
# This outputs data for the the 3 oldest employees in the table

SELECT *
FROM employee_demographics
ORDER BY age DESC;
# This outputs data for the columns in the entire table ordered by age

SELECT *
FROM employee_demographics
ORDER BY age DESC
LIMIT 3, 1;
# This means starting at position 3 give the output for the next 1 row in order of highest age to the lowest age. This outputs the information for Chris Traeger.

SELECT *
FROM employee_demographics
ORDER BY age DESC
LIMIT 2, 1;
# This means starting at position 2 give the output for the next 1 row in order of the highest age to the lowest age. This outputs the information for Leslie Knope.


-- Aliasing 
# This is just assigning/reassigning columns using AS. It names or renames a column.

SELECT gender, avg(age) as avg_age
FROM employee_demographics
GROUP BY gender;
# This names the avg(age) function as avg_age
 
SELECT gender, avg(age) avg_age
FROM employee_demographics
GROUP BY gender;
# Note: The 'as' is not necessarily required for aliasing

