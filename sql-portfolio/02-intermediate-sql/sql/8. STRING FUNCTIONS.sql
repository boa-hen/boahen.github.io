-- String Functions

SELECT length('skyfall');

SELECT first_name, length(first_name)
FROM employee_demographics
ORDER BY length(first_name);
# example where length makes sense when used is when the data contains phone numbers

SELECT upper('sky');
SELECT lower('SKY');

SELECT first_name, upper(first_name)
FROM employee_demographics;

SELECT trim('    sky     ');
# Trim gets rid of leading and trailing spaces

SELECT ltrim('        sky     ');
# Left trim gets rid of spaces from the left hand side

SELECT rtrim('    sky         ');
# Right trim gets rid of spaces from the right hand side

SELECT first_name,
LEFT(first_name, 4),
RIGHT(first_name, 4),
substring(first_name, 3, 2)
FROM employee_demographics
;
# The Substring query substring(first_name, 3, 2) means starting at the 3rd position in the first name output 2 characters
