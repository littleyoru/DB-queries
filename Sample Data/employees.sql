DROP DATABASE IF EXISTS employees;
IF DB_ID('employees') IS NULL CREATE DATABASE employees;
USE employees;

SELECT 'CREATING DATABASE STRUCTURE' as 'INFO';

DROP TABLE IF EXISTS dept_emp,
                     dept_manager,
                     titles,
                     salaries, 
                     employees, 
                     departments;


CREATE TABLE employees (
    emp_no      INT             PRIMARY KEY,
    birth_date  DATE            NOT NULL,
    first_name  VARCHAR(14)     NOT NULL,
    last_name   VARCHAR(16)     NOT NULL,
    gender      VARCHAR(1)      NOT NULL CHECK (gender IN ('M','F')),    
    hire_date   DATE            NOT NULL
);

CREATE TABLE departments (
    dept_no     CHAR(4)         PRIMARY KEY,
    dept_name   VARCHAR(40)     NOT NULL UNIQUE
);

CREATE TABLE dept_manager (
   emp_no       INT             NOT NULL FOREIGN KEY REFERENCES employees (emp_no) ON DELETE CASCADE,
   dept_no      CHAR(4)         NOT NULL FOREIGN KEY REFERENCES departments (dept_no) ON DELETE CASCADE,
   from_date    DATE            NOT NULL,
   to_date      DATE            NOT NULL,
   CONSTRAINT PK_DEPT_M PRIMARY KEY (emp_no,dept_no)
); 

CREATE TABLE dept_emp (
    emp_no      INT             NOT NULL FOREIGN KEY REFERENCES employees (emp_no) ON DELETE CASCADE,
    dept_no     CHAR(4)         NOT NULL FOREIGN KEY REFERENCES departments (dept_no) ON DELETE CASCADE,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    CONSTRAINT PK_DEPT_E PRIMARY KEY (emp_no,dept_no)
);

CREATE TABLE titles (
    emp_no      INT             NOT NULL FOREIGN KEY REFERENCES employees (emp_no) ON DELETE CASCADE,
    title       VARCHAR(50)     NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE,
    CONSTRAINT PK_TITLES PRIMARY KEY (emp_no,title, from_date)
); 

CREATE TABLE salaries (
    emp_no      INT             NOT NULL FOREIGN KEY REFERENCES employees (emp_no) ON DELETE CASCADE,
    salary      INT             NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    CONSTRAINT PK_SAL PRIMARY KEY (emp_no, from_date)
); 

--CREATE OR ALTER VIEW dept_emp_latest_date AS
--    SELECT emp_no, MAX(from_date) AS from_date, MAX(to_date) AS to_date
--    FROM dept_emp
--    GROUP BY emp_no;

-- sql server equivalent:
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[dept_emp_latest_date]'))
	EXEC sp_executesql N'CREATE VIEW [dbo].[dept_emp_latest_date] AS SELECT ''ALTER VIEW [dbo].[dept_emp_latest_date] AS
	SELECT'' emp_no, MAX(from_date) AS from_date, MAX(to_date) AS to_date
    FROM dept_emp
    GROUP BY emp_no';


-- shows only the current department for each employee

--CREATE OR REPLACE VIEW current_dept_emp AS
--    SELECT l.emp_no, dept_no, l.from_date, l.to_date
--    FROM dept_emp d
--        INNER JOIN dept_emp_latest_date l
--        ON d.emp_no=l.emp_no AND d.from_date=l.from_date AND l.to_date = d.to_date;


-- sql server equivalent:
IF EXISTS (SELECT * FROM sys.views WHERE name = 'current_dept_emp')
DROP VIEW current_dept_emp;
GO
CREATE VIEW current_dept_emp AS 
	SELECT l.emp_no, dept_no, l.from_date, l.to_date
    FROM dept_emp d
        INNER JOIN dept_emp_latest_date l
        ON d.emp_no=l.emp_no AND d.from_date=l.from_date AND l.to_date = d.to_date;
