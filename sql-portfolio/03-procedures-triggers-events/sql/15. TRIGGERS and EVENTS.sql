-- Triggers and Events
# Trigger is a block of code that executes automatically when an event takes place on a specific table


SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

# we are going to write a trigger so that when new data is updated in the salary table, the demographics table also gets updated

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW. last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'Jean-Raphio', 'Sapaerstein', 'Entertainment 720 CEO', 1000000, NULL);


-- EVENTS
# An event takes place when it is scheduled, somewhat like a scheduled automator

SELECT *
FROM employee_demographics;

DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
	DELETE
    FROM employee_demographics
    WHERE age >= 60
;
END $$
DELIMITER ;
# The event delete_retirees clear the row data of employees aged 60 and above from the demographics table every 30 seconds
# A practical application of this query is in cases where there remains employee data of retired persons in the db
# An event like this can be created to delete such data if it is no longer needed

SHOW VARIABLES LIKE 'event%';
# This shows the status of the event_scheduler, whether it is on or off
