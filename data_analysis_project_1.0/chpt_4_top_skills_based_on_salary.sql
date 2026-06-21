-- Chapter 4 stems from chapter 3, but with a little twist. In this chapter, I seek to find skills with
-- highest average salary per year. 

-- DELIVERABLES
-- find skills associated with jobs postings that have specified annual salaries.
-- join these tables, and return the most important information.
-- Again, this result set is based on the average annual salary for all job postings for that skill,
-- and not, the highest annual salary for a particular job.

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

 