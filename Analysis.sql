Use netflix;

-- 1. Count the number of Movies vs TV Shows
SELECT 
    type, COUNT(*)
FROM
    netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (SELECT type, rating, COUNT(*) AS rating_count FROM netflix GROUP BY type, rating )
SELECT type, rating AS most_frequent_rating FROM ( SELECT type, rating, rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rak
    FROM RatingCounts
) AS RankedRatings
WHERE rak = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix 
WHERE release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1)) AS country
    FROM netflix 
    CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) n
    WHERE LENGTH(country) - LENGTH(REPLACE(country, ',', '')) >= n.n - 1
) AS country_list
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT * 
FROM netflix 
WHERE type = 'Movie' 
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

-- 6. Find content added in the last 5 years
SELECT * 
FROM netflix 
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT * 
FROM (
    SELECT *, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', n.n), ',', -1)) AS director_name
    FROM netflix 
    CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) n
    WHERE LENGTH(director) - LENGTH(REPLACE(director, ',', '')) >= n.n - 1
) AS director_list
WHERE director_name = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
SELECT * 
FROM netflix 
WHERE type = 'TV Show' 
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 9. Count the number of content items in each genre
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre, COUNT(*) AS total_content
FROM netflix 
CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) n
WHERE LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', '')) >= n.n - 1
GROUP BY genre;

-- 10. Find each year and the average number of content releases by India on Netflix (top 5 years)
SELECT release_year, COUNT(*) AS total_release, 
ROUND(COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%') * 100, 2) AS avg_release
FROM netflix 
WHERE country LIKE '%India%' 
GROUP BY release_year 
ORDER BY avg_release DESC 
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT * 
FROM netflix 
WHERE listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT * 
FROM netflix 
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years
SELECT * 
FROM netflix 
WHERE casts LIKE '%Salman Khan%' 
AND release_year > YEAR(CURDATE()) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n.n), ',', -1)) AS actor, COUNT(*) AS total_movies
FROM netflix 
CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) n
WHERE LENGTH(casts) - LENGTH(REPLACE(casts, ',', '')) >= n.n - 1 
AND country LIKE '%India%'
GROUP BY actor 
ORDER BY total_movies DESC 
LIMIT 10;

-- 15. Categorize content based on 'kill' and 'violence' in description
SELECT category, type, COUNT(*) AS content_count
FROM (
    SELECT *,
    CASE 
        WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category
    FROM netflix
) AS categorized_content
GROUP BY category, type;
