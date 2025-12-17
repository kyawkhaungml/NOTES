-- COLUMNS BASICS
CREATE TABLE NAME
(
	-- [COLUMN_NAME] [DATA_TYPE] [CONSTRAINTS],
	Column1 INT NOT NULL PRIMARY KEY,
	Column2 DECIMAL(10,2) UNIQUE,
	Column3 FLOAT ,
	Column4 CHAR(10),
	Column5 VARCHAR(255) NOT NULL
  DEFAULT 'active'
  CHECK (Column5 in ('active', 'not active')
  ,
	Column6 TEXT,
	Column7 BOOLEAN,
	Column8 DATE,
	Column9 TIME,
	Column10 TIMESTAMP, -- date+time,
	Column11 DATETIME, -- MySQL/SQL Server
	Jason_col JSON, -- JSON(Postgres/MySQL)
	Int_array_col INT[]
  Text_array_col TEXT[]-- array of integesr / Text
  
);

-- First, a parent table so we can use a FOREIGN KEY
CREATE TABLE department (
    dept_id      SERIAL PRIMARY KEY,             -- PRIMARY KEY (auto-increment)
    dept_name    VARCHAR(100) NOT NULL UNIQUE    -- NOT NULL + UNIQUE
);

-- Main example table with many constraint types
CREATE TABLE employee (
    -- Column-level constraints
    emp_id       SERIAL PRIMARY KEY,                 -- PRIMARY KEY (NOT NULL + UNIQUE)
    first_name   VARCHAR(50) NOT NULL,               -- NOT NULL
    last_name    VARCHAR(50) NOT NULL,               -- NOT NULL
    
    email        VARCHAR(255) NOT NULL UNIQUE,       -- NOT NULL + UNIQUE

    salary       NUMERIC(10,2) 
                 CHECK (salary >= 0),                -- CHECK constraint

    hire_date    DATE NOT NULL 
                 DEFAULT CURRENT_DATE,               -- DEFAULT value

    status       VARCHAR(20) NOT NULL 
                 DEFAULT 'active'                    -- NOT NULL + DEFAULT

                 CHECK (status IN ('active', 'on_leave', 'terminated')),
    
    dept_id      INTEGER,                            -- will be a FOREIGN KEY

    -- Table-level constraints (named)
    CONSTRAINT uq_employee_name_per_dept
        UNIQUE (first_name, last_name, dept_id),     -- composite UNIQUE

    CONSTRAINT fk_employee_department
        FOREIGN KEY (dept_id)                        -- FOREIGN KEY constraint
        REFERENCES department(dept_id)
        ON UPDATE CASCADE                            -- if dept_id changes, it changes(propagates) 
        ON DELETE SET NULL                           -- what happens when dept is deleted
);

-- Try inserting valid and invalid rows to see the constraints work
INSERT INTO department (dept_name) VALUES ('Engineering');

INSERT INTO employee (first_name, last_name, email, salary, dept_id)
VALUES ('Kyle', 'Lwin', 'kyle@example.com', 80000, 1);  -- should succeed

INSERT INTO employee (first_name, last_name, email, salary, dept_id)
VALUES ('Kyle', 'Lwin', 'kyle@example.com', -5, 1);     -- should fail (negative salary)

-- IMPORTING files into the tables from local device
-- Import file1.csv into table_one (resolution, property, geographic_area)
\copy complaint_descriptor FROM '/Users/kyawkhaungmyolwin/Downloads/complaint_descriptor.csv' WITH (FORMAT CSV, HEADER true);
\copy resolution FROM '/Users/kyawkhaungmyolwin/Downloads/resolution.csv' WITH (FORMAT CSV, HEADER true);
\copy geographic_area FROM '/Users/kyawkhaungmyolwin/Downloads/geographic_area.csv' WITH (FORMAT CSV, HEADER true);
\copy sale FROM '/Users/kyawkhaungmyolwin/Downloads/sale.csv' WITH (FORMAT CSV, HEADER true);

-- CASE STATEMENT
SELECT sale_id,
       amount,
       CASE 
           WHEN amount < 100 THEN 'Low'
           WHEN amount BETWEEN 100 AND 500 THEN 'Medium'
           ELSE 'High'
       END AS sale_category
       FROM sale;

-- JOIN Operations
-- SELECT columns FROM table1
-- LEFT/RIGHT/FULL/NATURAL JOIN table2 ON table1.common_column = table2.common_column;

-- Create View for frequently accessed data
CREATE VIEW active_employees AS
SELECT emp_id, first_name, last_name, email, status
FROM employee
WHERE status = 'active';

-- Write an example of an SQL Trigger
CREATE OR REPLACE FUNCTION log_employee_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employee_audit (emp_id, changed_at, old_status, new_status)
    VALUES (NEW.emp_id, CURRENT_TIMESTAMP, OLD.status, NEW.status);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Write an example of DISTINCT usage
SELECT DISTINCT status
FROM employee;

-- Write an example of Aggregate Function usage
SELECT dept_id, AVG(salary) AS average_salary
FROM employee
GROUP BY dept_id;

-- Write an example of Subquery usage
SELECT first_name, last_name
FROM employee
WHERE dept_id = (
    SELECT dept_id
    FROM department
    WHERE dept_name = 'Engineering'
);

-- Write an example of HAVING usage
SELECT dept_id, COUNT(*) AS employee_count
FROM employee
GROUP BY dept_id
HAVING COUNT(*) > 5;

-- Write an example of Constraint usage put a value in not null salary column
ALTER TABLE employee
ADD CONSTRAINT chk_salary_positive
CHECK (salary >= 0);

-- Write an example of Assertion usage
-- Note: SQL standard assertions are not widely supported in many RDBMS.
-- However, here's a conceptual example:
CREATE ASSERTION positive_salary_assertion
CHECK (NOT EXISTS (
    SELECT *
    FROM employee
    WHERE salary < 0
));

-- Write an example of Granting Privileges
GRANT SELECT, INSERT, UPDATE ON employee TO hr_user;


-- Write an example of SQL Function (no need to put $$ on the exam)
CREATE OR REPLACE FUNCTION get_employee_full_name(emp_id INT)
RETURNS VARCHAR AS $$
DECLARE
    full_name VARCHAR;
BEGIN
    SELECT first_name || ' ' || last_name INTO full_name
    FROM employee
    WHERE employee.emp_id = get_employee_full_name.emp_id;
    RETURN full_name;
END;
$$ LANGUAGE plpgsql;

-- Write an example of Table Function
CREATE OR REPLACE FUNCTION get_employees_by_department(dept INT)
RETURNS TABLE(emp_id INT, first_name VARCHAR, last_name VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT emp_id, first_name, last_name
    FROM employee
    WHERE dept_id = dept;
END;
$$ LANGUAGE plpgsql;

 -- Write an example of Trigger Usage
CREATE TRIGGER trg_log_employee_update
AFTER UPDATE OF status ON employee
FOR EACH ROW
EXECUTE FUNCTION log_employee_update();

-- Write an example of Index Creation
CREATE INDEX idx_employee_last_name
ON employee(last_name);

-- Write an example of Object Relational Database System (ORDS)
-- Example: Creating a composite type and using it in a table
CREATE TYPE address_type AS (
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10)
);

CREATE TABLE address OF address_type;