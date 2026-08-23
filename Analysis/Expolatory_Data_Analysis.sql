-- Expolatory Data Analysis

-- 1. Database Exploration

-- Explore all objects from the database tables
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore the columns from the database tables
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- 2. Dimention Exploration

-- Explore all the countries our customers came from
SELECT DISTINCT country FROM gold.dim_customers

-- Explore all the moajor categories of products
SELECT DISTINCT category,subcategory,product_name FROM gold.dim_product
ORDER BY 1,2,3


-- 3. Date Exploration

-- First and last order
SELECT
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(year,MIN(order_date),MAX(order_date)) AS order_range_years
FROM gold.fact_sales

-- Customer birthdate analysis
SELECT 
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(year,MIN(birthdate),GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(year,MAX(birthdate),GETDATE()) AS youngest_age
FROM gold.dim_customers
