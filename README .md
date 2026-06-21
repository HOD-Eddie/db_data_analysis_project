# SQL Data Analytics: Exploring the Data Job Market

## 1. Introduction

This project dives into the data job market through the lens of SQL, using a real-world database of job postings, companies, and skills. The goal was to answer practical questions that anyone targeting a data-related career might ask: Which roles pay the most? What skills do top-paying jobs demand? Which skills are most in demand, and which ones pay the best? And, ultimately, which skills offer the best balance of demand and pay?

Rather than treating this as a purely academic SQL exercise, I approached it as an aspiring Data Analyst trying to make sense of the job market for myself — using the database to answer the exact questions I'd want answered before deciding what to learn next.

See Queries here: [data_analysis_project_1.0 folder](/data_analysis_project_1.0/)

## 2. Background

The dataset is built around a set of relational tables capturing job postings and the skills tied to them:

- **`job_postings_fact`** — the central fact table, containing individual job postings (title, location, salary, posted date, company reference, etc.)
- **`company_dim`** — company information, linked to job postings via `company_id`
- **`skills_dim`** — a lookup table of distinct skills, each with a `skill_id`
- **`skills_job_dim`** — a bridge table mapping job postings to the skills they require

This star-schema-like structure made it a great candidate for practicing joins, subqueries, CTEs, and aggregation — since almost every meaningful question requires pulling data across multiple tables.

The job titles explored throughout this project include roles such as *Data Analyst, Data Engineer, Data Scientist, Machine Learning Engineer, Software Engineer, Cloud Engineer, Business Analyst*, and their "Senior" variants.
This awesome Data hails from [Luke Barousse's SQL Course](https://lukebarousse.com/sql). Him and his Team deserve the huge CREDIT ✅

## 3. Tools I Used

- **PostgreSQL** — the database engine and SQL dialect used for all queries (window functions, CTEs, `ROUND`, type casting, etc.)
- **VS Code** — used to write, organize, and run the SQL scripts, with each analytical question kept in its own `.sql` file for clarity
- **Git / GitHub** — for version control and to host this project

## 4. The Analysis

Each query below was written to answer a specific question, building progressively on the one before it. Sample query results are summarized in tables (queries 3–5), and placeholders are included for the corresponding visualizations.

### Query 1 — What are the top-paying jobs for a given role?

This query identifies the top 10 highest-paying job postings for a specified role (here, Data Scientist), filtering out postings with no listed salary.

```sql
SELECT job_title_short,
    job_location,
    salary_year_avg,
    company_dim.name AS company,
    job_schedule_type,
    job_posted_date::DATE
FROM job_postings_fact
    LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Scientist'
    AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```

**Sample results — Top 10 highest-paying Data Scientist roles**

| Company | Location | Average Salary (USD) |
|---|---|---|
| East River Electric Power Cooperative, Inc. | Madison, SD | $960,000 |
| ReServe | New York, NY | $585,000 |
| Selby Jennings | Anywhere | $550,000 |
| Selby Jennings | Anywhere | $525,000 |
| Netflix | Los Gatos, CA | $450,000 |
| Netflix | California City, CA | $450,000 |
| Glocomms | San Francisco, CA | $425,000 |
| Algo Capital Group | Anywhere | $375,000 |
| Truist Financial | Charlotte, NC | $375,000 |
| PayPal | Austin, TX | $375,000 |

**Chart:** A horizontal bar chart of these 10 postings shows one clear outlier — the $960,000 listing at East River Electric Power Cooperative sits well above the rest of the field, which clusters more tightly between $375,000 and $585,000.


### Query 2 — What skills are required for the top-paying jobs?

Building on Query 1, this query uses the top-paying jobs as a subquery, then joins against the skills tables to see exactly what skills those roles demand.

```sql
SELECT top_paying_jobs.*,
    skills
FROM (
        SELECT job_id,
            job_title_short,
            job_postings_fact.salary_year_avg AS avg_annual_salary,
            company_dim.name AS company
        FROM job_postings_fact
            LEFT JOIN company_dim
            ON job_postings_fact.company_id = company_dim.company_id
        WHERE job_title_short = 'Data Engineer'
            AND salary_year_avg IS NOT NULL
        ORDER BY salary_year_avg DESC
        LIMIT 10
    ) AS top_paying_jobs
    JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
    JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY avg_annual_salary DESC;
```

**Sample results — Skill frequency across the top 10 highest-paying Data Engineer postings**

| Skill | Mentions |
|---|---|
| Python | 8 |
| Linux | 4 |
| SQL | 3 |
| AWS | 3 |
| Excel | 3 |
| Docker | 3 |
| Java | 2 |
| C++ | 2 |
| Kubernetes | 2 |
| MongoDB | 2 |
| (Scala, Spark, SQL Server, PostgreSQL, Redshift, Unix, Splunk, Jenkins, Tableau, Looker, Kafka, Airflow, Go) | 1 each |

**Chart:** Python appears in 8 of the 10 top-paying postings, far outpacing every other skill. Linux, SQL, AWS, Excel, and Docker form a clear second tier, each showing up in 3–4 postings.

### Query 3 — What are the most in-demand skills since 2023?

This query counts how often each skill appears across job postings for a given role, surfacing the top 10 most in-demand skills.

```sql
SELECT skills_dim.skill_id,
    COUNT(skills_job_dim.job_id) AS job_count,
    skills AS skill_name
FROM skills_dim
    JOIN skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
    JOIN job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id
WHERE job_postings_fact.job_title_short = 'Data Engineer'
GROUP BY skills_dim.skill_id
ORDER BY job_count DESC
LIMIT 10;
```

**Sample results — Top in-demand skills for Data Engineer roles**

| Skill Name | Job Count |
|---|---|
| SQL | 113,375 |
| Python | 108,265 |
| AWS | 62,174 |
| Azure | 60,823 |
| Spark | 53,789 |
| Java | 35,642 |
| Kafka | 29,163 |
| Hadoop | 28,883 |
| Scala | 28,791 |
| Databricks | 27,532 |

**Chart:** SQL and Python lead by a wide margin, each appearing in over 100,000 postings — roughly double the third-place skill, AWS.


### Query 4 — What are the top-paying skills?

This query computes the average annual salary across all postings associated with each skill, surfacing which skills correlate with the highest pay.

```sql
SELECT
    skills,
    ROUND(AVG(salary_year_avg), 2) AS average_salary
FROM job_postings_fact
JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY
    average_salary DESC
LIMIT 20;
```

**Sample results — Top-paying skills (by average annual salary)**

| Skill Name | Average Salary (USD) |
|---|---|
| Debian | $196,500 |
| RingCentral | $182,500 |
| Mongo | $170,714.89 |
| Lua | $170,500 |
| dplyr | $160,667.21 |
| Haskell | $155,757.67 |
| ASP.NET Core | $155,000 |
| Node | $154,408.02 |
| Cassandra | $154,124.26 |
| Solidity | $153,639.95 |
| Watson | $152,844.23 |
| CodeCommit | $152,289.01 |
| RShiny | $151,611.15 |
| Hugging Face | $148,648.18 |
| Neo4j | $147,707.93 |
| Gatsby | $147,500 |
| Scala | $145,119.51 |
| mlr | $145,000 |
| Kafka | $144,753.82 |
| PyTorch | $144,470.14 |

**Chart:** Unlike the demand list in Query 3, the top-paying skills here are largely niche or specialized (Debian, RingCentral, Lua, Haskell) rather than mainstream — a sign that rarity, not popularity, drives the highest average salaries.


### Query 5 — What are the most optimal skills to learn?

This final query combines demand and salary into a single view using two CTEs — one for skill demand, one for average salary — joined together to find skills that are both in high demand *and* well-paid.

```sql
WITH highest_in_demand_skills AS (
    SELECT skills_dim.skill_id AS skill_id,
        COUNT(skills_job_dim.job_id) AS job_count,
        skills AS skill_name
    FROM skills_dim
        JOIN skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
        JOIN job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id
    WHERE job_postings_fact.job_title_short = 'Software Engineer'
    GROUP BY skills_dim.skill_id
),
highest_avg_salary_skill AS (
    SELECT skills_dim.skill_id AS skill_id,
        skills,
        ROUND(AVG(salary_year_avg), 2) AS average_salary
    FROM job_postings_fact
        JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
        JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE salary_year_avg IS NOT NULL
    GROUP BY skills_dim.skill_id
)
SELECT hd.skill_id,
    hd.skill_name,
    hd.job_count,
    hs.average_salary
FROM highest_in_demand_skills hd
JOIN highest_avg_salary_skill hs
    ON hd.skill_id = hs.skill_id
ORDER BY hs.average_salary DESC,
    hd.job_count DESC
LIMIT 30;
```

**Sample results — Most optimal skills (demand + salary) for Software Engineer roles**

| Skill Name | Job Count | Average Salary (USD) |
|---|---|---|
| Debian | 159 | $196,500 |
| RingCentral | 6 | $182,500 |
| Mongo | 296 | $170,714.89 |
| Lua | 49 | $170,500 |
| dplyr | 8 | $160,667.21 |
| Haskell | 68 | $155,757.67 |
| ASP.NET Core | 106 | $155,000 |
| Node | 613 | $154,408.02 |
| Cassandra | 714 | $154,124.26 |
| Solidity | 76 | $153,639.95 |
| Watson | 19 | $152,844.23 |
| CodeCommit | 12 | $152,289.01 |
| RShiny | 8 | $151,611.15 |
| Hugging Face | 12 | $148,648.18 |
| Neo4j | 192 | $147,707.93 |
| Gatsby | 8 | $147,500 |
| Scala | 2,292 | $145,119.51 |
| Kafka | 3,666 | $144,753.82 |
| PyTorch | 544 | $144,470.14 |
| Couchdb | 33 | $144,166.67 |
| Mxnet | 24 | $143,694.88 |
| Theano | 8 | $143,403.65 |
| Shell | 1,526 | $143,370.21 |
| Golang | 1,383 | $143,138.68 |
| Airflow | 1,398 | $142,385.76 |
| TensorFlow | 646 | $142,370.32 |
| Spark | 3,503 | $141,733.54 |
| Heroku | 85 | $141,666.67 |
| Redshift | 806 | $140,791.90 |
| Airtable | 11 | $140,615.34 |

**Chart:** Plotting job count against average salary, Kafka and Spark stand out as the genuine "optimal" picks — both have 3,000+ postings and salaries above $140,000. Debian and RingCentral pay even more on average, but their job counts (under 200) make them a far riskier specialization.

## 5. What I Learned

Working through these five queries end-to-end reinforced and deepened several core SQL and PostgreSQL concepts:

- **JOINS** — Used `LEFT JOIN` to preserve job postings even when a matching company record didn't exist, versus `INNER JOIN` (plain `JOIN`) when I deliberately wanted to keep only records that matched across `job_postings_fact`, `skills_job_dim`, and `skills_dim`. Understanding *why* to choose one over the other — based on whether incomplete matches should be dropped or retained — was a key takeaway.
- **Subqueries** — In Query 2, I used a subquery to first isolate the top 10 highest-paying jobs, then joined that derived result set against the skills tables. This taught me how to treat a query's output as a temporary, queryable table.
- **CTEs (Common Table Expressions)** — Query 5 used two CTEs (`highest_in_demand_skills` and `highest_avg_salary_skill`) to break a complex problem into named, readable building blocks before joining them together. Compared to nested subqueries, CTEs made the logic far easier to read and debug.
- **Aggregate Functions & GROUP BY** — `COUNT()` and `AVG()` (paired with `ROUND()` for cleaner output) were central to almost every query from Chapter 3 onward. I learned to be deliberate about *what* I was grouping by (e.g., `skill_id` vs. `skills`) to avoid subtly incorrect aggregations when skill names could theoretically repeat across IDs.
- **Filtering with WHERE vs. HAVING** — Filtering out `NULL` salaries before aggregation (`WHERE salary_year_avg IS NOT NULL`) reinforced the distinction between filtering raw rows before grouping versus filtering aggregated results.
- **Sorting and Limiting Results** — Combining `ORDER BY` (including multi-column sorts, as in Query 5's sort by salary *then* job count) with `LIMIT` to consistently surface "top N" results.
- **Type Casting** — Using `::DATE` to strip the time component from a timestamp column (`job_posted_date::DATE`) in Query 1, a small but practical PostgreSQL-specific convenience.
- **Query Design as Iteration** — Perhaps the biggest non-technical lesson: each query is built on the one before it. Starting with a simple filtered `SELECT`, then layering in subqueries, then CTEs, mirrored how real analytical questions evolve — and how SQL complexity should grow only as far as the question demands.
- **(While not directly used in these queries) Indexing** — Exploring this dataset highlighted *why* indexing matters: columns repeatedly used in `JOIN` and `WHERE` clauses (like `job_id`, `skill_id`, and `company_id`) are exactly the kind of columns that benefit from indexes in a larger, production-scale dataset, since they're scanned constantly during query execution.

## 6. Conclusions

This project moved beyond syntax memorization into actually *using* SQL to answer layered, real-world questions about the data job market. A few high-level conclusions stood out:

- **Demand and pay don't always align.** Niche skills like Debian ($196,500 avg.) and RingCentral ($182,500 avg.) top the salary charts, but with fewer than 200 job postings each, they're a thin foundation to build a career on. Kafka and Spark, by contrast, combine strong salaries (~$144,000–$145,000 avg.) with thousands of postings each — making them the standout "optimal" skills from Query 5.
- **SQL complexity should match the question, not the other way around.** Simple filtered selects were enough for Query 1; CTEs were genuinely necessary by Query 5. Learning to recognize *when* a CTE or subquery is warranted (versus over-engineering a simple query) was as important as learning the syntax itself.
- **A clean schema makes layered analysis possible.** The fact/dimension structure of this dataset (`job_postings_fact`, `company_dim`, `skills_dim`, `skills_job_dim`) made it straightforward to keep extending the analysis without restructuring earlier queries — a good reminder of why schema design matters before any SQL gets written.

Overall, this project gave me hands-on, practical reps with the exact SQL skills (joins, subqueries, CTEs, aggregation) that show up constantly in real analytics work — and a genuinely useful answer to "what should I learn next?" along the way.
