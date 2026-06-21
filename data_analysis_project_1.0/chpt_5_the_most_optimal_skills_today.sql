-- Recall in chapter 3, I found the highest paying jobs associated with their skills.
-- And chapter 4, I found the top skills with highest average salary for job postings.
-- In this chapter, I seek to find the most optimal skills, for securing a job based on 
-- on the job postings stat.
-- This query also helps the job enthusiasts to be able to match their skills to jobs
--  in terms of demand, or highest average salaries.
-- that said, the query is optimized to returned results for different(specified) jot titles/roles.
WITH highest_in_demand_skills AS (
    SELECT skills_dim.skill_id AS skill_id,
        COUNT(skills_job_dim.job_id) AS job_count,
        skills AS skill_name
    FROM skills_dim
        JOIN skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
        JOIN job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id -- i joined with job_postings_fact table so I
        -- filter results for specific job titles
    WHERE job_postings_fact.job_title_short = 'Software Engineer' -- yes here, the job title is specified here.
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
ORDER BY hs.average_salary DESC,  -- with this order by section, we can sort for highest salary skills first,
    hd.job_count DESC        -- or highest demand ones.

LIMIT 30; -- for at most 30 most optimal skills, either high in demand, or highly paid