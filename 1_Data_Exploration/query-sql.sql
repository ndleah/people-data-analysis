/*******************************
Data Exploration
********************************/


--1. Employee Table
SELECT 
  id,
  COUNT(id) AS id_count
FROM employees.employee
GROUP BY id
ORDER BY id_count DESC
LIMIT 5;

--Result:
+────────+───────────+
| id     | id_count  |
+────────+───────────+
| 10002  | 1         |
| 10003  | 1         |
| 10004  | 1         |
| 10005  | 1         |
| 10001  | 1         |
+────────+───────────+


SELECT * FROM employees.employee
LIMIT 10;

--Result:
+────────+───────────────────────────+─────────────+────────────+─────────+───────────────────────────+
| id     | birth_date                | first_name  | last_name  | gender  | hire_date                 |
+────────+───────────────────────────+─────────────+────────────+─────────+───────────────────────────+
| 10001  | 1953-09-02T00:00:00.000Z  | Georgi      | Facello    | M       | 1986-06-26T00:00:00.000Z  |
| 10002  | 1964-06-02T00:00:00.000Z  | Bezalel     | Simmel     | F       | 1985-11-21T00:00:00.000Z  |
| 10003  | 1959-12-03T00:00:00.000Z  | Parto       | Bamford    | M       | 1986-08-28T00:00:00.000Z  |
| 10004  | 1954-05-01T00:00:00.000Z  | Chirstian   | Koblick    | M       | 1986-12-01T00:00:00.000Z  |
| 10005  | 1955-01-21T00:00:00.000Z  | Kyoichi     | Maliniak   | M       | 1989-09-12T00:00:00.000Z  |
| 10006  | 1953-04-20T00:00:00.000Z  | Anneke      | Preusig    | F       | 1989-06-02T00:00:00.000Z  |
| 10007  | 1957-05-23T00:00:00.000Z  | Tzvetan     | Zielinski  | F       | 1989-02-10T00:00:00.000Z  |
| 10008  | 1958-02-19T00:00:00.000Z  | Saniya      | Kalloufi   | M       | 1994-09-15T00:00:00.000Z  |
| 10009  | 1952-04-19T00:00:00.000Z  | Sumant      | Peac       | F       | 1985-02-18T00:00:00.000Z  |
| 10010  | 1963-06-01T00:00:00.000Z  | Duangkaew   | Piveteau   | F       | 1989-08-24T00:00:00.000Z  |
+────────+───────────────────────────+─────────────+────────────+─────────+───────────────────────────+


--2. Title Table
SELECT 
  employee_id,
  COUNT(employee_id) AS id_count
FROM employees.title
GROUP BY employee_id
ORDER BY id_count DESC
LIMIT 5;

--Result:
+──────────────+───────────+
| employee_id  | id_count  |
+──────────────+───────────+
| 10451        | 3         |
| 10009        | 3         |
| 10066        | 3         |
| 10258        | 3         |
| 10571        | 3         |
+──────────────+───────────+


SELECT * FROM employees.title
WHERE employee_id = 10005
ORDER BY  from_date;

--Result:
+──────────────+───────────────+───────────────────────────+───────────────────────────+
| employee_id  | title         | from_date                 | to_date                   |
+──────────────+───────────────+───────────────────────────+───────────────────────────+
| 10005        | Staff         | 1989-09-12T00:00:00.000Z  | 1996-09-12T00:00:00.000Z  |
| 10005        | Senior Staff  | 1996-09-12T00:00:00.000Z  | 9999-01-01T00:00:00.000Z  |
+──────────────+───────────────+───────────────────────────+───────────────────────────+


--3. Salary Table
SELECT 
  employee_id,
  COUNT(employee_id) AS id_count
FROM employees.salary
GROUP BY employee_id
ORDER BY id_count DESC
LIMIT 5;

--Result:
+──────────────+───────────+
| employee_id  | id_count  |
+──────────────+───────────+
| 10258        | 18        |
| 10277        | 18        |
| 10137        | 18        |
| 10009        | 18        |
| 10372        | 18        |
+──────────────+───────────+


SELECT * FROM employees.salary
WHERE employee_id = 10005;

--Result:
+──────────────+─────────+───────────────────────────+───────────────────────────+
| employee_id  | amount  | from_date                 | to_date                   |
+──────────────+─────────+───────────────────────────+───────────────────────────+
| 10005        | 78228   | 1989-09-12T00:00:00.000Z  | 1990-09-12T00:00:00.000Z  |
| 10005        | 82621   | 1990-09-12T00:00:00.000Z  | 1991-09-12T00:00:00.000Z  |
| 10005        | 83735   | 1991-09-12T00:00:00.000Z  | 1992-09-11T00:00:00.000Z  |
| 10005        | 85572   | 1992-09-11T00:00:00.000Z  | 1993-09-11T00:00:00.000Z  |
| 10005        | 85076   | 1993-09-11T00:00:00.000Z  | 1994-09-11T00:00:00.000Z  |
| 10005        | 86050   | 1994-09-11T00:00:00.000Z  | 1995-09-11T00:00:00.000Z  |
| 10005        | 88448   | 1995-09-11T00:00:00.000Z  | 1996-09-10T00:00:00.000Z  |
| 10005        | 88063   | 1996-09-10T00:00:00.000Z  | 1997-09-10T00:00:00.000Z  |
| 10005        | 89724   | 1997-09-10T00:00:00.000Z  | 1998-09-10T00:00:00.000Z  |
| 10005        | 90392   | 1998-09-10T00:00:00.000Z  | 1999-09-10T00:00:00.000Z  |
| 10005        | 90531   | 1999-09-10T00:00:00.000Z  | 2000-09-09T00:00:00.000Z  |
| 10005        | 91453   | 2000-09-09T00:00:00.000Z  | 2001-09-09T00:00:00.000Z  |
| 10005        | 94692   | 2001-09-09T00:00:00.000Z  | 9999-01-01T00:00:00.000Z  |
+──────────────+─────────+───────────────────────────+───────────────────────────+


--4. department_employee table
SELECT
  employee_id,
  COUNT(DISTINCT department_id) AS unique_departments
FROM employees.department_employee
GROUP BY employee_id
ORDER BY unique_departments DESC
LIMIT 5;

--Result:
+──────────────+─────────────────────+
| employee_id  | unique_departments  |
+──────────────+─────────────────────+
| 10029        | 2                   |
| 10040        | 2                   |
| 10010        | 2                   |
| 10018        | 2                   |
| 10050        | 2                   |
+──────────────+─────────────────────+

SELECT * FROM employees.department_employee
WHERE employee_id = 10029
LIMIT 5;

--Result:
+──────────────+────────────────+───────────────────────────+───────────────────────────+
| employee_id  | department_id  | from_date                 | to_date                   |
+──────────────+────────────────+───────────────────────────+───────────────────────────+
| 10029        | d004           | 1991-09-18T00:00:00.000Z  | 1999-07-08T00:00:00.000Z  |
| 10029        | d006           | 1999-07-08T00:00:00.000Z  | 9999-01-01T00:00:00.000Z  |
+──────────────+────────────────+───────────────────────────+───────────────────────────+


--5. department_manager table

SELECT * FROM employees.department_manager
ORDER BY employee_id
LIMIT 5;

--Result:
+──────────────+────────────────+───────────────────────────+───────────────────────────+
| employee_id  | department_id  | from_date                 | to_date                   |
+──────────────+────────────────+───────────────────────────+───────────────────────────+
| 110022       | d001           | 1985-01-01T00:00:00.000Z  | 1991-10-01T00:00:00.000Z  |
| 110039       | d001           | 1991-10-01T00:00:00.000Z  | 9999-01-01T00:00:00.000Z  |
| 110085       | d002           | 1985-01-01T00:00:00.000Z  | 1989-12-17T00:00:00.000Z  |
| 110114       | d002           | 1989-12-17T00:00:00.000Z  | 9999-01-01T00:00:00.000Z  |
| 110183       | d003           | 1985-01-01T00:00:00.000Z  | 1992-03-21T00:00:00.000Z  |
+──────────────+────────────────+───────────────────────────+───────────────────────────+


SELECT *
FROM employees.department_manager
WHERE department_id = 'd004'
ORDER BY from_date;

--Result:
+──────────────+────────────────+───────────────────────────+───────────────────────────+
| employee_id  | department_id  | from_date                 | to_date                   |
+──────────────+────────────────+───────────────────────────+───────────────────────────+
| 110303       | d004           | 1985-01-01T00:00:00.000Z  | 1988-09-09T00:00:00.000Z  |
| 110344       | d004           | 1988-09-09T00:00:00.000Z  | 1992-08-02T00:00:00.000Z  |
| 110386       | d004           | 1992-08-02T00:00:00.000Z  | 1996-08-30T00:00:00.000Z  |
| 110420       | d004           | 1996-08-30T00:00:00.000Z  | 9999-01-01T00:00:00.000Z  |
+──────────────+────────────────+───────────────────────────+───────────────────────────+


--6. Department table
SELECT *
FROM employees.department
ORDER BY id;

--Result:
+───────+─────────────────────+
| id    | dept_name           |
+───────+─────────────────────+
| d001  | Marketing           |
| d002  | Finance             |
| d003  | Human Resources     |
| d004  | Production          |
| d005  | Development         |
| d006  | Quality Management  |
| d007  | Sales               |
| d008  | Research            |
| d009  | Customer Service    |
+───────+─────────────────────+

--Update tables

DROP SCHEMA IF EXISTS mv_employees CASCADE;
CREATE SCHEMA mv_employees;

-- department
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department;
CREATE MATERIALIZED VIEW mv_employees.department AS
SELECT * FROM employees.department;


-- department employee
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department_employee;
CREATE MATERIALIZED VIEW mv_employees.department_employee AS
SELECT
  employee_id,
  department_id,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.department_employee;

-- department manager
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department_manager;
CREATE MATERIALIZED VIEW mv_employees.department_manager AS
SELECT
  employee_id,
  department_id,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.department_manager;

-- employee
DROP MATERIALIZED VIEW IF EXISTS mv_employees.employee;
CREATE MATERIALIZED VIEW mv_employees.employee AS
SELECT
  id,
  (birth_date + interval '18 years')::DATE AS birth_date,
  first_name,
  last_name,
  gender,
  (hire_date + interval '18 years')::DATE AS hire_date
FROM employees.employee;

-- salary
DROP MATERIALIZED VIEW IF EXISTS mv_employees.salary;
CREATE MATERIALIZED VIEW mv_employees.salary AS
SELECT
  employee_id,
  amount,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.salary;

-- title
DROP MATERIALIZED VIEW IF EXISTS mv_employees.title;
CREATE MATERIALIZED VIEW mv_employees.title AS
SELECT
  employee_id,
  title,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.title;

-- Index Creation
-- NOTE: we do not name the indexes as they will be given randomly upon creation!
CREATE UNIQUE INDEX ON mv_employees.employee USING btree (id);
CREATE UNIQUE INDEX ON mv_employees.department_employee USING btree (employee_id, department_id);
CREATE INDEX        ON mv_employees.department_employee USING btree (department_id);
CREATE UNIQUE INDEX ON mv_employees.department USING btree (id);
CREATE UNIQUE INDEX ON mv_employees.department USING btree (dept_name);
CREATE UNIQUE INDEX ON mv_employees.department_manager USING btree (employee_id, department_id);
CREATE INDEX        ON mv_employees.department_manager USING btree (department_id);
CREATE UNIQUE INDEX ON mv_employees.salary USING btree (employee_id, from_date);
CREATE UNIQUE INDEX ON mv_employees.title USING btree (employee_id, title, from_date);