-- With time, I am beginning to explore more complex querries, if not too complex.
-- One thing, it isn't getting simpler than I first started.
-- In this chapter, I created a query that returns the remote job counts per each skill,
-- More like a more restricting form of my previous query that returns the hotest skills for all job
-- categories, in terms of job counts and demand.
CREATE TABLE job_count_per_skill AS WITH remote_jobs_per_skill AS (
    SELECT skill_id,
        COUNT(skills_job_dim.job_id) AS jobs_per_skill
    FROM skills_job_dim
        JOIN job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id
    WHERE job_postings_fact.job_work_from_home = TRUE -- AND job_postings_fact.job_title_short = 'Data Scientist'
    GROUP BY skill_id
)
SELECT rjp.skill_id,
    sd.skills AS skill_name,
    jobs_per_skill
FROM remote_jobs_per_skill AS rjp
    JOIN skills_dim AS sd ON rjp.skill_id = sd.skill_id
ORDER BY jobs_per_skill DESC
LIMIT 5;