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
        ROUND((lifespan_years * 12 * 10000 - (lifespan_years * 12 * 1000)) / 10) * 10 AS total_revenue,
        ROUND(10000 * CASE WHEN max_price <= 1 THEN 1 ELSE max_price END / 10) * 10 AS purchase_price
    FROM
        lifespan
)
SELECT
    distinct name,
    cast(purchase_price as money),
    cast(total_revenue as money),
    cast(ROUND((total_revenue - purchase_price) / 10) * 10 as money) AS net_profit,
	lifespan_years,
	normalized_apps.avg_rating
FROM
    revenues
inner join lifespan
using (name)
inner join normalized_apps
using (name)
ORDER BY
    net_profit DESC
LIMIT 10;


--add if app is on both app stores
--add marketing cost
--add lifespan

--1. determine the purchase price of the app
--2. determine if app is on both app stores (use inner joing)
--3. cost to market
--4. lifespan of the app 
--5. roi over 5 years?
--revenue on app


select a.name, a.price as app_price, CAST(REPLACE(REPLACE(p.price, '$', ''), ',', '') AS DECIMAL(5, 2)) AS price_numeric, a.rating as app_rating, p.rating as play_rating

from app_store_apps a
inner join play_store_apps p
using (name)
where a.price between 0 and 1 or  CAST(REPLACE(REPLACE(p.price, '$', ''), ',', '') AS DECIMAL(5, 2)) between 0 and 1
and a.rating=5.0 or p.rating=5.0
order by a.rating desc, p.rating desc

-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.

-- c. Submit a report based on your findings. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report. 


select 
case when name in app_store_apps and play_store_apps then ROUND((lifespan_years * 12 * 10000 - (lifespan_years * 12 * 1000)) / 10) * 10 AS total_revenue,
when ROUND((lifespan_years * 12 * 5000 - (lifespan_years * 12 * 1000)) / 10) * 10 AS total_revenue

