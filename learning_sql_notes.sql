-- COLUMNS BASICS
CREATE TABLE NAME
(
	-- [COLUMN_NAME] [DATA_TYPE] [CONSTRAINTS],
	Column1 INT NOT NULL,
  PRIMARY KEY (Column1),
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

