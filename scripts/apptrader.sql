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

---- OVERVIEW
SELECT DISTINCT(name),
	ROUND(((a.rating + p.rating) / 2),1) as combined_rating,
	ROUND((2*((a.rating + p.rating) / 2)/2*2+1),2) as lifespan,
	a.primary_genre AS a_genre,
	p.genres AS p_genre,
	a.content_rating AS a_content_rating,
	p.content_rating AS p_content_rating,
	 CAST(REPLACE(REPLACE(p.price, '$', ''), ',', '') AS DECIMAL(5, 2)) AS price_numeric
FROM play_store_apps p
LEFT JOIN app_store_apps a
USING (name)
WHERE primary_genre IS NOT NULL
ORDER BY combined_rating DESC

----- THE BIG Ol' QUERY
WITH combined_apps AS (
    SELECT
        app.name,
        app.price AS apple_price,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
        app.rating AS apple_rating,
        play.rating AS android_rating,
		app.review_count as apple_review_count,
		CAST(REGEXP_REPLACE(app.review_count, '[^0-9.]', '', 'g') AS NUMERIC) AS apple_review_count
	
    FROM
       play_store_apps AS play  
    LEFT JOIN
       app_store_apps AS app ON play.name = app.name
	
),
normalized_apps AS (
    SELECT
        name,
        GREATEST(apple_price, COALESCE(android_price, 0)) AS max_price,
        (apple_rating + COALESCE(android_rating, 0)) / 2 AS avg_rating
    FROM
        combined_apps
),
lifespan AS (
    SELECT
        *,
        ROUND(2 * avg_rating) / 2 * 2 + 1 AS lifespan_years
    FROM
        normalized_apps
),
revenues AS (
    SELECT
        name,
        ROUND((lifespan_years * 12 * 5000 - (lifespan_years * 12 * 1000)) / 10) * 10 AS total_revenue,
        ROUND(10000 * CASE WHEN max_price <= 1 THEN 1 ELSE max_price END / 10) * 10 AS purchase_price
    FROM
        lifespan
)
SELECT
    DISTINCT(name),
    purchase_price,
    total_revenue,
    ROUND((total_revenue - purchase_price) / 10) * 10 AS net_profit
FROM
    revenues
WHERE name IS NOT NULL
ORDER BY
    net_profit DESC
-- LIMIT 10;



