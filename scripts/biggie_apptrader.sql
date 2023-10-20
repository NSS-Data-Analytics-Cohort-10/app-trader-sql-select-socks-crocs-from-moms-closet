WITH combined_apps AS (
	SELECT
        play.name,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
     	play.rating AS android_rating,
		play.review_count AS android_review_count,
		app.price AS apple_price,
		app.rating AS apple_rating,	
		primary_genre,
		install_count,
-- 		round(((apple_rating + COALESCE(android_rating, 0)) / 2)*2,0)/2 AS avg_rating,
		CAST(REGEXP_REPLACE(app.review_count, '[^0-9.]', '', 'g') AS NUMERIC) AS apple_review_count, CAST(REGEXP_REPLACE(play.install_count, '[^0-9.]', '', 'g') AS NUMERIC) AS installs,
	
	CASE WHEN app.content_rating = '4+' THEN 'Everyone'
	WHEN app.content_rating = '9+' THEN 'Everyone'
	WHEN app.content_rating = '12+' THEN 'Teen'
	WHEN app.content_rating = '17+' THEN 'Teen'
	END AS content_rating
	FROM
        play_store_apps AS play
    LEFT JOIN
        app_store_apps AS app ON app.name = play.name
),
normalized_apps AS (
    SELECT
        name,
        GREATEST(apple_price, COALESCE(android_price, 0)) AS max_price,
        round(((apple_rating + COALESCE(android_rating, 0)) / 2)*2,0)/2 AS avg_rating
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
        ROUND((lifespan_years * 12 * 10000 - (lifespan_years * 12 * 1000)) / 10) * 10 AS total_revenue,
        ROUND(10000 * CASE WHEN max_price <= 1 THEN 1 ELSE max_price END / 10) * 10 AS purchase_price
    FROM
        lifespan
)
SELECT DISTINCT(name), android_price, android_rating, max(android_review_count) as max_android_review_count, apple_price, apple_rating, apple_review_count, lifespan_years, normalized_apps.max_price, normalized_apps.avg_rating, total_revenue, purchase_price, content_rating, COALESCE(ROUND((total_revenue - purchase_price) / 10),0) * 10 AS net_profit, primary_genre, installs,
	CASE
		WHEN android_rating > 0 AND apple_rating > 0 THEN 'Both Stores'
		ELSE 'One Store'
	END AS store_count
FROM combined_apps
LEFT JOIN lifespan
USING (name)
LEFT JOIN normalized_apps
USING (name)
LEFT JOIN revenues
USING (name)
GROUP BY android_price, android_rating, apple_price, apple_rating, apple_review_count, lifespan_years, normalized_apps.max_price, normalized_apps.avg_rating, total_revenue, purchase_price, combined_apps.name, content_rating, primary_genre, installs
ORDER BY net_profit DESC, installs DESC


























