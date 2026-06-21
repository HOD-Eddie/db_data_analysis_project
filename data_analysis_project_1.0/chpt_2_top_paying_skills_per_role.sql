-- In this chapter, I am working to explore the skills required for the 
-- the top paying roles, I worked on in the first chapter.]
-- DELIVERABLES
-- my query basically answers the question, "What are the skills required for top paying roles?"
-- This answer helps job enthusiasts to what skills are the pre-requisites for their aspirations,
-- given their existing awareness on the top paying jobs for their desired -role.
-- A skills and skills_to_job data set would be useful for this case
SELECT top_paying_jobs.*,
    skills
FROM -- I used my first query as a subquery in this scenario, so I can extend the top paying jobs, and associate them with the
    -- required skills for this roles.
    (
        SELECT job_id,
            job_title_short,
            job_postings_fact.salary_year_avg AS avg_annual_salary,
            company_dim.name AS company
        FROM job_postings_fact
            LEFT JOIN company_dim -- left join because I want to retain the current information returned
            -- for my top paying jobs and only get the companies from the company_dim table that matches with these jobs
            ON job_postings_fact.company_id = company_dim.company_id
        WHERE -- job_title_short IN ('Data Analyst', 'Data Scientist', 'Data Engineer')
            -- with the line above, we can return result for different role categories.
            job_title_short = 'Data Engineer'
            AND salary_year_avg IS NOT NULL -- AND job_location = 'Anywhere'
        ORDER BY -- job_title_short,
            salary_year_avg DESC
        LIMIT 10
    ) AS top_paying_jobs
    JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id -- I used an inner join so we do not account for jobs from the subquery
    -- whose salaries are not specified. I want to return what matches strictly between all the tables.
    JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY avg_annual_salary DESC