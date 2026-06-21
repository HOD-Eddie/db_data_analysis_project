SELECT *
FROM january_jobs
WHERE salary_year_avg IS NOT NULL
UNION
SELECT *
FROM february_paying_jobs
ORDER BY job_posted_date;