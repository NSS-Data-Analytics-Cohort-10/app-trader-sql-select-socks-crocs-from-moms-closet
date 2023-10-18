SELECT name, (ROUND(2 * avg(rating))/2*2+1) as lifespan_years
FROM app_store_apps
GROUP BY name
ORDER BY lifespan_years DESC

--STILL WORKING ON THIS
-- inner join names, average rating and rating per store, lifespan
SELECT (name), app_store_apps.rating, play_store_apps.rating, app_store_apps.review_count, play_store_apps.review_count, ((app_store_apps.rating + play_store_apps.rating) / 2) as combined_rating, (2*((app_store_apps.rating + play_store_apps.rating) / 2)/2*2+1) as lifespan
FROM play_store_apps
inner join  app_store_apps 
USING (name)
ORDER BY name ASC

SELECT DISTINCT(name), app_store_apps.rating, play_store_apps.rating, ((app_store_apps.rating + play_store_apps.rating) / 2) as combined_rating, (2*((app_store_apps.rating + play_store_apps.rating) / 2)/2*2+1) as lifespan
FROM play_store_apps
inner join  app_store_apps 
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
		
-- Working on getting a total purchase price, this is head stuff, not meant to be run
(lifespan_years * 12 * 5000 - (lifespan_years * 12 * 1000)) / 10) * 10 AS total_revenue




