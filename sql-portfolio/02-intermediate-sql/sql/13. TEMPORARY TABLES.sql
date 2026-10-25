-- Temporary Tables
# Temp Tables are only visible to the session that they are created in. This means that if you close the current session and then you come back and open a new session, the temp table does not work.

CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
last_name varchar(50),
favourite_movie varchar(100)
);

SELECT *
FROM temp_table;

INSERT INTO temp_table
VALUES('Alex','Freborg','Lord of the Rings: The Two Towers');

SELECT *
FROM temp_table;

SELECT *
FROM employee_salary;

# Creating temp_table using values from an existing table

CREATE TEMPORARY TABLE salary_over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT *
FROM salary_over_50k;

/* Benefits of Temp Table over CTEs
Temp tables work even in a new window whereas CTEs do not work even in a new query.


SUMMARY FOR USE OF SUBQUERY, CTEs and TEMPORARY TABLES
Use a subquery for simple, short nested logic
Use a CTE when readability matters or you need to reference the result more than once in the same query
Use a temp table when you're doing multi-step analysis or working with large datasets you'll query repeatedly
*/

