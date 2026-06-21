-- This is chapter3. As the analyst, I have worked so far on extracting the highest paying jobs for specific job roles,
--  and also, the highest paying skills associated with high paying jobs. This query focuses on the top 10 skills in high demand
-- for any specified job role.
-- the various job roles ["Business Analyst", "Cloud Engineer", "Data Analyst", "Data Engineer", "Data Scientist",
--      "Machine Learning Engineer", "Senior Data Analyst", "Senior Data Engineer",  "Senior Data Scientist", "Software Engineer"]
SELECT skills_dim.skill_id,
    COUNT(skills_job_dim.job_id) AS job_count,
    skills AS skill_name
FROM skills_dim
    JOIN skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
    JOIN job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id -- i joined with job_postings_fact table so I
    -- filter results for specific job titles
WHERE job_postings_fact.job_title_short = 'Data Engineer' -- yes here, the job title is specified here.
GROUP BY skills_dim.skill_id
ORDER BY job_count DESC
LIMIT 10;