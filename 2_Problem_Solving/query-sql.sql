/*-----------------------------------
Current employee snapshot view
-------------------------------------*/

DROP VIEW IF EXISTS mv_employees.current_employee_snapshot CASCADE;
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
    employee.gender,
    employee.hire_date,
    title.title,
    salary.amount AS salary,
    cte_previous_salary.amount AS previous_salary,
    department.dept_name AS department,
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
  WHERE salary.to_date = '9999-01-01'
    AND title.to_date = '9999-01-01'
    AND department_employee.to_date = '9999-01-01'
),
final_output AS (
  SELECT
    employee_id,
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
  FROM cte_joined_data
)
SELECT * FROM final_output;
--inspect the result
SELECT *
FROM mv_employees.current_employee_snapshot
LIMIT 5;

--Result:
+──────────────+─────────+──────────────────+─────────+──────────────────+───────────────────────────+───────────────────────+─────────────────────+──────────────────────────+
| employee_id  | gender  | title            | salary  | department       | salary_percentage_change  | company_tenure_years  | title_tenure_years  | department_tenure_years  |
+──────────────+─────────+──────────────────+─────────+──────────────────+───────────────────────────+───────────────────────+─────────────────────+──────────────────────────+
| 10001        | M       | Senior Engineer  | 88958   | Development      | 4.54                      | 17                    | 17                  | 17                       |
| 10002        | F       | Staff            | 72527   | Sales            | 0.78                      | 18                    | 7                   | 7                        |
| 10003        | M       | Senior Engineer  | 43311   | Production       | -0.89                     | 17                    | 8                   | 8                        |
| 10004        | M       | Senior Engineer  | 74057   | Production       | 4.75                      | 17                    | 8                   | 17                       |
| 10005        | M       | Senior Staff     | 94692   | Human Resources  | 3.54                      | 14                    | 7                   | 14                       |
+──────────────+─────────+──────────────────+─────────+──────────────────+───────────────────────────+───────────────────────+─────────────────────+──────────────────────────+

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

--inspect the result
SELECT *
FROM mv_employees.company_level_dashboard
LIMIT 5;

--Result:
+─────────+─────────────────+──────────────────────+─────────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+
| gender  | employee_count  | employee_percentage  | company_tenure  | avg_salary  | avg_salary_percentage_change  | min_salary  | max_salary  | median_salary  | inter_quartile_range  | stddev_salary  |
+─────────+─────────────────+──────────────────────+─────────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+
| M       | 144114          | 60                   | 13              | 72045       | 3                             | 38623       | 158220      | 69830          | 23624                 | 17363          |
| F       | 96010           | 40                   | 13              | 71964       | 3                             | 38936       | 152710      | 69764          | 23326                 | 17230          |
+─────────+─────────────────+──────────────────────+─────────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+

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
  
--inspect the result
SELECT *
FROM mv_employees.department_level_dashboard
LIMIT 5;

--Result:
+─────────+───────────────────+─────────────────+──────────────────────+────────────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+
| gender  | department        | employee_count  | employee_percentage  | department_tenure  | avg_salary  | avg_salary_percentage_change  | min_salary  | max_salary  | median_salary  | inter_quartile_range  | stddev_salary  |
+─────────+───────────────────+─────────────────+──────────────────────+────────────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+
| M       | Customer Service  | 10562           | 60                   | 9                  | 67203       | 3                             | 39373       | 143950      | 65100          | 20097                 | 15921          |
| F       | Customer Service  | 7007            | 40                   | 9                  | 67409       | 3                             | 39812       | 144866      | 65198          | 20450                 | 15979          |
| M       | Development       | 36853           | 60                   | 11                 | 67713       | 3                             | 39036       | 140784      | 66526          | 19664                 | 14267          |
| F       | Development       | 24533           | 40                   | 11                 | 67576       | 3                             | 39469       | 144434      | 66355          | 19309                 | 14149          |
| M       | Finance           | 7423            | 60                   | 11                 | 78433       | 3                             | 39012       | 142395      | 77526          | 24078                 | 17242          |
+─────────+───────────────────+─────────────────+──────────────────────+────────────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+

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

--inspect the result:
SELECT *
FROM mv_employees.title_level_dashboard
LIMIT 5;

--Result:
+─────────+─────────────────────+─────────────────+──────────────────────+───────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+
| gender  | title               | employee_count  | employee_percentage  | title_tenure  | avg_salary  | avg_salary_percentage_change  | min_salary  | max_salary  | median_salary  | inter_quartile_range  | stddev_salary  |
+─────────+─────────────────────+─────────────────+──────────────────────+───────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+
| M       | Assistant Engineer  | 2148            | 60                   | 6             | 57198       | 4                             | 39827       | 117636      | 54384          | 14972                 | 11152          |
| F       | Assistant Engineer  | 1440            | 40                   | 6             | 57496       | 4                             | 39469       | 106340      | 55234          | 14679                 | 10805          |
| M       | Engineer            | 18571           | 60                   | 6             | 59593       | 4                             | 38942       | 130939      | 56941          | 17311                 | 12416          |
| F       | Engineer            | 12412           | 40                   | 6             | 59617       | 4                             | 39519       | 115444      | 57220          | 17223                 | 12211          |
| M       | Manager             | 5               | 56                   | 9             | 79351       | 2                             | 56654       | 106491      | 72876          | 43242                 | 23615          |
+─────────+─────────────────────+─────────────────+──────────────────────+───────────────+─────────────+───────────────────────────────+─────────────+─────────────+────────────────+───────────────────────+────────────────+

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
Historic Employee Deep Dive View
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
  DATE_PART('year', now()) -
    DATE_PART('year', employee.birth_date) AS employee_age,
  CONCAT_WS(' ', employee.first_name, employee.last_name) AS employee_name,
  employee.gender,
  employee.hire_date,
  title.title,
  salary.amount AS salary,
  cte_previous_salary.amount AS previous_latest_salary,
  department.dept_name AS department,
  CONCAT_WS(' ', manager.first_name, manager.last_name) AS manager,
  DATE_PART('year', now()) -
    DATE_PART('year', employee.hire_date) AS company_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', title.from_date) AS title_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', department_employee.from_date) AS department_tenure_years,
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

-- This final view powers the employee deep dive tool
DROP VIEW IF EXISTS mv_employees.employee_deep_dive;
CREATE VIEW mv_employees.employee_deep_dive AS
SELECT *
FROM mv_employees.historic_employee_records
WHERE event_order <= 5;
