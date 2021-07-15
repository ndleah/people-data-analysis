[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/nduongthucanh?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/nduongthucanh)

# **[SERIOUS SQL: PEOPLE ANALYTICS CASE STUDY](https://github.com/nduongthucanh/HR-Analytics-Using-SQL)**

# 📂 Data Overview - Data Exploration

## 📕 Table of contents
* 🔗 [Entity Diagram Relationship](#-entity-diagram-relationship)
* 📂 [Dataset](#-dataset) 
* 🆕 [Update Tables](#-updates-tables)
* 👣 [Next Steps](#-next-steps)

## 🔗 Entity Diagram Relationship
Before diving straight into solution mode for the business requirements, I need to take a look at the data with **EDR (Entity-Relationship Diagrams)** to identify different data relationships between tables. The EDR of these datasets can be viewed as below:

<p align="center">
<img src="https://github.com/nduongthucanh/HR-Analytics-Using-SQL/blob/main/IMG/EDR.png" width=100% height=100%>
</p>

<br /> 

## 📂 Dataset

This case study provided me with 6 key datasets:

### ⭐ **```Employee Table```**

With the **```employee```** table, we can see that there is a unique row of personal information for each employee in our database and there is primary key on the **```id```** column. 

Moreover, there is the issue with the dates where the year was wrongly input 18 years behind what it should be. 

```sql
SELECT * FROM employees.employee
LIMIT 10;
```

**Result:**
|id   |birth_date|first_name|last_name|gender|hire_date               |
|-----|----------|----------|---------|------|------------------------|
|10001|1953-09-02T00:00:00.000Z|Georgi    |Facello  |M     |1986-06-26T00:00:00.000Z|
|10002|1964-06-02T00:00:00.000Z|Bezalel   |Simmel   |F     |1985-11-21T00:00:00.000Z|
|10003|1959-12-03T00:00:00.000Z|Parto     |Bamford  |M     |1986-08-28T00:00:00.000Z|
|10004|1954-05-01T00:00:00.000Z|Chirstian |Koblick  |M     |1986-12-01T00:00:00.000Z|
|10005|1955-01-21T00:00:00.000Z|Kyoichi   |Maliniak |M     |1989-09-12T00:00:00.000Z|
|10006|1953-04-20T00:00:00.000Z|Anneke    |Preusig  |F     |1989-06-02T00:00:00.000Z|
|10007|1957-05-23T00:00:00.000Z|Tzvetan   |Zielinski|F     |1989-02-10T00:00:00.000Z|
|10008|1958-02-19T00:00:00.000Z|Saniya    |Kalloufi |M     |1994-09-15T00:00:00.000Z|
|10009|1952-04-19T00:00:00.000Z|Sumant    |Peac     |F     |1985-02-18T00:00:00.000Z|
|10010|1963-06-01T00:00:00.000Z|Duangkaew |Piveteau |F     |1989-08-24T00:00:00.000Z|

---

### ⭐ **```Title```**

Our second table is the **```employees.title```** table which contains the **```employee_id```** which we can join back to our **```employees.employee```** table.

``` sql
SELECT 
  employee_id,
  COUNT(employee_id) AS id_count
FROM employees.title
GROUP BY employee_id
ORDER BY id_count DESC
LIMIT 5;
```

**Result:**
|employee_id|id_count|
|-----------|--------|
|10451      |3       |
|10009      |3       |
|10066      |3       |
|10258      |3       |
|10571      |3       |

After inspecting the data - we notice that there is in fact a **many-to-one relationship** between the **```employees.title```** and **```employees.employee```** tables.


```sql
SELECT * FROM employees.title
WHERE employee_id = 10005
ORDER BY  from_date;
```

**Result:**
|employee_id|title|from_date               |to_date                 |
|-----------|-----|------------------------|------------------------|
|10005      |Staff|1989-09-12T00:00:00.000Z|1996-09-12T00:00:00.000Z|
|10005      |Senior Staff|1996-09-12T00:00:00.000Z|9999-01-01T00:00:00.000Z|

For our example, **```employee_id```** = 10005 Kyoichi Maliniak’s title was originally “Staff” from **```1989-09-12```** to **```1996-09-12```** when he was then promoted to “Senior Staff” which is his current position until the “arbitrary” end date of **```9999-01-01```** in our dataset.

Also, there is the issue with the dates where the year was wrongly input which is similar with the **```employee```** table above.

---

### ⭐ **```Salary```**
```sql
SELECT 
  employee_id,
  COUNT(employee_id) AS id_count
FROM employees.salary
GROUP BY employee_id
ORDER BY id_count DESC
LIMIT 5;
```

**Result:**
|employee_id|id_count|
|-----------|--------|
|10258      |18      |
|10277      |18      |
|10137      |18      |
|10009      |18      |
|10372      |18      |

The third table is the all-important employees.salary table - it also has a similar relationship with the unique **```employees.employee```** table in that there are **many-to-one** or **one-to-many records** for each employee and their salary amounts over time.

Let’s also continue to check **```employee_id```** 10005’s records for this table ordered by the from_date ascending from earliest to latest to checkout his salary growth over the years with the company:
```sql
SELECT * FROM employees.salary
WHERE employee_id = 10005;
```

**Result:**
|employee_id|amount|from_date               |to_date                 |
|-----------|------|------------------------|------------------------|
|10005      |78228 |1989-09-12T00:00:00.000Z|1990-09-12T00:00:00.000Z|
|10005      |82621 |1990-09-12T00:00:00.000Z|1991-09-12T00:00:00.000Z|
|10005      |83735 |1991-09-12T00:00:00.000Z|1992-09-11T00:00:00.000Z|
|10005      |85572 |1992-09-11T00:00:00.000Z|1993-09-11T00:00:00.000Z|
|10005      |85076 |1993-09-11T00:00:00.000Z|1994-09-11T00:00:00.000Z|
|10005      |86050 |1994-09-11T00:00:00.000Z|1995-09-11T00:00:00.000Z|
|10005      |88448 |1995-09-11T00:00:00.000Z|1996-09-10T00:00:00.000Z|
|10005      |88063 |1996-09-10T00:00:00.000Z|1997-09-10T00:00:00.000Z|
|10005      |89724 |1997-09-10T00:00:00.000Z|1998-09-10T00:00:00.000Z|
|10005      |90392 |1998-09-10T00:00:00.000Z|1999-09-10T00:00:00.000Z|
|10005      |90531 |1999-09-10T00:00:00.000Z|2000-09-09T00:00:00.000Z|
|10005      |91453 |2000-09-09T00:00:00.000Z|2001-09-09T00:00:00.000Z|
|10005      |94692 |2001-09-09T00:00:00.000Z|9999-01-01T00:00:00.000Z|

We found out that the same **```from_date```** and **```to_date```** columns exist in this table, along with it’s arbitrary end date of **```9999-01-01```** which we will need to deal with later.

---

### ⭐ **```department_employee```**

We now take a look at the **```employees.department_employee```** table which captures information for which department each employee belongs to throughout their career with our company.

```sql
SELECT
  employee_id,
  COUNT(DISTINCT department_id) AS unique_departments
FROM employees.department_employee
GROUP BY employee_id
ORDER BY unique_departments DESC
LIMIT 5;
```

**Result:**
|employee_id|unique_departments|
|-----------|------------------|
|10029      |2                 |
|10040      |2                 |
|10010      |2                 |
|10018      |2                 |
|10050      |2                 |

In the same vain as the previous tables - we have the same slow changing dimension (SCD) style data design with a **many-to-one relationship** with the base **```employees.employee```** table

```sql
SELECT * FROM employees.department_employee
WHERE employee_id = 10029
LIMIT 5;
```

**Result:**
|employee_id|department_id|from_date               |to_date                 |
|-----------|-------------|------------------------|------------------------|
|10029      |d004         |1991-09-18T00:00:00.000Z|1999-07-08T00:00:00.000Z|
|10029      |d006         |1999-07-08T00:00:00.000Z|9999-01-01T00:00:00.000Z|

We can see that they’ve changed departments from **```d004```** to **```d006```** in **```1999-07-08```** (well, we’ll add 18 years to this date later!)

This **```department_id```** value is all good and well though - but wouldn’t it be more useful if we were to actually use the department name…

---

### ⭐ **```department_manager```**

Before we cover the actual department name - let’s also take a look at the department manager too, this time still with the random looking **```department_id```** values!

```sql
SELECT * FROM employees.department_manager
ORDER BY employee_id
LIMIT 5;
```

**Result:**
|employee_id|department_id|from_date               |to_date                 |
|-----------|-------------|------------------------|------------------------|
|110022     |d001         |1985-01-01T00:00:00.000Z|1991-10-01T00:00:00.000Z|
|110039     |d001         |1991-10-01T00:00:00.000Z|9999-01-01T00:00:00.000Z|
|110085     |d002         |1985-01-01T00:00:00.000Z|1989-12-17T00:00:00.000Z|
|110114     |d002         |1989-12-17T00:00:00.000Z|9999-01-01T00:00:00.000Z|
|110183     |d003         |1985-01-01T00:00:00.000Z|1992-03-21T00:00:00.000Z|

In the same way that the **```employees.department_employee```** table shows the relationship between employees and their respective departments throughout time - the employees.**```department_manager```** table shows the **```employee_id```** of the manager of each department throughout time.

To inspect this dataset - how about we take a look at that **```department_id```** = 'd004' record:

```sql
SELECT *
FROM employees.department_manager
WHERE department_id = 'd004'
ORDER BY from_date;
```

**Result:**
|employee_id|department_id|from_date               |to_date                 |
|-----------|-------------|------------------------|------------------------|
|110303     |d004         |1985-01-01T00:00:00.000Z|1988-09-09T00:00:00.000Z|
|110344     |d004         |1988-09-09T00:00:00.000Z|1992-08-02T00:00:00.000Z|
|110386     |d004         |1992-08-02T00:00:00.000Z|1996-08-30T00:00:00.000Z|
|110420     |d004         |1996-08-30T00:00:00.000Z|9999-01-01T00:00:00.000Z|

As transparent from the table, we know the current and previous managers of **```department_id```** d004 - well at least we know their **```employee_id```**, we’ll need to join back onto the **```employees.employee```** table to grab out more of their personal details.

---

### ⭐ **```Department table```**

The **```employees.department```** table is just like the employees.employee table where there is a 1:1 unique relationship between the id or department_id and the **```dept_name```**.

```sql
SELECT *
FROM employees.department
ORDER BY id;
```
**Result:**
|id   |dept_name|
|-----|---------|
|d001 |Marketing|
|d002 |Finance  |
|d003 |Human Resources|
|d004 |Production|
|d005 |Development|
|d006 |Quality Management|
|d007 |Sales    |
|d008 |Research |
|d009 |Customer Service|

---

## 🆕 Updates Tables

For views which might be accessed multiple times frequently - it makes a lot of sense to create a materialized view as there is only a single ```REFRESH MATERIALIZED VIEW``` statement to pull in the new data if there are any changes in the upstream source data.

Additionally - I will create indexes on materialized views which will also get updated whenever we refresh the materialized view. 

```sql
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
```
---

## 👣 Next Steps

This completes the quick data exploration of all the tables we will be using for this case study!

In the next tutorial we will start tackling our problem - first we will remedy our data entry mistake and explore how we can create some reusable data assets to store this case study’s results to scale out our solution.

___________________________________

<p>&copy; 2021 Leah Nguyen</p>