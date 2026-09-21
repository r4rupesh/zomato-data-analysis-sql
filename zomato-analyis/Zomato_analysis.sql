USE projects;
SELECT * FROM zomato_dataset;

-- ============================================================================
-- STEP 1: DATA CLEANING & PRE-PROCESSING
-- ============================================================================
-- 1.1 Identify and remove duplicate records based on RestaurantID

 WITH DuplicateValue AS (
 SELECT RestaurantID,
 ROW_NUMBER() OVER (PARTITION BY RestaurantID ORDER BY RestaurantID) AS RowNum
 FROM zomato_dataset)
 DELETE FROM zomato_dataset
 WHERE restaurantID IN 
 (SELECT restaurantID FROM DuplicateValue WHERE RowNum>1);
 
 -- 1.2 Handle NULL or empty string entries for Cuisines
UPDATE zomato_dataset
SET Cuisines = 'Unknown'
WHERE Cuisines IS NULL OR TRIM(Cuisines) = '';

-- 1.3 Convert unrated/placeholder ratings (Rating = 0) to NULL for accurate AVG calculations
UPDATE zomato_dataset
SET Rating=NULL
WHERE Rating=0;

-- 1.4 Trim whitespace from text fields
UPDATE zomato_dataset
SET RestaurantName = TRIM(RestaurantName),
    City = TRIM(City),
    Locality = TRIM(Locality);
-- 1.5 Standardize Yes/No boolean flags to uppercase
UPDATE zomato_dataset
SET Has_Table_booking = UPPER(TRIM(Has_Table_booking)),
    Has_Online_delivery = UPPER(TRIM(Has_Online_delivery)),
    Is_delivering_now = UPPER(TRIM(Is_delivering_now));
-- 1.6 Delete records with invalid numerical entries (e.g., negative cost values)
DELETE FROM zomato_dataset
WHERE Average_Cost_for_two<0;
-- 1.7 Drop uninformative/redundant columns
ALTER TABLE zomato_dataset
DROP COLUMN Switch_to_order_menu;

-- ============================================================================
-- STEP 2: EXPLORATORY DATA ANALYSIS (EDA)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q1: Top 10 cities with the highest restaurant presence
-- ----------------------------------------------------------------------------
 SELECT City,COUNT(RestaurantId) AS Total_Restaurent
 FROM zomato_dataset
 GROUP BY City
 ORDER BY Total_Restaurent DESC
 LIMIT 10;
 
 -- ----------------------------------------------------------------------------
-- Q2: Rating and Cost trends across Price Ranges
-- ----------------------------------------------------------------------------
SELECT Price_range,
COUNT(RestaurantID) AS Total_Restaurant,
ROUND(AVG(Rating),2) AS Avg_Rating,
ROUND(AVG(Average_Cost_for_two), 2) AS Avg_Cost_For_Two
FROM zomato_dataset
WHERE Rating IS NOT NULL
GROUP BY Price_range
ORDER BY Price_range;

-- ----------------------------------------------------------------------------
-- Q3: Impact of Online Delivery service on Ratings & Votes
-- ----------------------------------------------------------------------------
SELECT 
    Has_Online_delivery,
    COUNT(RestaurantID) AS Restaurant_Count,
    ROUND(AVG(Rating), 2) AS Avg_Rating,
    SUM(Votes) AS Total_Votes
FROM zomato_dataset
WHERE Rating IS NOT NULL
GROUP BY Has_Online_delivery;

-- ----------------------------------------------------------------------------
-- Q4: Table Booking influence on customer engagement
-- ----------------------------------------------------------------------------
SELECT 
    Has_Table_booking,
    COUNT(RestaurantID) AS Total_Restaurants,
    ROUND(AVG(Rating), 2) AS Avg_Rating,
    ROUND(AVG(Votes), 0) AS Avg_Votes
FROM zomato_dataset
WHERE Rating IS NOT NULL
GROUP BY Has_Table_booking;

-- ----------------------------------------------------------------------------
-- Q5: Top 5 highest-voted restaurants per city
-- ----------------------------------------------------------------------------

WITH RankedRestaurants AS(
SELECT City,RestaurantName,Votes,Rating,
DENSE_RANK() OVER (PARTITION BY City ORDER BY Votes DESC) AS Rank_num
FROM  zomato_dataset
)
SELECT City, RestaurantName, Votes, Rating,Rank_num
FROM RankedRestaurants
WHERE Rank_Num <= 5
ORDER BY City, Rank_Num;

-- ----------------------------------------------------------------------------
-- Q6: Most expensive localities per city (Top 5)
-- ----------------------------------------------------------------------------
WITH LocalityCosts AS(
 SELECT City,
 Locality,
 ROUND(AVG(Average_Cost_for_two),2) AS Avg_Cost,
 DENSE_RANK() OVER (PARTITION BY City ORDER BY AVG(Average_Cost_for_two)DESC)
 AS Cost_Rank
 FROM zomato_dataset
 WHERE Average_Cost_for_two>0
 GROUP BY City,Locality
 )
 SELECT City,Locality,Avg_Cost
 FROM LocalityCosts
 WHERE Cost_Rank <=5
 ORDER BY City,Cost_Rank;
 
 -- ----------------------------------------------------------------------------
-- Q7: Dual-service offering (Table Booking + Delivery) per Price Range
-- ----------------------------------------------------------------------------
SELECT 
    Price_range,
    COUNT(RestaurantID) AS Total_Restaurants,
    SUM(CASE WHEN Has_Table_booking = 'YES' AND Has_Online_delivery = 'YES' THEN 1 ELSE 0 END) AS Dual_Service_Count,
    ROUND(
        (SUM(CASE WHEN Has_Table_booking = 'YES' AND Has_Online_delivery = 'YES' THEN 1 ELSE 0 END) * 100.0) / COUNT(RestaurantID), 
        2
    ) AS Dual_Service_Percentage
FROM zomato_dataset
GROUP BY Price_range
ORDER BY Price_range;

-- ----------------------------------------------------------------------------
-- Q8: "High Rating, Low Cost" value restaurants per city
-- ----------------------------------------------------------------------------
WITH CityAverages AS (
    SELECT 
        City,
        AVG(Rating) AS City_Avg_Rating,
        AVG(Average_Cost_for_two) AS City_Avg_Cost
    FROM zomato_dataset
    WHERE Rating IS NOT NULL AND Average_Cost_for_two > 0
    GROUP BY City
)
SELECT 
    z.City,
    z.RestaurantName,
    z.Rating,
    z.Average_Cost_for_two,
    ROUND(ca.City_Avg_Rating, 2) AS City_Avg_Rating,
    ROUND(ca.City_Avg_Cost, 2) AS City_Avg_Cost
FROM zomato_dataset z
JOIN CityAverages ca ON z.City = ca.City
WHERE z.Rating > ca.City_Avg_Rating 
  AND z.Average_Cost_for_two < ca.City_Avg_Cost
ORDER BY z.City, z.Rating DESC;

-- ----------------------------------------------------------------------------
-- Q9: Single-Cuisine vs. Multi-Cuisine performance comparison
-- ----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN Cuisines LIKE '%|%' OR Cuisines LIKE '%,%' THEN 'Multi-Cuisine'
        ELSE 'Single-Cuisine'
    END AS Cuisine_Type,
    COUNT(RestaurantID) AS Total_Restaurants,
    ROUND(AVG(Rating), 2) AS Avg_Rating,
    ROUND(AVG(Votes), 0) AS Avg_Votes
FROM zomato_dataset
WHERE Rating IS NOT NULL
GROUP BY 
    CASE 
        WHEN Cuisines LIKE '%|%' OR Cuisines LIKE '%,%' THEN 'Multi-Cuisine'
        ELSE 'Single-Cuisine'
    END;
    
-- ----------------------------------------------------------------------------
-- Q10: Top 3 restaurants per currency with at least 100 votes
-- ----------------------------------------------------------------------------
WITH CurrencyRankings AS (
    SELECT 
        Currency,
        RestaurantName,
        City,
        Rating,
        Votes,
        DENSE_RANK() OVER (PARTITION BY Currency ORDER BY Rating DESC, Votes DESC) AS Rank_Num
    FROM zomato_dataset
    WHERE Votes >= 100 AND Rating IS NOT NULL
)
SELECT Currency, RestaurantName, City, Rating, Votes
FROM CurrencyRankings
WHERE Rank_Num <= 3
ORDER BY Currency, Rank_Num;
   
