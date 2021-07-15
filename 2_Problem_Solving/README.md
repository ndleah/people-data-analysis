[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/nduongthucanh?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/nduongthucanh)

# **[SERIOUS SQL: PEOPLE ANALYTICS CASE STUDY](https://github.com/nduongthucanh/HR-Analytics-Using-SQL)**

# Problem Solving

## 📕 Table of contents
* ✅ [Solution](#solution)
* 💯 [Result](#result)
    * ⭐ [Department Level Results](#-department-level-results) 
    * ⭐ [Salary Benchmark Results](#-salary-benchmark-results)
    * ⭐ [Historic Employee Deep Dive Example](#-historic-employee-deep-dive-example) 

## ✅ Solution

This is the final script for the problem solution of this case study:
```sql
/*-----------------------------------
Current employee snapshot view
-------------------------------------*/

DROP VIEW IF EXISTS mv_employees.current_employee_snapshot;
CREATE VIEW mv_employees.current_employee_snapshot AS
WITH cte_previous_salary AS (
  SELECT * FROM (
    SELECT
      employee_id,
      to_date,
      LAG(amount) OVER (
        PARTITION BY employee_id
        ORDER BY from_date
      ) AS amount
    FROM mv_employees.salary
  ) all_salaries
  WHERE to_date = '9999-01-01'
),
cte_joined_data AS (
  SELECT
    employee.id AS employee_id,
    CONCAT_WS(' ', employee.first_name, employee.last_name) AS employee_name,
    employee.gender,
    employee.hire_date,
    title.title,
    salary.amount AS salary,
    cte_previous_salary.amount AS previous_salary,
    department.dept_name AS department,
    CONCAT_WS(' ', manager.first_name, manager.last_name) AS manager,
    title.from_date AS title_from_date,
    department_employee.from_date AS department_from_date
  FROM mv_employees.employee
  INNER JOIN mv_employees.title
    ON employee.id = title.employee_id
  INNER JOIN mv_employees.salary
    ON employee.id = salary.employee_id
  INNER JOIN cte_previous_salary
    ON employee.id = cte_previous_salary.employee_id
  INNER JOIN mv_employees.department_employee
    ON employee.id = department_employee.employee_id
  INNER JOIN mv_employees.department
    ON department_employee.department_id = department.id
  INNER JOIN mv_employees.department_manager
    ON department.id = department_manager.department_id
  INNER JOIN mv_employees.employee AS manager
    ON department_manager.employee_id = manager.id
  WHERE salary.to_date = '9999-01-01'
    AND title.to_date = '9999-01-01'
    AND department_employee.to_date = '9999-01-01'
    AND department_manager.to_date = '9999-01-01'
)
SELECT
  employee_id,
  employee_name,
  manager,
  gender,
  title,
  salary,
  department,
  -- salary change percentage
  ROUND(
    100 * (salary - previous_salary) / previous_salary::NUMERIC,
    2
  ) AS salary_percentage_change,
  -- tenure calculations
  DATE_PART('year', now()) -
    DATE_PART('year', hire_date) AS company_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', title_from_date) AS title_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', department_from_date) AS department_tenure_years
FROM cte_joined_data;


/*---------------------------
Aggregated dashboard views
-----------------------------*/

-- company level aggregation view
DROP VIEW IF EXISTS mv_employees.company_level_dashboard;
CREATE VIEW mv_employees.company_level_dashboard AS
SELECT
  gender,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER ()) AS employee_percentage,
  ROUND(AVG(company_tenure_years)) AS company_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY gender;

-- department level aggregation view
DROP VIEW IF EXISTS mv_employees.department_level_dashboard;
CREATE VIEW mv_employees.department_level_dashboard AS
SELECT
  gender,
  department,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY department
  )) AS employee_percentage,
  ROUND(AVG(department_tenure_years)) AS department_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, department;

-- title level aggregation view
DROP VIEW IF EXISTS mv_employees.title_level_dashboard;
CREATE VIEW mv_employees.title_level_dashboard AS
SELECT
  gender,
  title,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY title
  )) AS employee_percentage,
  ROUND(AVG(title_tenure_years)) AS title_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, title;

/*-----------------------
Salary Benchmark Views
-------------------------*/

DROP VIEW IF EXISTS mv_employees.tenure_benchmark;
CREATE VIEW mv_employees.tenure_benchmark AS
SELECT
  company_tenure_years,
  AVG(salary) AS tenure_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY company_tenure_years;

DROP VIEW IF EXISTS mv_employees.gender_benchmark;
CREATE VIEW mv_employees.gender_benchmark AS
SELECT
  gender,
  AVG(salary) AS gender_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY gender;

DROP VIEW IF EXISTS mv_employees.department_benchmark;
CREATE VIEW mv_employees.department_benchmark AS
SELECT
  department,
  AVG(salary) AS department_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY department;

DROP VIEW IF EXISTS mv_employees.title_benchmark;
CREATE VIEW mv_employees.title_benchmark AS
SELECT
  title,
  AVG(salary) AS title_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY title;


/*----------------------------------
1. Historic Employee Deep Dive View
-----------------------------------*/

DROP VIEW IF EXISTS mv_employees.historic_employee_records CASCADE;
CREATE VIEW mv_employees.historic_employee_records AS
WITH cte_previous_salary AS (
  SELECT
    employee_id,
    amount
  FROM (
    SELECT
      employee_id,
      to_date,
      LAG(amount) OVER (
        PARTITION BY employee_id
        ORDER BY from_date
      ) AS amount,
      ROW_NUMBER() OVER (
        PARTITION BY employee_id
        ORDER BY to_date DESC
      ) AS record_rank
    FROM mv_employees.salary
  ) all_salaries
  WHERE record_rank = 1
),
cte_join_data AS (
SELECT
  employee.id AS employee_id,
  employee.birth_date,
  -- calculated employee_age field
  DATE_PART('year', now()) -
    DATE_PART('year', employee.birth_date) AS employee_age,
  -- employee full name
  CONCAT_WS(' ', employee.first_name, employee.last_name) AS employee_name,
  employee.gender,
  employee.hire_date,
  title.title,
  salary.amount AS salary,
  cte_previous_salary.amount AS previous_latest_salary,
  department.dept_name AS department,
  -- use the `manager` aliased version of employee table for manager
  CONCAT_WS(' ', manager.first_name, manager.last_name) AS manager,
  -- calculated tenure fields
  DATE_PART('year', now()) -
    DATE_PART('year', employee.hire_date) AS company_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', title.from_date) AS title_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', department_employee.from_date) AS department_tenure_years,
  -- we also need to use AGE & DATE_PART functions here to generate month diff
  DATE_PART('months', AGE(now(), title.from_date)) AS title_tenure_months,
  GREATEST(
    title.from_date,
    salary.from_date,
    department_employee.from_date,
    department_manager.from_date
  ) AS effective_date,
  LEAST(
    title.to_date,
    salary.to_date,
    department_employee.to_date,
    department_manager.to_date
  ) AS expiry_date
FROM mv_employees.employee
INNER JOIN mv_employees.title
  ON employee.id = title.employee_id
INNER JOIN mv_employees.salary
  ON employee.id = salary.employee_id
INNER JOIN mv_employees.department_employee
  ON employee.id = department_employee.employee_id
INNER JOIN mv_employees.department
  ON department_employee.department_id = department.id
INNER JOIN mv_employees.department_manager
  ON department.id = department_manager.department_id
INNER JOIN mv_employees.employee AS manager
  ON department_manager.employee_id = manager.id
INNER JOIN cte_previous_salary
  ON mv_employees.employee.id = cte_previous_salary.employee_id
),
cte_ordered_transactions AS (
  SELECT
    employee_id,
    birth_date,
    employee_age,
    employee_name,
    gender,
    hire_date,
    title,
    LAG(title) OVER w AS previous_title,
    salary,
    previous_latest_salary,
    LAG(salary) OVER w AS previous_salary,
    department,
    LAG(department) OVER w AS previous_department,
    manager,
    LAG(manager) OVER w AS previous_manager,
    company_tenure_years,
    title_tenure_years,
    title_tenure_months,
    department_tenure_years,
    effective_date,
    expiry_date,
    ROW_NUMBER() OVER (
      PARTITION BY employee_id
      ORDER BY effective_date DESC
    ) AS event_order
  FROM cte_join_data
  WHERE effective_date <= expiry_date
  WINDOW
    w AS (PARTITION BY employee_id ORDER BY effective_date)
),
final_output AS (
  SELECT
    base.employee_id,
    base.gender,
    base.birth_date,
    base.employee_age,
    base.hire_date,
    base.title,
    base.employee_name,
    base.previous_title,
    base.salary,
    previous_latest_salary,
    base.previous_salary,
    base.department,
    base.previous_department,
    base.manager,
    base.previous_manager,
    -- tenure metrics
    base.company_tenure_years,
    base.title_tenure_years,
    base.title_tenure_months,
    base.department_tenure_years,
    base.event_order,
    CASE
      WHEN event_order = 1
        THEN ROUND(
          100 * (base.salary - base.previous_latest_salary) /
            base.previous_latest_salary::NUMERIC,
          2
        )
      ELSE NULL
    END AS latest_salary_percentage_change,
    CASE
      WHEN event_order = 1
        THEN ROUND(
          base.salary - base.previous_latest_salary
        )
      ELSE NULL
    END AS latest_salary_amount_change,
    CASE
      WHEN base.previous_salary < base.salary
        THEN 'Salary Increase'
      WHEN base.previous_salary > base.salary
        THEN 'Salary Decrease'
      WHEN base.previous_department <> base.department
        THEN 'Dept Transfer'
      WHEN base.previous_manager <> base.manager
        THEN 'Reporting Line Change'
      WHEN base.previous_title <> base.title
        THEN 'Title Change'
      ELSE NULL
    END AS event_name,
    -- salary change
    ROUND(base.salary - base.previous_salary) AS salary_amount_change,
    ROUND(
      100 * (base.salary - base.previous_salary) / base.previous_salary::NUMERIC,
      2
    ) AS salary_percentage_change,
    -- tenure
    ROUND(tenure_benchmark_salary) AS tenure_benchmark_salary,
    ROUND(
      100 * (base.salary - tenure_benchmark_salary)
        / tenure_benchmark_salary::NUMERIC
    ) AS tenure_comparison,
    -- title
    ROUND(title_benchmark_salary) AS title_benchmark_salary,
    ROUND(
      100 * (base.salary - title_benchmark_salary)
        / title_benchmark_salary::NUMERIC
    ) AS title_comparison,
    -- department
    ROUND(department_benchmark_salary) AS department_benchmark_salary,
    ROUND(
      100 * (salary - department_benchmark_salary)
        / department_benchmark_salary::NUMERIC
    ) AS department_comparison,
    -- gender
    ROUND(gender_benchmark_salary) AS gender_benchmark_salary,
    ROUND(
      100 * (base.salary - gender_benchmark_salary)
        / gender_benchmark_salary::NUMERIC
    ) AS gender_comparison,
    base.effective_date,
    base.expiry_date
  FROM cte_ordered_transactions AS base
  INNER JOIN mv_employees.tenure_benchmark
    ON base.company_tenure_years = tenure_benchmark.company_tenure_years
  INNER JOIN mv_employees.title_benchmark
    ON base.title = title_benchmark.title
  INNER JOIN mv_employees.department_benchmark
    ON base.department = department_benchmark.department
  INNER JOIN mv_employees.gender_benchmark
    ON base.gender = gender_benchmark.gender

)
SELECT * FROM final_output;

-- by keeping only the 5 latest events
DROP VIEW IF EXISTS mv_employees.employee_deep_dive;
CREATE VIEW mv_employees.employee_deep_dive AS
SELECT *
FROM mv_employees.historic_employee_records
WHERE event_order <= 5;
```

## 💯 Result

### ⭐ **Department Level Results**
```sql
SELECT * FROM mv_employees.department_level_dashboard
ORDER BY department, gender;
```

**Result:**
|gender|department        |employee_count|employee_percentage|department_tenure|avg_salary|avg_salary_percentage_change|min_salary|max_salary|median_salary|inter_quartile_range|stddev_salary|
|------|------------------|--------------|-------------------|-----------------|----------|----------------------------|----------|----------|-------------|--------------------|-------------|
|M     |Customer Service  |10562         |60                 |9                |67203     |3                           |39373     |143950    |65100        |20097               |15921        |
|F     |Customer Service  |7007          |40                 |9                |67409     |3                           |39812     |144866    |65198        |20450               |15979        |
|M     |Development       |36853         |60                 |11               |67713     |3                           |39036     |140784    |66526        |19664               |14267        |
|F     |Development       |24533         |40                 |11               |67576     |3                           |39469     |144434    |66355        |19309               |14149        |
|M     |Finance           |7423          |60                 |11               |78433     |3                           |39012     |142395    |77526        |24078               |17242        |
|F     |Finance           |5014          |40                 |11               |78747     |3                           |39949     |136978    |78285        |23576               |16833        |
|M     |Human Resources   |7751          |60                 |11               |63777     |3                           |39611     |141953    |62864        |17607               |12843        |
|F     |Human Resources   |5147          |40                 |11               |64140     |3                           |38936     |123268    |62782        |17674               |12955        |
|M     |Marketing         |8978          |60                 |10               |80293     |3                           |39821     |145128    |79481        |24990               |17480        |
|F     |Marketing         |5864          |40                 |10               |79700     |3                           |39871     |141842    |78596        |24512               |17293        |
|M     |Production        |31911         |60                 |10               |67921     |3                           |38623     |132552    |66768        |19662               |14271        |
|F     |Production        |21393         |40                 |10               |67728     |3                           |39476     |138273    |66645        |19485               |14099        |
|M     |Quality Management|8674          |60                 |10               |65361     |3                           |38942     |132103    |64258        |18465               |13402        |
|F     |Quality Management|5872          |40                 |10               |65562     |3                           |39571     |122965    |64685        |18386               |13259        |
|M     |Research          |9260          |60                 |10               |67848     |3                           |39186     |130211    |66576        |19749               |14435        |
|F     |Research          |6181          |40                 |10               |68012     |3                           |39526     |124158    |66814        |19100               |14252        |
|M     |Sales             |22702         |60                 |11               |88864     |2                           |39426     |158220    |88462        |24401               |17757        |
|F     |Sales             |14999         |40                 |11               |88836     |2                           |40392     |152710    |88581        |24712               |17738        |


---

### ⭐ **Title Level Results**
```sql
SELECT * FROM mv_employees.title_level_dashboard
ORDER BY title, gender;
```
**Result:**
|gender|title             |employee_count|employee_percentage|title_tenure|avg_salary|avg_salary_percentage_change|min_salary|max_salary|median_salary|inter_quartile_range|stddev_salary|
|------|------------------|--------------|-------------------|------------|----------|----------------------------|----------|----------|-------------|--------------------|-------------|
|M     |Assistant Engineer|2148          |60                 |6           |57198     |4                           |39827     |117636    |54384        |14972               |11152        |
|F     |Assistant Engineer|1440          |40                 |6           |57496     |4                           |39469     |106340    |55234        |14679               |10805        |
|M     |Engineer          |18571         |60                 |6           |59593     |4                           |38942     |130939    |56941        |17311               |12416        |
|F     |Engineer          |12412         |40                 |6           |59617     |4                           |39519     |115444    |57220        |17223               |12211        |
|M     |Manager           |5             |56                 |9           |79351     |2                           |56654     |106491    |72876        |43242               |23615        |
|F     |Manager           |4             |44                 |12          |75690     |3                           |65400     |83457     |76952        |8176                |7774         |
|M     |Senior Engineer   |51533         |60                 |7           |70870     |3                           |39285     |140784    |69509        |18081               |13596        |
|F     |Senior Engineer   |34406         |40                 |8           |70754     |3                           |39476     |138273    |69478        |17918               |13494        |
|M     |Senior Staff      |49232         |60                 |7           |80735     |3                           |39012     |158220    |78704        |27310               |18679        |
|F     |Senior Staff      |32792         |40                 |7           |80663     |3                           |39227     |152710    |78617        |27406               |18621        |
|M     |Staff             |15436         |60                 |6           |67362     |3                           |39186     |133577    |65120        |27388               |17193        |
|F     |Staff             |10090         |40                 |6           |67282     |3                           |38936     |137875    |65110        |26470               |16815        |
|M     |Technique Leader  |7189          |60                 |11          |67600     |3                           |38623     |132233    |66558        |19162               |14087        |
|F     |Technique Leader  |4866          |40                 |11          |67369     |3                           |39812     |144434    |66174        |18710               |13939        |


---

### ⭐ **Salary Benchmark Results**

#### **1. Company Tenure Benchmark**
```sql
SELECT * FROM mv_employees.tenure_benchmark
ORDER BY company_tenure_years;
```
**Result:**
|company_tenure_years|tenure_benchmark_salary|
|--------------------|-----------------------|
|3                   |58192.111111111111     |
|4                   |58199.381229235880     |
|5                   |59673.060204695966     |
|6                   |60794.599395313681     |
|7                   |62424.674585563242     |
|8                   |63705.126141845427     |
|9                   |65332.550853873980     |
|10                  |67090.800166933296     |
|11                  |68286.071060382916     |
|12                  |69812.803444278854     |
|13                  |71483.857415471938     |
|14                  |73053.445423075238     |
|15                  |74201.560354770712     |
|16                  |75927.588217658522     |
|17                  |77411.446324549237     |
|18                  |78870.316248983776     |


#### **2. Gender Benchmark**
```sql
SELECT * FROM mv_employees.gender_benchmark;
```

**Result:**
|gender|gender_benchmark_salary|
|------|-----------------------|
|M     |72044.656972951969     |
|F     |71963.570753046558     |


#### **3. Department Benchmark**
```sql
SELECT * FROM mv_employees.department_benchmark
ORDER BY department_benchmark_salary DESC;
```

**Result:**
|department|department_benchmark_salary|
|----------|---------------------------|
|Sales     |88852.969470305827         |
|Marketing |80058.848807438351         |
|Finance   |78559.936962289941         |
|Research  |67913.374975714008         |
|Production|67843.301984841663         |
|Development|67657.919558205454         |
|Customer Service|67285.230178154704         |
|Quality Management|65441.993400247491         |
|Human Resources|63921.899829430920         |


#### **4. Title Benchmark**
```sql
SELECT * FROM mv_employees.title_benchmark
ORDER BY title_benchmark_salary DESC;
```

**Result:**
|title|title_benchmark_salary|
|-----|----------------------|
|Senior Staff|80706.495879254852    |
|Manager|77723.666666666667    |
|Senior Engineer|70823.437647633787    |
|Technique Leader|67506.590294483617    |
|Staff|67330.665204105618    |
|Engineer|59602.737759416454    |
|Assistant Engineer|57317.573578595318    |

---

#### ⭐ **Historic Employee Deep Dive Example**
```sql
SELECT * FROM mv_employees.employee_deep_dive
WHERE employee_name = 'Leah Anguita'
ORDER BY event_order;
```
**Result:**
|employee_id|gender|birth_date|employee_age|hire_date|title          |employee_name|previous_title|salary|previous_latest_salary|previous_salary|department      |previous_department|manager        |previous_manager|company_tenure_years|title_tenure_years|title_tenure_months|department_tenure_years|event_order|latest_salary_percentage_change|event_name     |salary_amount_change|salary_percentage_change|tenure_benchmark_salary|tenure_comparison|title_benchmark_salary|title_comparison|department_benchmark_salary|department_comparison|gender_benchmark_salary|gender_comparison|effective_date|expiry_date|
|-----------|------|----------|------------|---------|---------------|-------------|--------------|------|----------------------|---------------|----------------|-------------------|---------------|----------------|--------------------|------------------|-------------------|-----------------------|-----------|-------------------------------|---------------|--------------------|------------------------|-----------------------|-----------------|----------------------|----------------|---------------------------|---------------------|-----------------------|-----------------|--------------|-----------|
|11669      |M     |3/3/1975  |46          |4/7/2004 |Senior Engineer|Leah Anguita |Engineer      |47373 |47046                 |47373          |Customer Service|Customer Service   |Yuchang Weedman|Yuchang Weedman |17                  |1                 |11                 |2                      |1          |0.7                            |Title Change   |0                   |0                       |77411                  |-39              |70823                 |-33             |67285                      |-30                  |72045                  |-34              |5/12/2020     |1/1/9999   |
|11669      |M     |3/3/1975  |46          |4/7/2004 |Engineer       |Leah Anguita |Engineer      |47373 |47046                 |47046          |Customer Service|Customer Service   |Yuchang Weedman|Yuchang Weedman |17                  |6                 |11                 |2                      |2          |                               |Salary Increase|327                 |0.7                     |77411                  |-39              |59603                 |-21             |67285                      |-30                  |72045                  |-34              |5/11/2020     |5/12/2020  |
|11669      |M     |3/3/1975  |46          |4/7/2004 |Engineer       |Leah Anguita |Engineer      |47046 |47046                 |47046          |Customer Service|Production         |Yuchang Weedman|Oscar Ghazalie  |17                  |6                 |11                 |2                      |3          |                               |Dept Transfer  |0                   |0                       |77411                  |-39              |59603                 |-21             |67285                      |-30                  |72045                  |-35              |6/12/2019     |5/11/2020  |
|11669      |M     |3/3/1975  |46          |4/7/2004 |Engineer       |Leah Anguita |Engineer      |47046 |47046                 |43681          |Production      |Production         |Oscar Ghazalie |Oscar Ghazalie  |17                  |6                 |11                 |6                      |4          |                               |Salary Increase|3365                |7.7                     |77411                  |-39              |59603                 |-21             |67843                      |-31                  |72045                  |-35              |5/11/2019     |6/12/2019  |
|11669      |M     |3/3/1975  |46          |4/7/2004 |Engineer       |Leah Anguita |Engineer      |43681 |47046                 |43930          |Production      |Production         |Oscar Ghazalie |Oscar Ghazalie  |17                  |6                 |11                 |6                      |5          |                               |Salary Decrease|-249                |-0.57                   |77411                  |-44              |59603                 |-27             |67843                      |-36                  |72045                  |-39              |5/11/2018     |5/11/2019  |

___________________________________

<p>&copy; 2021 Leah Nguyen</p>