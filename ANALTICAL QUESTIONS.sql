--SALES PERFORMANCE--
--Top 10 Highest & Lowest Selling Products
-- Highest
SELECT name, sales_volume
FROM zara
ORDER BY sales_volume DESC
LIMIT 10;
-- Lowest
SELECT name, sales_volume
FROM zara
ORDER BY sales_volume ASC
LIMIT 10;
-------------------------------------------------------
--Average Sales Volume by Section
SELECT section, AVG(sales_volume) AS avg_sales_volume
FROM zara
GROUP BY section;
-------------------------------------------------------
--Subcategory with the Most Revenue
SELECT terms, SUM(price * sales_volume) AS total_revenue
FROM zara
GROUP BY terms
ORDER BY total_revenue DESC;
-------------------------------------------------------
 --Sales Performance by Product Position
 SELECT product_position, SUM(sales_volume) AS total_sales
FROM zara
GROUP BY product_position
ORDER BY total_sales DESC;
-------------------------------------------------------
--High Performers Regardless of Price
SELECT name, price, sales_volume
FROM zara
WHERE sales_volume > (SELECT AVG(sales_volume) FROM zara)
  AND price <= (SELECT AVG(price) FROM zara)
ORDER BY sales_volume DESC;
-------------------------------------------------------
--Total Sales Volume: Seasonal vs Non-Seasonal
SELECT seasonal, SUM(sales_volume) AS total_sales
FROM zara
GROUP BY seasonal;
-------------------------------------------------------
--Top-Selling Products Within Each Section & Subcategory
SELECT section, terms, name, sales_volume
FROM (
    SELECT section, terms, name, sales_volume,
           ROW_NUMBER() OVER (PARTITION BY section, terms ORDER BY sales_volume DESC) AS rank
    FROM zara
) ranked
WHERE rank <= 1;
-------------------------------------------------------
--Products Above/Below Average Sales Volume
SELECT 
    CASE 
        WHEN sales_volume > (SELECT AVG(sales_volume) FROM zara) THEN 'Above Average'
        ELSE 'Below or Equal Average'
    END AS sales_group,
    COUNT(*) AS product_count
FROM zara
GROUP BY sales_group;

--PROMOTION EFFECTIVNESS--
--Percentage of Promoted vs Non-Promoted Products
SELECT 
  promotion,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zara), 2) AS percentage
FROM zara
GROUP BY promotion;
----------------------------------------------------------
--Average Sales Volume for Promoted vs Non-Promoted
SELECT 
  promotion,
  Round(AVG(sales_volume)) AS avg_sales_volume
FROM zara
GROUP BY promotion;
----------------------------------------------------------
--Product Positions with Most Promoted Items
SELECT 
  product_position,
  COUNT(*) AS promoted_count
FROM zara
WHERE promotion = 'Yes'
GROUP BY product_position
ORDER BY promoted_count DESC;
----------------------------------------------------------
--Average Price of Promoted vs Non-Promoted Items
SELECT 
  promotion,
  ROUND(AVG(price)) AS avg_price
FROM zara
GROUP BY promotion;
----------------------------------------------------------
--Promotions by Subcategory and Section
SELECT 
  section,
  terms,
  COUNT(*) AS promoted_count
FROM zara
WHERE promotion = 'Yes'
GROUP BY section, terms
ORDER BY promoted_count DESC;
----------------------------------------------------------
--Difference in Sales Between Promoted and Non-Promoted Items
SELECT 
  promotion,
  ROUND(AVG(sales_volume)) AS avg_sales_volume
FROM zara
GROUP BY promotion;
----------------------------------------------------------
--Promotion Impact on Low-Selling Items
SELECT
promotion,
COUNT(*) AS count_low_sellers
FROM zara
WHERE sales_volume < (SELECT AVG(sales_volume) FROM zara)
GROUP BY promotion;
----------------------------------------------------------
--Are Seasonal Products More Likely to Be Promoted?
SELECT 
  seasonal,
  promotion,
  COUNT(*) AS product_count
FROM zara
GROUP BY seasonal, promotion;
----------------------------------------------------------
--Ineffective Promotions (Low Sales Despite Being Promoted)
SELECT name, price, sales_volume
FROM zara
WHERE promotion = 'Yes'
  AND sales_volume < (SELECT AVG(sales_volume) FROM zara)
ORDER BY sales_volume ASC;
----------------------------------------------------------
--Revenue Impact of Promotions
SELECT 
  promotion,
  SUM(price * sales_volume) AS total_revenue
FROM zara
GROUP BY promotion;
----------------------------------------------------------
--Product Catalog & Inventory--
--How many unique products and SKUs are in the dataset?
SELECT
  COUNT(DISTINCT product_id) AS unique_products,
  COUNT(DISTINCT sku) AS unique_skus
FROM zara;
----------------------------------------------------------
--Which subcategories (terms) have the most variety of products?
SELECT
  terms,
  COUNT(DISTINCT product_id) AS unique_products
FROM zara
GROUP BY terms
ORDER BY unique_products DESC;
----------------------------------------------------------
--Which product names appear in multiple sizes or styles (based on  sku)?
SELECT name, COUNT(DISTINCT sku) AS sku_variants
FROM zara
GROUP BY name
HAVING COUNT(DISTINCT sku) > 1
ORDER BY sku_variants DESC;
----------------------------------------------------------
--How many products are repeated across different scraping times?
SELECT
  COUNT(*) AS total_scraped_entries,
  COUNT(DISTINCT product_id) AS unique_products,
  COUNT(*) - COUNT(DISTINCT product_id) AS repeated_products
FROM zara;
----------------------------------------------------------
--Are there subcategories that are underrepresented in the catalog?
SELECT terms, COUNT(*) AS product_count
FROM zara
GROUP BY terms
ORDER BY product_count ASC;
----------------------------------------------------------
--Which sections (MAN vs WOMAN) have a more diverse product offering?
SELECT section, COUNT(DISTINCT product_id) AS unique_products
FROM zara
GROUP BY section;
----------------------------------------------------------
--What are the most and least common product names?
-- Most common
SELECT name, COUNT(*) AS frequency
FROM zara
GROUP BY name
ORDER BY frequency DESC
LIMIT 5;

-- Least common
SELECT name, COUNT(*) AS frequency
FROM zara
GROUP BY name
ORDER BY frequency ASC
LIMIT 5;
----------------------------------------------------------
--How many products have identical prices but different sales volumes?
SELECT price, COUNT(DISTINCT sales_volume) AS sales_variants, COUNT(*) AS product_count
FROM zara
GROUP BY price
HAVING COUNT(DISTINCT sales_volume) > 1;
----------------------------------------------------------
--Which products appear to be variants of the same item?
--Assuming variants share the same **product name** but have different SKUs:
SELECT name, COUNT(DISTINCT sku) AS variant_count
FROM zara
GROUP BY name
HAVING COUNT(DISTINCT sku) > 1
ORDER BY variant_count DESC;
----------------------------------------------------------
--Pricing Strategy--
--Average, Median, and Range of Product Prices
-- Average and Range
SELECT
  AVG(price) AS average_price,
  MIN(price) AS min_price,
  MAX(price) AS max_price,
  MAX(price) - MIN(price) AS price_range
FROM zara;

-- Median
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price
FROM zara;
----------------------------------------------------------
--Which Sections or Subcategories Have Higher-Priced Products on Average?
-- By Section
SELECT section, ROUND(AVG(price), 1) AS avg_price
FROM zara
GROUP BY section
ORDER BY avg_price DESC;

-- By Subcategory (terms)
SELECT terms, ROUND(AVG(price), 1) AS avg_price
FROM zara
GROUP BY terms
ORDER BY avg_price DESC;
----------------------------------------------------------
--Is There a Clear Pricing Pattern Across Product Positions?
SELECT product_position, ROUND(AVG(price), 1) AS avg_price
FROM zara
GROUP BY product_position
ORDER BY avg_price DESC;
----------------------------------------------------------
--Do Seasonal Products Tend to Be Priced Higher?
SELECT seasonal, ROUND(AVG(price), 1) AS avg_price
FROM zara
GROUP BY seasonal;
----------------------------------------------------------
--Price Range for Each Subcategory
SELECT
  terms,
  MIN(price) AS min_price,
  MAX(price) AS max_price,
  MAX(price) - MIN(price) AS price_range
FROM zara
GROUP BY terms
ORDER BY price_range DESC;
----------------------------------------------------------
--Relationship Between Price and Promotional Status
SELECT promotion, ROUND(AVG(price), 1) AS avg_price
FROM zara
GROUP BY promotion;
----------------------------------------------------------
--Expensive Products with Low Sales (Possible Overpricing)
SELECT name, price, sales_volume
FROM zara
WHERE price > (SELECT ROUND(AVG(price), 1) FROM zara)
  AND sales_volume < (SELECT ROUND(AVG(sales_volume)) FROM zara)
ORDER BY price DESC;
----------------------------------------------------------
--How Does Price Vary Between MAN and WOMAN Sections?
SELECT section, ROUND(AVG(price), 1) AS avg_price
FROM zara
GROUP BY section;
----------------------------------------------------------
--What Price Points Yield the Highest Sales Volume?
SELECT price, SUM(sales_volume) AS total_sales
FROM zara
GROUP BY price
ORDER BY total_sales DESC
LIMIT 10;
----------------------------------------------------------
--Website & Scraping Behavior--
--What times of day are products most commonly scraped?
SELECT
  EXTRACT(HOUR FROM scraped_time) AS hour_of_day,
  COUNT(*) AS scraped_count
FROM zara
GROUP BY hour_of_day
ORDER BY hour_of_day;
----------------------------------------------------------
--Scraping Time Patterns vs Promotions or Price Changes
SELECT
  EXTRACT(HOUR FROM scraped_time) AS hour_of_day,
  promotion,
  ROUND(AVG(price), 1) AS avg_price
FROM zara
GROUP BY hour_of_day, promotion
ORDER BY hour_of_day;
----------------------------------------------------------
--Are Certain Product Positions Scraped at Specific Times?
SELECT
  EXTRACT(HOUR FROM scraped_time) AS hour_of_day,
  product_position,
  COUNT(*) AS position_count
FROM zara
GROUP BY hour_of_day, product_position
ORDER BY hour_of_day, position_count DESC;
----------------------------------------------------------
--Most Recently Added Products (Based on Scraping Order)
--Assuming `scraped_time` reflects when a product appeared:
SELECT name, product_id, scraped_time
FROM zara
ORDER BY scraped_time DESC
LIMIT 10;
----------------------------------------------------------
--Is Scraping More Frequent for Certain Categories
SELECT terms, COUNT(*) AS scrape_count
FROM zara
GROUP BY terms
ORDER BY scrape_count DESC;
----------------------------------------------------------
--Duplicate URLs = Same Product with Variants?
SELECT url, COUNT(*) AS occurrences
FROM zara
GROUP BY url
HAVING COUNT(*) > 1;
----------------------------------------------------------
--Are Products Scraped at Peak vs Off-Peak Hours?
SELECT 
  CASE 
    WHEN EXTRACT(HOUR FROM scraped_time) BETWEEN 9 AND 21 THEN 'Peak'
    ELSE 'Off-Peak'
  END AS time_category,
  COUNT(*) AS scraped_count
FROM zara
GROUP BY time_category;
----------------------------------------------------------