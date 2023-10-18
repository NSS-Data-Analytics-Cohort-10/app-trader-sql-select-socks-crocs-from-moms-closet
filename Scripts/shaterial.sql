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

SELECT DISTINCT(name), app_store_apps.rating, play_store_apps.rating, ((app_store_apps.rating + play_store_apps.rating) / 2) as combined_rating, (2*((app_store_apps.rating + play_store_apps.rating) / 2)/2*2+1) as lifespan
FROM app_store_apps
INNER JOIN play_store_apps
USING (name)
ORDER BY name ASC

--lifespan and combined ratings for both stores, our team is looking at lifespan and think this might be a factor in our decision making