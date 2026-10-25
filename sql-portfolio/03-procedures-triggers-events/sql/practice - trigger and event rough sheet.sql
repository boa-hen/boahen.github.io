# trial to check understanding of triggers
# create a trigger so that when new data is added in the employee salary table it will also be updated in the demographics table
# column information needed are employee id, first name, last name, salary and occupation
# Note: adding the columns salary and occupation and passing them into the demographics table caused an error in our trigger code
# this is because we wanted to pass values into columns that do not exist in the demographics table from the newly inserted information in the salary table
# understand that the columns mentioned in this line of code in the trigger 'INSERT INTO employee_demographics (employee_id, first_name, last_name)' are the columns we want the new data to be inserted into in the demographics table
# therefore they must correspond to already existing columns in the demographics table
# our mistake in wanting to pass values from the salary and occupation columns into the demographics table gives 'Error Code 1136: Column count doesn't match value count at row 1'
# we were able to arrive at 2 solutions to this issue. the first one is to only include columns that we know are present in both demographics and salary tables and whose values we want updated at all times
# or to mention all the columns of the demographics table and match the columns whose values we are not interested in to null
# so either we do 'INSERT INTO employee_demographics (employee_id, first_name, last_name)' and follow up
# with 'VALUES (NEW.employee_id, NEW.first_name, NEW.last_name)'
# or we do 'INSERT INTO employee_demographics (employee_id, first_name, last_name,age, gender, birth_date)' and then
# we follow up with 'VALUES (NEW.employee_id, NEW.first_name, NEW.last_name, NULL, NULL, NULL)'

SELECT *
FROM employee_salary;

SELECT *
FROM employee_demographics;

DESCRIBE employee_salary;

DROP TRIGGER IF EXISTS new_trigger;
DROP TRIGGER IF EXISTS employee_insert;

DELIMITER $$
CREATE TRIGGER employee_insert
AFTER INSERT ON employee_salary
FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (15, 'Alex', 'Rivera', 'Data Analyst', 85000, 6);

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (14, 'Sam', 'Carter', 'Advisor', 80000, NULL);

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (19, 'Jordan', 'Lee', 'Junior Auditor', 60000, 6);

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (16, 'Taylor', 'Brooks', 'Junior Auditor', 60000, 6);

SELECT * FROM employee_demographics WHERE employee_id IN (14, 19);

SHOW TRIGGERS FROM parks_and_recreation;

# NOTE: The DROP command is used to delete or clear a function from the db
# DROP TRIGGER — permanently deletes the trigger from your database. It's gone completely, not just from memory but from the database itself.
# DROP TRIGGER IF EXISTS — does the same thing but only if the trigger exists, preventing an error if it doesn't.

## events
# Lets say we want something that will help us single out employees who are of retirement age (aged 60+)
# so that we can retire them and clear their data from the system
# we can create an event that will check and identify such employees as well as delete their data from the table

DELIMITER $$
CREATE EVENT remove_retirees
ON SCHEDULE EVERY 10 SECOND
DO
BEGIN
	select *
    FROM employee_demographics
    WHERE age >= 60;
END $$
DELIMITER ;

SELECT *
FROM employee_demographics;

DROP EVENT IF EXISTS remove_retirees;
# deletes the event from the db

SHOW EVENTS FROM parks_and_recreation;
# this shows all active events in the db

SHOW VARIABLES LIKE 'log_bin';
# this helped to identify whether binary logging was enabled

show variables like 'event%';
# this shows whether event scheduler is enabled

# recovering deleted data using binary logs
SHOW binary logs;
SHOW VARIABLES LIKE 'log_bin_basename';
SHOW BINLOG EVENTS IN 'YOUR-PC-bin.000003';
# the deleted event is in the bin.000003 log however scrolling through manually to find it was difficult so I opened cmd in windows
# it turns out that the event was logged in binary format and not plain text
# so I used cmd to export all binary logs to a readable text file, then I searched the file for the DELETE event
# After which I proceeded to insert the deleted data back into the demographics table

INSERT INTO employee_demographics (employee_id, first_name, last_name, age, gender, birth_date)
VALUES (5, 'Jerry', 'Gergich', 61, 'Male', '1962-08-28');

SELECT *
FROM employee_demographics
WHERE employee_id = 5;
