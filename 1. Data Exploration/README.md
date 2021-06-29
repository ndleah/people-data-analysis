[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/nduongthucanh?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/nduongthucanh)

# **[SERIOUS SQL: PEOPLE ANALYTICS CASE STUDY](https://github.com/nduongthucanh/HR-Analytics-Using-SQL)**

# Data Overview - Data Exploration

<p align="center">
<img src="https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/IMG/data-exploration.gif" width=60% height=60%>
</p>

## Table of contents
<!--ts-->


---
## Entity Diagram Relationship
Before diving straight into solution mode for the business requirements, I need to take a look at the data with **EDR (Entity-Relationship Diagrams)** to identify different data relationships between tables. The EDR of these datasets can be viewed as below:

<p align="center">
<img src="https://github.com/nduongthucanh/HR-Analytics-Using-SQL/blob/main/IMG/EDR.png" width=100% height=100%>
</p>

<br /> 

## Dataset

This case study provided me with 6 key datasets:

* ### **```Employee Table```**
```sql
SELECT 
  id,
  COUNT(id) AS id_count
FROM employees.employee
GROUP BY id
ORDER BY id_count DESC
LIMIT 5;
```

**Result:**
|id   |id_count|
|-----|--------|
|10002|1       |
|10003|1       |
|10004|1       |
|10005|1       |
|10001|1       |


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

* ### **```Title```**
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

---

* ### **```Salary```**
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

---

* ### **```department_employee```**
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

---

* ### **```department_manager```**
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

---

* ### **```Department table```**
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

## Next Steps

### *Thanks for reading and scrolling down until this point. I truly aprreciated your patience!* :heart:

<br /> 

### **In the second stage of this project, I will perfom some table joins for retrieving and transform data into meaning insights for our email marketing campaign.**

<br /> 

View The Next Part: [![View Data Join Folder](https://img.shields.io/badge/View-Data_Join_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/2.-Data-Join)

View The 3rd Part: [![View Problem Solving Folder](https://img.shields.io/badge/View-Problem_Solving_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis/blob/main/3.-Problem-Solving)

Come back to main folder: [![View Main Folder](https://img.shields.io/badge/View-Main_Folder-red?)](https://github.com/nduongthucanh/DVD-Rental-Co-Email-Marketing-Analysis)

___________________________________

<p>&copy; 2021 Leah Nguyen</p>