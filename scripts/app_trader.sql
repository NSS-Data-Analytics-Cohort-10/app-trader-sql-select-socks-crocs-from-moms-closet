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

WITH combined_apps AS (
	SELECT
        play.name,
        CAST(REGEXP_REPLACE(play.price, '[^0-9.]', '', 'g') AS NUMERIC) AS android_price,
     	play.rating AS android_rating,
		play.review_count AS android_review_count,
		app.price AS apple_price,
		app.rating AS apple_rating,
		primary_genre as genre,
		install_count,
		CAST(REGEXP_REPLACE(app.review_count, '[^0-9.]', '', 'g') AS NUMERIC) AS apple_review_count,
		CAST(REGEXP_REPLACE(play.install_count, '[^0-9.]', '', 'g') AS NUMERIC) AS play_install_count,
		CASE WHEN app.content_rating = '4+' THEN 'Everyone'
		WHEN app.content_rating = '9+' THEN 'Everyone'
		WHEN app.content_rating = '12+' THEN 'Teen'
		WHEN app.content_rating = '17+' THEN 'Age 17 and up'
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
SELECT DISTINCT(name), cast(android_price as money), android_rating, max(android_review_count) as android_review_count, cast(apple_price as money), apple_rating, max(apple_review_count) as apple_review_count, content_rating, genre, lifespan_years, cast(normalized_apps.max_price as money), normalized_apps.avg_rating, cast(total_revenue as money), cast(purchase_price as money), cast(COALESCE(ROUND((total_revenue - purchase_price) / 10),0) * 10 as money) AS net_profit,  install_count, play_install_count,
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
group by name, android_price, android_rating, apple_price, apple_rating, content_rating, genre, lifespan_years, normalized_apps.max_price, normalized_apps.avg_rating, total_revenue, purchase_price,net_profit,store_count,install_count, play_install_count
ORDER BY net_profit DESC,play_install_count DESC


