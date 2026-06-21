-- In this section, I worked as an aspiring Data Analyst, and I manipulated my dataset to 
-- to display the top 10 paying jobs for a specified job role. 
-- My query is also optimized to return the jobs based on a given location.
-- DELIVERABLES
--  this query answers the question, "What are the top-paying jobs for my role?"
-- Identify the top 10 highest-paying job posts for specified roles, and also a specified location criterion
-- focus only on jobs with specified annual salaries
--  
SELECT job_title_short,
    job_location,
    salary_year_avg,
    company_dim.name AS company,
    job_schedule_type,
    job_posted_date::DATE -- this is to only return the date part of this timestamp field.
FROM job_postings_fact
    LEFT JOIN company_dim -- left join because I want to retain the current information returned
    -- for my top paying jobs and only get the companies from the company_dim table that match these jobs
    ON job_postings_fact.company_id = company_dim.company_id
WHERE -- job_title_short IN ('Data Analyst', 'Data Scientist', 'Data Engineer')
    -- With the line above, we can return the result for different role categories.
    job_title_short = 'Data Scientist'
    AND salary_year_avg IS NOT NULL -- AND job_location = 'Anywhere'
ORDER BY -- job_title_short,
    salary_year_avg DESC
LIMIT 10;
-- LIMIT 10 to match the top 10, based on yearly average salary
