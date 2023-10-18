SELECT COUNT (DISTINCT name)
FROM app_store_apps

SELECT name, COUNT(name) 
FROM app_store_apps
GROUP BY name
HAVING COUNT(name) > 1

SELECT *
FROM play_store_apps

SELECT name, COUNT(name) 
FROM play_store_apps
GROUP BY name
HAVING COUNT(name) > 1


-- Convert play store price to numeric

SELECT *
FROM play_store_apps
LEFT JOIN app_store_apps




SELECT 
    price,
    CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS DECIMAL(5, 2)) AS price_numeric
FROM play_store_apps
ORDER BY price_numeric DESC

SELECT price_numeric

