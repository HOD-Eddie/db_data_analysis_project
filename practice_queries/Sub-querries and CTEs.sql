-- I have covered CTEs and Sub-querries in this sections.
-- Now, I feel confident combining temporary result sets with 
-- existing table data and pulling meaningful info from messy tables.
-- CREATE TABLE hot_skills_top_10 AS 
WITH hot_skills AS (
    SELECT COUNT(job_id) AS job_count,
        skill_id
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY job_count DESC
    LIMIT 10
)
SELECT hot_skills.skill_id,
    skills_dim.skills AS skill_name,
    skills_dim.type AS skill_type,
    hot_skills.job_count AS job_count
FROM hot_skills
    LEFT JOIN skills_dim ON hot_skills.skill_id = skills_dim.skill_id
ORDER BY job_count DESC  