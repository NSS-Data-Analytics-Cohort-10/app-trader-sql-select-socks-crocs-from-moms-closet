SELECT name, (ROUND(2 * avg(rating))/2*2+1) as lifespan_years
FROM app_store_apps
GROUP BY name
ORDER BY lifespan_years DESC


-- inner join names, average rating and rating per store, lifespan
SELECT DISTINCT(name), app_store_apps.rating, play_store_apps.rating, ((app_store_apps.rating + play_store_apps.rating) / 2) as combined_rating, (2*((app_store_apps.rating + play_store_apps.rating) / 2)/2*2+1) as lifespan
FROM app_store_apps 
INNER JOIN play_store_apps 
USING (name)
ORDER BY name ASC	
	
-- other avg rating between both, 
(apple.rating + IFNULL(play.rating, 0)) / (1 + (b.app_title IS NOT NULL)) AS avg_rating
	
	
	
	
	
SELECT DISTINCT(name), app_store_apps.rating, play_store_apps.rating, (ROUND(2 * avg(rating))/2*2+1) as lifespan_years
FROM app_store_apps
INNER JOIN play_store_apps
USING (name)
ORDER BY name ASC

--- how to get numbers from the string in the app store
SELECT
        a.name,
        a.price AS apple_price,
        CAST(REGEXP_REPLACE(b.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
        a.rating AS apple_rating,
        b.rating AS android_rating
    FROM
        app_store_apps a
    INNER JOIN
        play_store_apps b ON a.name = b.name