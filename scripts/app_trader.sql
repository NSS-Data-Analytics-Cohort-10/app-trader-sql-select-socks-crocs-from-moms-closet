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

select a.name, a.price, p.price

from app_store_apps as a
inner join play_store_apps as p
using (name)
where a.name = p.name
group by a.name, a.price, p.price
order by a.price desc


with fixed_price as
(SELECT
    price,
    CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS DECIMAL(5, 2)) AS price_numeric
FROM play_store_apps)




select a.name, a.price, fixed_price.price_numeric
from app_store_apps as a
inner join play_store_apps as p
using (name)
where a.name = p.name
group by a.name, a.price, fixed_price.price_numeric
order by a.price desc


--1. determine the purchase price of the app
--2. determine if app is on both app stores (use inner joing)
--3. cost to market
--4. lifespan of the app 
--5. roi over 5 years?
--revenue on app


SELECT name, app_store_apps.rating, play_store_apps.rating, ((app_store_apps.rating + play_store_apps.rating) / 2) as combined_rating, (2*((app_store_apps.rating + play_store_apps.rating) / 2)/2*2+1) as lifespan, app_store_apps.price, play_store_apps.price
FROM play_store_apps
INNER JOIN app_store_apps
USING (name)
ORDER BY name desc

select *
from app_store_apps
where name ilike '%zombie%'
order by name desc

select *
from play_store_apps
where name ilike '%facebook%'
order by name desc
-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.

-- c. Submit a report based on your findings. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report. 




