USE employees;

CREATE VIEW old_employees AS
SELECT
first_name AS Fornavn,
last_name AS Efternavn
FROM employees
WHERE YEAR(hire_date) < 1990
ORDER BY Fornavn, Efternavn
OFFSET 0 ROWS;

SELECT * FROM old_employees;

SELECT * FROM old_employees
WHERE Fornavn LIKE 'C%'
ORDER BY Efternavn;



USE employees
GO
CREATE PROCEDURE insert_dummy @empno INT
AS
INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date)
VALUES (@empno, '1970-01-01', 'foo', 'bar', 'M', GETDATE())
GO


USE employees
EXEC insert_dummy 12345;


SELECT * FROM employees



-- Udfordringer


-- show underpaid employees
-- stored procedure that created the view

CREATE PROCEDURE underpaid_employees
AS
GO
	CREATE VIEW underpaid_employees_view AS
		SELECT 
			e.first_name as Fornavn,
			e.last_name as Efternavn,
			s.salary as Løn
		FROM employees e 
			INNER JOIN salaries s ON e.emp_no = s.emp_no
		WHERE s.salary < 45001
		ORDER BY Fornavn, Efternavn
			OFFSET 0 ROWS
GO


EXEC underpaid_employees;

SELECT * FROM underpaid_employees_view


-- show employees from @dept_name with salary >= @salary
-- version 1: params not in scope
CREATE PROCEDURE overview (@dep_name NVARCHAR, @salary INT)
AS
GO
	CREATE VIEW overview_emp AS
		SELECT 
			e.first_name AS Fornavn,
			e.last_name AS Efternavn
		FROM employees e 
		INNER JOIN dept_emp de ON e.emp_no = de.emp_no
		INNER JOIN  departments d ON de.dept_no = d.dept_no
		INNER JOIN salaries s ON e.emp_no = s.emp_no
		WHERE d.dept_name = @dep_name AND s.salary >= @salary
GO

EXEC overview 'Sales', 60000

SELECT * FROM overview_emp

--version 2:
CREATE PROCEDURE overview_2 @dep_name NVARCHAR(MAX), @salary INT
AS
	SELECT DISTINCT
		e.first_name AS Fornavn,
		e.last_name AS Efternavn
	FROM employees e 
	INNER JOIN salaries s ON e.emp_no = s.emp_no
	INNER JOIN dept_emp de ON e.emp_no = de.emp_no
	INNER JOIN  departments d ON de.dept_no = d.dept_no
	WHERE d.dept_name = @dep_name AND s.salary >= @salary
GO

EXEC overview_2 'Production', 60000

