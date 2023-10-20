-- ### App Trader

-- Your team has been hired by a new company called App Trader to help them explore and gain insights from apps that are made available through the Apple App Store and Android Play Store. App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchase. 

-- Unfortunately, the data for Apple App Store apps and Android Play Store Apps is located in separate tables with no referential integrity.

-- #### 1. Loading the data
-- a. Launch PgAdmin and create a new database called app_trader.  

-- b. Right-click on the app_trader database and choose `Restore...`  

-- c. Use the default values under the `Restore Options` tab. 

-- d. In the `Filename` section, browse to the backup file `app_store_backup.backup` in the data folder of this repository.  

-- e. Click `Restore` to load the database.  

-- f. Verify that you have two tables:  
--     - `app_store_apps` with 7197 rows  
--     - `play_store_apps` with 10840 rows

-- #### 2. Assumptions

-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.
    
-- - For example, an app that costs $2.00 will be purchased for $20,000.
    
-- - The cost of an app is not affected by how many app stores it is on. A $1.00 app on the Apple app store will cost the same as a $1.00 app on both stores. 
    
-- - If an app is on both stores, it's purchase price will be calculated based off of the highest app price between the two stores. 

-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.
    
-- - An app that costs $200,000 will make the same per month as an app that costs $1.00. 

-- - An app that is on both app stores will make $10,000 per month. 

-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
-- - An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.

-- c. Submit a report based on your findings. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report. 

-- updated 2/18/2023

SELECT distinct name, 
	a.price, 
 	p.price,
	AVG(a.rating + p.rating) OVER () AS avg_rating
FROM app_store_apps a
INNER JOIN play_store_apps p
USING (name)
--GROUP BY name
ORDER BY avg_rating desc

-- SELECT name, 
-- 	ROUND(AVG(a.rating + p.rating),2) AS avg_rating,
	
-- FROM app_store_apps a
-- INNER JOIN play_store_apps p
-- USING (name)
-- GROUP BY name
-- ORDER BY avg_rating desc

SELECT COUNT(DISTINCT a.primary_genre), COUNT(DISTINCT p.genres)
FROM app_store_apps a
INNER JOIN play_store_apps p
USING (name)
--a: 22 a.genre, 57 p.genre

--SEAN'S RATING, LIFESPAN 
--I ADDED GENRE AND PRICING ** WANT TO CHANGE AND COLLECT CONTENT RATING FOR GENRES
SELECT DISTINCT(name),
--	app_store_apps.rating, 
--	play_store_apps.rating, 
	ROUND(((app_store_apps.rating + play_store_apps.rating) / 2),1) as combined_rating, 
	ROUND((2*((app_store_apps.rating + play_store_apps.rating) / 2)/2*2+1),2) as lifespan,
	app_store_apps.primary_genre,
	app_store_apps.price,
	play_store_apps.price
--	
--	RANK() OVER(((app_store_apps.rating + play_store_apps.rating) / 2)) as comb_rating_rank
--cant get rank above to work
FROM app_store_apps 
INNER JOIN play_store_apps 
USING (name)
ORDER BY combined_rating DESC

--SEAN'S SYNICING OF PRICES
SELECT
    DISTINCT(name),
	ROUND(((a.rating + p.rating) / 2),1) as combined_rating, 
	ROUND((2*((a.rating + p.rating) / 2)/2*2+1),2) as lifespan,
	a.primary_genre AS a_genre,
	p.genres AS p_genre,
	a.content_rating AS a_content_rating,
	p.content_rating AS p_content_rating,
	CAST(a.review_count AS int) AS a_review_count_num,
	p.review_count AS p_review_count,
	CAST(REPLACE(REPLACE(p.price, '$', ''), ',', '') AS DECIMAL(5, 2)) AS price_numeric,
	a.price
FROM play_store_apps p
LEFT JOIN app_store_apps a
USING (name)
WHERE primary_genre IS NOT NULL
ORDER BY price_numeric DESC

--goal: make sum of review counts
select 
	COALESCE(CAST(a.review_count AS int),'0') AS a_review_count_num,
--	COALESCE(a.review_count,'0'),
	p.review_count AS p_review_count,
	(COALESCE(CAST(a.review_count AS int),'0') + p.review_count) AS sum_review
FROM play_store_apps p
LEFT JOIN app_store_apps a
USING (name)
WHERE (CAST(a.review_count AS int) + p.review_count >=100)
ORDER BY sum_review DESC

--add to previous statement

SELECT
    DISTINCT(name),
	ROUND(((a.rating + p.rating) / 2),1) as combined_rating, 
	ROUND((2*((a.rating + p.rating) / 2)/2*2+1),2) as lifespan,
	a.primary_genre AS a_genre,
	p.genres AS p_genre,
	a.content_rating AS a_content_rating,
	p.content_rating AS p_content_rating,
	(COALESCE(CAST(a.review_count AS int),'0') + p.review_count) AS total_review,
	CAST(AVG(CAST(REPLACE(REPLACE(p.price, '$', ''), ',', '') AS DECIMAL(5, 2)) +
	a.price) OVER () AS money) AS avg_price
FROM play_store_apps p
LEFT JOIN app_store_apps a
USING (name)
WHERE primary_genre IS NOT NULL
	AND (CAST(a.review_count AS int) + p.review_count >=100)
ORDER BY combined_rating DESC

---goal: make 1 rating column
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

--below look at ratings across tables/review counts to add to above
select distinct(p.content_rating), a.content_rating
FROM play_store_apps p
LEFT JOIN app_store_apps a
USING (name)
WHERE (COALESCE(CAST(a.review_count AS int),'0') + p.review_count) >=50000

--join with running table
WITH total_rating AS (
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
)
SELECT
    DISTINCT(name),
	ROUND(((a.rating + p.rating) / 2),1) as combined_rating, 
	ROUND((2*((a.rating + p.rating) / 2)/2*2+1),2) as lifespan,
	a.primary_genre AS a_genre,
	p.genres AS p_genre,
--	a.content_rating AS a_content_rating,
--	p.content_rating AS p_content_rating,
	new_content_rating
--	(COALESCE(CAST(a.review_count AS int),'0') + p.review_count) AS total_review
--MONEY ALL GIVES .11??
--	CAST(AVG(CAST(REPLACE(REPLACE(p.price, '$', ''), ',', '') AS DECIMAL(5, 2)) +
--	a.price) OVER () AS money) AS avg_price
FROM play_store_apps p
LEFT JOIN app_store_apps a
	USING (name)
LEFT JOIN total_rating
	USING (name)
WHERE primary_genre IS NOT NULL
	AND (CAST(a.review_count AS int) + p.review_count >=50000)
ORDER BY combined_rating DESC
LIMIT 15;

---sean's new one below
WITH combined_apps AS (
    SELECT
        app.name,
        app.price AS apple_price,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
        app.rating AS apple_rating,
        play.rating AS android_rating
--		app.review_count as apple_review_count,
--		(CAST(REGEXP_REPLACE(app.review_count, '[^0-9.]', '', 'g'),'0') AS NUMERIC) AS apple_review_count
    FROM
        app_store_apps AS app
    INNER JOIN
        play_store_apps play ON app.name = play.name
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
    DISTINCT rev.name,
    purchase_price,
    total_revenue,
    ROUND((total_revenue - purchase_price) / 10) * 10 AS net_profit
--	(COALESCE(CAST(app.review_count AS int),'0') + play.review_count) AS total_review
FROM
    revenues rev
INNER JOIN play_store_apps play
	ON rev.NAME = play.name
INNER JOIN app_store_apps app
	 ON app.name = play.name
--HAVING (COALESCE(CAST(app.review_count AS int),'0') + play.review_count) >= 50000
ORDER BY
    net_profit DESC
LIMIT 25
;

--new running script
WITH combined_apps AS (
    SELECT
        app.name,
        app.price AS apple_price,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
        app.rating AS apple_rating,
        play.rating AS android_rating,
		
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
	
--aaron's overview table w my edits
WITH combined_apps AS (
	SELECT
        play.name,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
     	play.rating AS android_rating,
		ROUND(play.review_count/1000*1000) AS android_review_count,
		app.price AS apple_price,
		app.rating AS apple_rating,
		ROUND(CAST(REGEXP_REPLACE(app.review_count, '[^0-9.]', '', 'g') AS NUMERIC)/1000*1000) AS apple_review_count,
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
        (ROUND(apple_rating + COALESCE(randroid_rating, 0)/2*2)) / 2 AS avg_rating
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
SELECT DISTINCT(name), android_price, ROUND(android_rating/2*), android_review_count, apple_price, apple_rating, apple_review_count, lifespan_years, normalized_apps.max_price, normalized_apps.avg_rating, content_rating, total_revenue, purchase_price, COALESCE(ROUND((total_revenue - purchase_price) / 10),0) * 10 AS net_profit,
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
LIMIT 15;


