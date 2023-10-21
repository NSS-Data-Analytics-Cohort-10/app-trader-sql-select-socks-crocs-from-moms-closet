select *
FROM play_store_apps

Select *
from app_store_apps

Select price, name, content_rating
From app_store_apps

SELECT size_bytes
FROM app_stores_apps

SELECT primary_genre
FROM app-store_apps

SELECT name, category, rating
FROM play_store_apps

SELECT name MAX(price)
FROM app_store_apps
--
SELECT DISTINCT(name), app_store_apps.rating, play_store_apps.rating, ((app_store_apps.rating + play_store_apps.rating) / 2) as combined_rating, (2*((app_store_apps.rating + play_store_apps.rating) / 2)/2*2+1) as lifespan
FROM app_store_apps
INNER JOIN play_store_apps
USING (name)
ORDER BY name ASC

--lifespan and combined ratings for both stores, our team is looking at lifespan and think this might be a factor in our decision making

SELECT
    price,
    CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS DECIMAL(5, 2)) AS price_numeric
FROM play_store_apps
ORDER BY price_numeric DESC

--convert playstore price to numeric, our team decided it was strings and we needed to convert

SELECT CAST(REGEXP_REPLACE('abc123def', '[^\d]', '', 'g') AS INTEGER) AS cleaned_integer;

--cleaning integers, we discussed how to do this and have an article

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

--comparison of apple/android prices and apple/android ratings

--WITH total_rating AS (
	SELECT
	p.name,
	CASE WHEN a.content_rating = '4+' THEN 'Everyone'
	WHEN a.content_rating = '9+' THEN 'Everyone'
	WHEN a.content_rating = '12+' THEN 'Teen'
	WHEN a.content_rating = '17+' THEN 'Teen'
	END AS new_content_rating
FROM play_store_apps p
LEFT JOIN app_store_apps a
	USING (name)
--
SELECT
        app.name,
        app.price AS apple_price,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
        app.rating AS apple_rating,
        play.rating AS android_rating,
		app.review_count as apple_review_count,
		CAST(REGEXP_REPLACE(app.review_count, '[^0-9.]', '', 'g') AS NUMERIC) AS apple_review_count
    FROM
        app_store_apps AS app
    INNER JOIN
        play_store_apps play ON app.name = play.name
		
--
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
    name,
    purchase_price,
    total_revenue,
    ROUND((total_revenue - purchase_price) / 10) * 10 AS net_profit
FROM
    revenues
ORDER BY
    net_profit DESC
LIMIT 10;

-- with total rating as (worked with team)
SELECT
	p.name,
	CASE WHEN a.content_rating = '4+' THEN 'Everyone'
	WHEN a.content_rating = '9+' THEN 'Everyone'
	WHEN a.content_rating = '12+' THEN 'Teen'
	WHEN a.content_rating = '17+' THEN 'Teen'
	END AS new_content_rating
FROM play_store_apps p
LEFT JOIN app_store_apps a
	USING (name)

-- team effort
WITH combined_apps AS (
	SELECT
        play.name,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
     	play.rating AS android_rating,
		play.review_count AS android_review_count,
		app.price AS apple_price,
		app.rating AS apple_rating,
		CAST(REGEXP_REPLACE(app.review_count, '[^0-9.]', '', 'g') AS NUMERIC) AS apple_review_count
	FROM
        play_store_apps AS play
    LEFT JOIN
        app_store_apps AS app ON app.name = play.name
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
SELECT DISTINCT(name), android_price, android_rating, android_review_count, apple_price, apple_rating, apple_review_count, lifespan_years, normalized_apps.max_price, normalized_apps.avg_rating, total_revenue, purchase_price, COALESCE(ROUND((total_revenue - purchase_price) / 10),0) * 10 AS net_profit,
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
ORDER BY net_profit DESC

--

SELECT p.name,
	CASE WHEN a.content_rating = '4+' THEN 'Everyone'
	WHEN a.content_rating = '9+' THEN 'Everyone'
	WHEN a.content_rating = '12+' THEN 'Teen'
	WHEN a.content_rating = '17+' THEN 'Teen'
	END AS new_content_rating
FROM play_store_apps p
LEFT JOIN app_store_apps a
USING (name)
order by new_content_rating

-- WHERE android_rating > 0 AND apple_rating > 0

WITH combined_apps AS (
	SELECT
		play.name,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
     	play.rating AS android_rating,
		play.review_count AS android_review_count,
		app.price AS apple_price,
		app.rating AS apple_rating,
		app.content_rating AS app_content_rating,
		play.content_rating AS play_content_rating,
		primary_genre,
		install_count,
		CAST(REGEXP_REPLACE(app.review_count, '[^0-9.]', '', 'g') AS NUMERIC) AS apple_review_count,	
		CAST(REGEXP_REPLACE(play.install_count, '[^0-9.]', '', 'g') AS NUMERIC) AS play_install_count
	FROM
        play_store_apps AS play
    LEFT JOIN
        app_store_apps AS app ON app.name = play.name
),
normalized_apps AS (
    SELECT
        name,
        GREATEST(apple_price, COALESCE(android_price, 0)) AS max_price,
        ROUND((apple_rating + COALESCE(android_rating, 0)) / 2 * 2,0)/2 AS avg_rating
    FROM
        combined_apps
),
new_content_rating AS (
    SELECT
        play.name,
        CASE WHEN app.content_rating = '4+' THEN 'Everyone'
		WHEN app.content_rating = '9+' THEN 'Everyone'
		WHEN app.content_rating = '12+' THEN 'Teen'
		WHEN app.content_rating = '17+' THEN 'Teen'
		END AS new_content_rating
	FROM
        play_store_apps AS play
    LEFT JOIN
        app_store_apps AS app ON app.name = play.name
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
SELECT DISTINCT android_price, android_rating, MAX(android_review_count) AS max_android_review_count, apple_price, apple_rating, apple_review_count, lifespan_years, normalized_apps.max_price, normalized_apps.avg_rating, total_revenue, purchase_price, new_content_rating, name, COALESCE(ROUND((total_revenue - purchase_price) / 10),0) * 10 AS net_profit, primary_genre, install_count, play_install_count,
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
LEFT JOIN new_content_rating
USING (name)
GROUP BY name, android_price, android_rating, apple_price, apple_rating, apple_review_count, lifespan_years, normalized_apps.max_price, normalized_apps.avg_rating, total_revenue, purchase_price, net_profit, new_content_rating, primary_genre, install_count, play_install_count
ORDER BY net_profit DESC, play_install_count DESC

--working with team to help explain