CREATE DATABASE projects;

USE projects;

SELECT *
FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL; #changing column name

DESCRIBE hr;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END; #changing birthdate format and keeping all data in one standart format

ALTER TABLE hr
MODIFY COLUMN birthdate DATE; #changing birthdate data type

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END; #changing hire_date format

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT MIN(age) AS youngest, MAX(age) AS oldest
FROM hr;

SELECT COUNT(*)
FROM hr
WHERE age < 18;


#---------- QUESTIONS ---------------

#1. GENDER BREAKDOWN OF EMPLOYESS IN THE COMPANY ?

SELECT gender, count(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY gender;


#2. WHAT IS THE RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY?

SELECT race, count(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count(*) DESC;

#3. AGE DISTRIBUTION OF THE EMPLOYESS

SELECT MIN(age) AS youngest, MAX(age) AS oldest
FROM hr
WHERE age>=18 AND termdate = '0000-00-00';


SELECT CASE
	WHEN age >=18 AND age <= 24 THEN '18-24'
    WHEN age >=25 AND age <= 34 THEN '25-34'
    WHEN age >=35 AND age <= 44 THEN '35-44'
    WHEN age >=45 AND age <= 54 THEN '45-54'
    WHEN age >=55 AND age <= 64 THEN '55-64'
    ELSE '65+'
END AS age_group,
COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;




SELECT CASE
	WHEN age >=18 AND age <= 24 THEN '18-24'
    WHEN age >=25 AND age <= 34 THEN '25-34'
    WHEN age >=35 AND age <= 44 THEN '35-44'
    WHEN age >=45 AND age <= 54 THEN '45-54'
    WHEN age >=55 AND age <= 64 THEN '55-64'
    ELSE '65+'
END AS age_group, gender,
COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;
    
    
#4. HOW MANY EMPLOYESS WORK AT HEADQUARTERS VERSUS REMOTE?

SELECT location, COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY location;


#5. WHAT IS THE AVG LENGHT OF EMPLOYESS WHO HAVE BEEN TERMINATED?

SELECT ROUND(AVG(datediff(termdate, hire_date)) / 365, 0) AS avg_length_employment_year
FROM hr
WHERE  termdate <= curdate() AND termdate != '0000-00-00' AND age >= 18;


#6. HOW DOES GENDER DISTRIBUTION VARY ACROSS DEPARTMENTS AND JOB TITLES?

SELECT department, gender, COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP by department, gender
ORDER BY department;

#7. WHAT IS THE DISTR OF JOB TITLES ACROSS THE COMPANY?

SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

#8. WHICH DEPARTMENT HAS THE HIGHEST TURNOVER RATE?

SELECT department, total_count, terminated_count, terminated_count / total_count AS  termination_rate
FROM (
	SELECT department, COUNT(*) AS total_count,
    SUM(CASE WHEN termdate != '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS sub
ORDER BY termination_rate DESC;

#9. DISTR OF EMPLOYEES ACROSS LOCATIONS BY CITY AND STATE?

SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00' 
GROUP BY location_state
ORDER BY COUNT(*) DESC;

#10. how has the company's employee count changed over tikme based on hire and term dates?

SELECT year, 
hires, 
terminations, 
hires - terminations AS net_change, 
ROUND((hires - terminations)/hires * 100, 2)  AS net_change_percent
FROM (
	SELECT YEAR(hire_date) AS year,
    COUNT(*) AS hires,
    SUM(CASE WHEN termdate != '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
    GROUP BY YEAR(hire_date)
    ) AS sub
ORDER BY year ASC;


#11. WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT ?

SELECT department, ROUND(AVG(datediff(termdate, hire_date) / 365), 0 ) AS avg_tenure
FROM  hr
WHERE termdate <= curdate() AND termdate != '0000-00-00' AND age >= 18
GROUP BY department;
    
