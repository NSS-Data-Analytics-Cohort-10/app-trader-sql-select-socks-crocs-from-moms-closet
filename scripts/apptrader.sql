SELECT name, (ROUND(2 * avg(rating))/2*2+1) as lifespan_years
FROM app_store_apps
GROUP BY name
ORDER BY lifespan_years DESC


-- inner join names, average rating and rating per store
SELECT DISTINCT(name), app_store_apps.rating, play_store_apps.rating, ((app_store_apps.rating + play_store_apps.rating) / 2) as combined_rating	
FROM app_store_apps
INNER JOIN play_store_apps
USING (name)
ORDER BY name ASC	
	
--LIFESPAN

	
	
	
	
	
SELECT DISTINCT(name), app_store_apps.rating, play_store_apps.rating, (ROUND(2 * avg(rating))/2*2+1) as lifespan_years
FROM app_store_apps
INNER JOIN play_store_apps
USING (name)
ORDER BY name ASC