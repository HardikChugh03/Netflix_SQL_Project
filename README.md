# Netflix Dataset Analysis using SQL
![Netflix Logo](https://github.com/HardikChugh03/Netflix_SQL_Project/blob/main/Netflix_logo.jpg)

## Overview
This project presents a comprehensive SQL-based analysis of Netflix’s movies and TV shows dataset. Using a series of structured SQL queries, the project explores key aspects of Netflix’s content library — including content distribution, ratings, release trends, country-wise insights, and genre categorisations.

The goal is to uncover actionable insights and answer critical business questions related to Netflix’s content strategy and audience preferences.
This repository includes:
- SQL scripts used for data exploration and analysis.
- Detailed explanations of each query and its purpose.
- Key findings and visual summaries of results.

## Objectives
- **Content Distribution:** Examine the proportion of movies and TV shows in the dataset.
- **Ratings Analysis:** Identify and compare the most common ratings across movies and TV shows.
- **Release and Regional Insights:** Analyse content trends by release year, country of origin, and duration.
- **Content Categorisation:** Explore and group titles based on defined criteria and relevant keywords.

## Dataset
The data for this project is sourced from the Kaggle dataset:
> Dataset Link: [Netflix Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Learning Credits
> Zero Analyst: [Project Video](https://www.youtube.com/watch?v=-7cT0651_lw&list=WL&index=2&t=1058s)

## Schema

```sql
CREATE TABLE netflix
(
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
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, count(type)
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT type, rating
FROM (
SELECT type, rating, count(rating),
RANK() OVER(PARTITION BY type ORDER BY count(rating) DESC) as ranking
FROM netflix
GROUP BY type, rating
) as table_1
WHERE ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in 2019

```sql
SELECT type, title, release_year
FROM netflix
WHERE release_year = 2019
AND type = 'Movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))),
count(title)
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT title, duration
FROM netflix
WHERE type ='Movie'
AND duration =
(SELECT
MAX(duration)
FROM netflix);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql

SELECT title, date_added FROM
(SELECT title, date_added, TO_DATE(date_added, 'Month DD, YYYY') AS date
FROM netflix) AS t1
WHERE t1.date >= CURRENT_DATE - INTERVAL '5 YEARS'
ORDER BY date;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT title, director, type
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 4 Seasons

```sql
SELECT title, duration FROM
(SELECT title, type, duration, CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS ssn
FROM netflix) AS t1
WHERE type = 'TV Show'
AND ssn > 4
ORDER BY ssn DESC;
```

**Objective:** Identify TV shows with more than 4 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))),
COUNT(*)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;
```

**Objective:** Count the number of content items in each genre.

### 10. For each year, find the number of content released in India

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT title, type, listed_in
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

-- OR

SELECT title, type, genre FROM
(SELECT *,
TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre FROM netflix)
WHERE genre = 'Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE cast1 ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(cast1, ','))) AS actor,
count(*) AS no_of_movies
FROM netflix
WHERE type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
OFFSET 2;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorise Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorise content as 'Violent' if it contains 'kill' or 'violence' and 'Other' otherwise. Count the number of items in each category.


## Findings and Conclusion

- **Content Distribution:** The dataset showcases a diverse collection of movies and TV shows, highlighting Netflix’s broad range of genres and formats.
- **Common Ratings:** An analysis of the most frequent ratings reveals valuable insights into Netflix’s target audience and their preferred content maturity levels.
- **Geographical Insights:** Country-wise analysis, particularly the strong presence of content from India and other top-producing regions, illustrates Netflix’s global reach and regional focus.
- **Content Categorisation:** Grouping titles by keywords and themes provides a deeper understanding of content trends, popular topics, and genre diversity across the platform.

_Overall, this analysis provides a comprehensive overview of Netflix’s content landscape, offering meaningful insights that can inform data-driven decisions, content strategy, and market positioning within the streaming industry._
