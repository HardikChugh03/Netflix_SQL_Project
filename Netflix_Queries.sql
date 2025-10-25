-- Netflix Project

CREATE TABLE netflix(
	show_id	VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(250),
	director VARCHAR(250),
	cast1 VARCHAR(1000),
	country VARCHAR(250),
	date_added VARCHAR(250),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(250),
	listed_in VARCHAR(250),
	description VARCHAR(250)
)

SELECT * FROM netflix;


-- Q1. Count the number of movies vs TV Shows

SELECT type, count(type)
FROM netflix
GROUP BY type;


-- Q2. Find the most common rating for movies and tv shows

SELECT type, rating
FROM (
SELECT type, rating, count(rating),
RANK() OVER(PARTITION BY type ORDER BY count(rating) DESC) as ranking
FROM netflix
GROUP BY type, rating
) as table_1
WHERE ranking = 1;


-- Q3. List all movies released in 2019

SELECT type, title, release_year
FROM netflix
WHERE release_year = 2019
AND type = 'Movie';


-- Q4. Find the top 5 countries with most content on Netflix

SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))), count(title)
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Q5. Identify the longest movie  duration

SELECT title, duration
FROM netflix
WHERE type ='Movie'
AND duration = (SELECT
MAX(duration)
FROM netflix);


-- Q6. Find the content added in last 5 years

SELECT title, date_added FROM
(SELECT title, date_added, TO_DATE(date_added, 'Month DD, YYYY') AS date
FROM netflix) AS t1
WHERE t1.date >= CURRENT_DATE - INTERVAL '5 YEARS'
ORDER BY date;



-- Q7. Find the content directed by 'Rajiv Chilaka'

SELECT title, director, type
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'


-- Q8. List all the TV Shows with more than 4 seasons

SELECT title, duration FROM
(
	SELECT title, type, duration, CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS ssn
	FROM netflix
) AS t1
WHERE type = 'TV Show'
AND ssn > 4
ORDER BY ssn DESC;


-- Q9. Count the number of content in each genre

SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))), count(*)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;


-- Q10. Find for each year number of content release in India

SELECT cntry, yr, release_no FROM
(SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS cntry,
TRIM(SPLIT_PART(date_added, ',', 2)) AS yr,
COUNT(*) AS release_no
FROM NETFLIX
GROUP BY 2, 1)
WHERE cntry = 'India'
ORDER BY 3 DESC;

-- OR

SELECT cntry, yr, release_no FROM
(SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS cntry,
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS yr,
COUNT(*) AS release_no
FROM netflix
GROUP BY 1, 2)
WHERE cntry = 'India'
ORDER BY 3 DESC;


-- Q11. List all the movies that are documentries

SELECT title, type, listed_in
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

-- OR

SELECT title, type, genre FROM
(SELECT *,
TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre FROM netflix)
WHERE genre = 'Documentaries';


-- Q12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;


-- Q13. Find in how many movies 'Salman Khan' appeared, in last 10 years

SELECT *
FROM netflix
WHERE cast1 ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- Q14. Find the top 10 actors who have appeared in highest number of movies except the first 2 actors

SELECT TRIM(UNNEST(STRING_TO_ARRAY(cast1, ','))) AS actor,
count(*) AS no_of_movies
FROM netflix
WHERE type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
OFFSET 2;


-- Q15. Categorize the content based on the presence of keywords 'kill' and 'violence' in the descricption
-- field. Label these content containing these keywords as 'Violent' and all other content as 'Other'. Count 
-- how many item fall into each category.

WITH t1 AS(
SELECT *,
CASE 
	WHEN description ILIKE '%Kill%'
	OR description ILIKE '%Violence%'
	THEN 'Violent'
	ELSE 'Other'
	END category
FROM netflix)
SELECT category, COUNT(*)
FROM t1
GROUP BY category;





