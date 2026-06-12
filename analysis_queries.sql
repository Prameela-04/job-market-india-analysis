
-- ============================================================
-- Job Market Intelligence Dashboard — SQL Analysis
-- Author: [Your Name]
-- Database: SQLite | Tables: jobs_global, jobs_india, jobs_apac
-- ============================================================

-- Q1: Top 15 Highest Paying Full-Time Jobs

SELECT 
    job_title,
    role_category,
    experience_level,
    company_size,
    work_setting,
    salary_in_usd
FROM jobs_global
WHERE employment_type = 'Full-Time'
  AND is_salary_outlier = 0
ORDER BY salary_in_usd DESC
LIMIT 15


-- Q2: Salary Statistics by Role Category

SELECT
    role_category                           AS Role,
    COUNT(*)                                AS Total_Jobs,
    ROUND(AVG(salary_in_usd), 0)           AS Avg_Salary_USD,
    ROUND(MIN(salary_in_usd), 0)           AS Min_Salary_USD,
    ROUND(MAX(salary_in_usd), 0)           AS Max_Salary_USD,
    ROUND(AVG(salary_in_usd) * 83, 0)     AS Avg_Salary_INR
FROM jobs_global
WHERE is_salary_outlier = 0
GROUP BY role_category
ORDER BY Avg_Salary_USD DESC


-- Q3: Salary Tier Classification (CASE WHEN)

SELECT
    role_category                       AS Role,
    experience_level                    AS Experience,
    COUNT(*)                            AS Job_Count,
    ROUND(AVG(salary_in_usd), 0)       AS Avg_Salary,
    CASE
        WHEN AVG(salary_in_usd) >= 150000 THEN '🔥 Premium Tier'
        WHEN AVG(salary_in_usd) >= 100000 THEN '✅ High Tier'
        WHEN AVG(salary_in_usd) >= 60000  THEN '📊 Mid Tier'
        ELSE                                   '🔵 Entry Tier'
    END                                 AS Salary_Tier
FROM jobs_global
WHERE is_salary_outlier = 0
GROUP BY role_category, experience_level
ORDER BY Avg_Salary DESC
LIMIT 20


-- Q4: Roles Above vs Below Average (CTE)

-- Step 1: Calculate global average salary
WITH global_avg AS (
    SELECT ROUND(AVG(salary_in_usd), 0) AS avg_salary
    FROM jobs_global
    WHERE is_salary_outlier = 0
),

-- Step 2: Calculate per-role averages
role_averages AS (
    SELECT
        role_category,
        COUNT(*)                          AS job_count,
        ROUND(AVG(salary_in_usd), 0)     AS role_avg_salary
    FROM jobs_global
    WHERE is_salary_outlier = 0
    GROUP BY role_category
)

-- Step 3: Compare role avg vs global avg
SELECT
    r.role_category                                         AS Role,
    r.job_count                                             AS Jobs,
    r.role_avg_salary                                       AS Role_Avg_USD,
    g.avg_salary                                            AS Global_Avg_USD,
    ROUND(r.role_avg_salary - g.avg_salary, 0)             AS Difference_USD,
    ROUND((r.role_avg_salary - g.avg_salary) 
          / g.avg_salary * 100, 1)                         AS Pct_Above_Avg,
    CASE
        WHEN r.role_avg_salary > g.avg_salary 
        THEN '✅ Above Average'
        ELSE '🔵 Below Average'
    END                                                     AS Vs_Market
FROM role_averages r
CROSS JOIN global_avg g
ORDER BY Pct_Above_Avg DESC


-- Q5: Top 3 Roles Per Experience Level (Window Function)

-- Rank each role by salary WITHIN each experience level
-- This answers: "For my experience level, which role pays best?"
WITH ranked_roles AS (
    SELECT
        experience_level,
        role_category,
        COUNT(*)                                    AS job_count,
        ROUND(AVG(salary_in_usd), 0)               AS avg_salary,
        RANK() OVER (
            PARTITION BY experience_level           
            ORDER BY AVG(salary_in_usd) DESC        
        )                                           AS salary_rank
    FROM jobs_global
    WHERE is_salary_outlier = 0
    GROUP BY experience_level, role_category
)
SELECT
    experience_level    AS Experience,
    salary_rank         AS Rank,
    role_category       AS Role,
    avg_salary          AS Avg_Salary_USD,
    job_count           AS Job_Count
FROM ranked_roles
WHERE salary_rank <= 3          -- Top 3 roles per experience level
ORDER BY 
    CASE experience_level
        WHEN 'Entry-level' THEN 1
        WHEN 'Mid-level'   THEN 2
        WHEN 'Senior'      THEN 3
        WHEN 'Executive'   THEN 4
    END,
    salary_rank


-- Q6: India vs Global Salary Comparison (JOIN)

-- Compare role-level salaries: India dataset vs Global dataset
WITH india_salaries AS (
    SELECT
        role_category,
        ROUND(AVG(salary_in_usd), 0)   AS india_avg_salary,
        COUNT(*)                        AS india_job_count
    FROM jobs_india
    GROUP BY role_category
),
global_salaries AS (
    SELECT
        role_category,
        ROUND(AVG(salary_in_usd), 0)   AS global_avg_salary,
        COUNT(*)                        AS global_job_count
    FROM jobs_global
    WHERE is_salary_outlier = 0
    GROUP BY role_category
)
SELECT
    g.role_category                                         AS Role,
    i.india_avg_salary                                      AS India_Avg_USD,
    g.global_avg_salary                                     AS Global_Avg_USD,
    ROUND(i.india_avg_salary * 83, 0)                      AS India_Avg_INR,
    ROUND((g.global_avg_salary - i.india_avg_salary) 
          / g.global_avg_salary * 100, 1)                  AS India_Discount_Pct
FROM global_salaries g
INNER JOIN india_salaries i
    ON g.role_category = i.role_category
ORDER BY India_Discount_Pct ASC


-- Q7: Year-over-Year Growth Analysis (LAG Window Function)

WITH yearly_stats AS (
    SELECT
        work_year,
        COUNT(*)                            AS total_jobs,
        ROUND(AVG(salary_in_usd), 0)       AS avg_salary,
        ROUND(
            COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 
            1
        )                                   AS pct_of_total_jobs
    FROM jobs_global
    WHERE is_salary_outlier = 0
    GROUP BY work_year
),
with_growth AS (
    SELECT
        work_year,
        total_jobs,
        avg_salary,
        pct_of_total_jobs,
        LAG(avg_salary) OVER (ORDER BY work_year)   AS prev_year_salary,
        LAG(total_jobs) OVER (ORDER BY work_year)   AS prev_year_jobs
    FROM yearly_stats
)
SELECT
    work_year                                           AS Year,
    total_jobs                                          AS Jobs,
    avg_salary                                          AS Avg_Salary_USD,
    pct_of_total_jobs                                   AS Pct_Of_All_Jobs,
    prev_year_salary                                    AS Prev_Year_Salary,
    CASE
        WHEN prev_year_salary IS NULL THEN 'Baseline'
        ELSE ROUND((avg_salary - prev_year_salary) 
                   * 100.0 / prev_year_salary, 1) || '%'
    END                                                 AS Salary_Growth_YoY,
    CASE
        WHEN prev_year_jobs IS NULL THEN 'Baseline'
        ELSE ROUND((total_jobs - prev_year_jobs) 
                   * 100.0 / prev_year_jobs, 1) || '%'
    END                                                 AS Job_Growth_YoY
FROM with_growth
ORDER BY work_year

