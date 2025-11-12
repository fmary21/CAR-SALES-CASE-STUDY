SELECT
  *
FROM
  "SALES"."CAR_SALES"."CAR_SALE_UPDATED"
LIMIT
  100;
-----------------------------------------------------------------------------------------
      ----calculating units sold--------
  SELECT COUNT(*) AS units_sold
FROM car_sale_updated;

---------------------------------------------------------------------------------------

  ---Total revenue and total profit----
SELECT
  COUNT(*) AS totalsales,
  SUM(sellingprice) AS total_revenue,
  SUM(sellingprice - mmr) AS total_profit,
  AVG(sellingprice - mmr) AS avg_profit_per_sale
FROM car_sales_dataset
WHERE saledate BETWEEN '2024-01-01' AND '2024-12-31';
----------------------------------------------------------------------------------------

---Top 10 models by profi----
SELECT make, model, COUNT(*) AS sales, SUM(sellingprice - mmr) AS profit
FROM car_sales_dataset
GROUP BY make, model
ORDER BY profit DESC
LIMIT 10;
---------------------------------------------------------------------------
          ---Mileage buckets (CASE)---
SELECT
  CASE
    WHEN odometer < 20000 THEN '<20k'
    WHEN odometer BETWEEN 20000 AND 50000 THEN '20-50k'
    WHEN odometer BETWEEN 50001 AND 100000 THEN '50-100k'
    ELSE '>100k'
  END AS mileage_band,
  COUNT(*) AS cnt,
  AVG(sellingprice) AS avg_price
FROM car_sales_dataset
GROUP BY mileage_band
ORDER BY cnt DESC;
----------------------------------------------------------------------------
       ---Identify vehicles sold above MMR (price premium)----

SELECT
    vin, make, model, sellingprice, mmr, (sellingprice - mmr) AS premium
FROM car_sales_dataset
WHERE (sellingprice - mmr) > 0
ORDER BY premium DESC
LIMIT 50;
---------------------------------------------------------------------------
---TRYING OUT WINDOWS FUNCTIONS FOR PRACTICE ----
---Window function — price trend per VIN (first/last sale)---

SELECT vin, make, model, saledate, sellingprice,
       LAG(sellingprice) OVER (PARTITION BY vin ORDER BY saledate) AS prev_price
FROM CAR_SALES_DATASET;
----------------------------------------------------------------------------
        ---Unique vehicles / duplicates by VIN----

SELECT vin, COUNT(*) AS listings
FROM CAR_SALES_DATASET
GROUP BY vin
HAVING COUNT(*) > 1;
----------------------------------------------------------------------------
           ---State performance: revenue & avg profit---
SELECT state,
       COUNT(*) AS sales,
       SUM(sellingprice) AS revenue,
       AVG(sellingprice - mmr) AS avg_profit
FROM CAR_SALES_DATASET
GROUP BY state
ORDER BY revenue DESC;
---------------------------------------------------------------------------
         ---Handle Missing or Null Values----
  ---We’ll replace or impute missing data depending on the column type---

SELECT
  COALESCE(TRY_TO_NUMBER(sellingprice), 0) AS selling_price,
  COALESCE(TRY_TO_NUMBER(mmr), 0) AS mmr,
  COALESCE(TRY_TO_NUMBER(odometer), 0) AS odometer,
  trim,
  body,
  transmission
FROM car_sale_updated
WHERE TRY_TO_TIMESTAMP(saledate) IS NOT NULL;

SELECT
  vin,
  COALESCE(make, 'Unknown') AS make,
  COALESCE(model, 'Unknown') AS model,
  COALESCE(year, DATE_PART('YEAR', TRY_TO_TIMESTAMP(saledate))) AS year,
  COALESCE(state, 'Unknown') AS state,
  -- FIX: Only use 'Not Specified' if condition is a TEXT column
  COALESCE(condition, 0) AS condition,
  COALESCE(seller, 'Unknown') AS seller,
  COALESCE(color, 'Unknown') AS color,
  COALESCE(interior, 'Unknown') AS interior,
  saledate,
FROM car_sale_updated

    
   --- Handle numeric nulls by replacing with 0 or average ----
 
  SELECT
  COALESCE(TRY_TO_NUMBER(sellingprice), 0) AS selling_price,
  COALESCE(TRY_TO_NUMBER(mmr), 0) AS mmr,
  COALESCE(TRY_TO_NUMBER(odometer), 0) AS odometer,
  trim,
  body,
  transmission
FROM car_sale_updated
WHERE TRY_TO_TIMESTAMP(saledate) IS NOT NULL;

---------------------------------------------------------------------------------------
  --- Extract date-time components---
SELECT
  TO_CHAR(TRY_TO_TIMESTAMP_NTZ(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'YYYY') AS year,
  TO_CHAR(TRY_TO_TIMESTAMP_NTZ(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'Month') AS month_name,
  DATE_PART('HOUR', TRY_TO_TIMESTAMP_NTZ(saledate, 'DY MON DD YYYY HH24:MI:SS')) AS sale_hour,
  TO_CHAR(TRY_TO_TIMESTAMP_NTZ(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'HH24:MI:SS') AS sale_time
FROM car_sale_updated;

----------------------------------------------------------------------------------
  --- Convert string to timestamp---

SELECT
  TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS') AS sale_ts
FROM car_sale_updated
WHERE TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS') IS NOT NULL;

-------------------------------------------------------------------------------------
-----Generating Table -----
SELECT
    MAKE,
    MODEL,
    YEAR,
    STATE AS region, 
--- Fuel Type Classification----
    CASE 
        WHEN MAKE = 'Subaru' AND MODEL = 'Legacy' AND YEAR = 1997 THEN 'PETROL'
        WHEN MAKE = 'Mazda' AND MODEL = '3 SERIES' AND YEAR = 2014 THEN 'Gasoline/Flex Fuel'
        WHEN MAKE = 'Land Rover' AND MODEL = 'Range Rover' AND YEAR = 2018 THEN 'Diesel'
        WHEN MAKE = 'Audi' AND MODEL = 'Q5' AND YEAR = 2014 THEN 'Electric'
        ELSE 'Unknown'
    END AS fuel_type,
---Sale Date (converted properly)----
    TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS') AS sale_date,
----Time Dimensions-----
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'YYYY') AS year_sold,
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'Month') AS month_name,
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'DY') AS day_name,
 ---Units Sold----
    COUNT(*) AS units_sold,
    -- Total Revenue----
    SUM(sellingprice) AS total_revenue,
 --- Average Selling Price-----
    AVG(SELLINGPRICE) AS avg_selling_price,
---- Average Profit Margin---
    AVG((SELLINGPRICE - MMR) / NULLIF(MMR, 0)) AS avg_profit_margin,
 --- Performance Tier (Margin Category)---
    CASE 
        WHEN ((SELLINGPRICE - MMR) / NULLIF(MMR, 0)) >= 0.20 THEN 'High Margin'
        WHEN ((SELLINGPRICE - MMR) / NULLIF(MMR, 0)) BETWEEN 0.05 AND 0.199 THEN 'Medium Margin'
        WHEN ((SELLINGPRICE - MMR) / NULLIF(MMR, 0)) < 0.05 THEN 'Low Margin'
        ELSE 'Unknown'
    END AS performance_tier

FROM car_sale_updated
WHERE TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS') IS NOT NULL
GROUP BY 
    MAKE,
    MODEL,
    YEAR,
    STATE,
    fuel_type,
    sale_date,
    year_sold,
    month_name,
    day_name,
    performance_tier
ORDER BY 
    MAKE,
    MODEL,
    YEAR,
    region,
    year_sold,
    month_name,
    performance_tier;
-------------------------------------------------------------------------------------------
-----Generating Table -----

SELECT
    MAKE,
    MODEL,
    YEAR,
    STATE AS region,

    -- Fuel Type Classification
    CASE 
        WHEN MAKE = 'Subaru' AND MODEL = 'Legacy' AND YEAR = 1997 THEN 'PETROL'
        WHEN MAKE = 'Mazda' AND MODEL = '3 SERIES' AND YEAR = 2014 THEN 'Gasoline/Flex Fuel'
        WHEN MAKE = 'Land Rover' AND MODEL = 'Range Rover' AND YEAR = 2018 THEN 'Diesel'
        WHEN MAKE = 'Audi' AND MODEL = 'Q5' AND YEAR = 2014 THEN 'Electric'
        ELSE 'Unknown'
    END AS fuel_type,

    -- Sale Date and Time Dimensions
    TO_DATE(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS')) AS sale_date,
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'YYYY') AS year_sold,
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'Month') AS month_name,
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'DY') AS day_name,

    -- Units Sold
    COUNT(*) AS units_sold,

    -- Total Revenue
    SUM(SELLINGPRICE) AS total_revenue,

    -- Average Selling Price
    AVG(SELLINGPRICE) AS avg_selling_price,

    -- Average Profit Margin
    AVG(
        CASE 
            WHEN MMR = 0 THEN NULL
            ELSE (SELLINGPRICE - MMR) / MMR
        END
    ) AS avg_profit_margin,

    -- Performance Tier
    CASE 
        WHEN AVG(
            CASE 
                WHEN MMR = 0 THEN NULL
                ELSE (SELLINGPRICE - MMR) / MMR
            END
        ) >= 0.20 THEN 'High Margin'
        WHEN AVG(
            CASE 
                WHEN MMR = 0 THEN NULL
                ELSE (SELLINGPRICE - MMR) / MMR
            END
        ) BETWEEN 0.05 AND 0.199 THEN 'Medium Margin'
        WHEN AVG(
            CASE 
                WHEN MMR = 0 THEN NULL
                ELSE (SELLINGPRICE - MMR) / MMR
            END
        ) < 0.05 THEN 'Low Margin'
        ELSE 'Unknown'
    END AS performance_tier

FROM car_sale_updated
WHERE TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS') IS NOT NULL

GROUP BY 
    MAKE,
    MODEL,
    YEAR,
    STATE,
    TO_DATE(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS')),
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'YYYY'),
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'Month'),
    TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH24:MI:SS'), 'DY'),

    CASE 
        WHEN MAKE = 'Subaru' AND MODEL = 'Legacy' AND YEAR = 1997 THEN 'PETROL'
        WHEN MAKE = 'Mazda' AND MODEL = '3 SERIES' AND YEAR = 2014 THEN 'Gasoline/Flex Fuel'
        WHEN MAKE = 'Land Rover' AND MODEL = 'Range Rover' AND YEAR = 2018 THEN 'Diesel'
        WHEN MAKE = 'Audi' AND MODEL = 'Q5' AND YEAR = 2014 THEN 'Electric'
        ELSE 'Unknown'
    END

ORDER BY 
    MAKE,
    MODEL,
    YEAR,
    region,
    year_sold,
    month_name,
    performance_tier;

  
