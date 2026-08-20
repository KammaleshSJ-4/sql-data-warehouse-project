-- TABLE crm_cust_info 

TRUNCATE TABLE silver.crm_cust_info; 
INSERT INTO silver.crm_cust_info (
       [cst_id]
      ,[cst_key]
      ,[cst_firstname]
      ,[cst_lastname]
      ,[cst_marital_status]
      ,[cst_gndr]
      ,[cst_create_date]
)
SELECT 
     [cst_id]
    ,[cst_key]
    ,TRIM(cst_firstname) AS cst_firstname   -- Eliminate Unwanted Spaces
    ,TRIM(cst_lastname) AS cst_lastname     -- Eliminate Unwanted Spaces
    ,CASE UPPER(cst_marital_status)			-- Standardizing Data
        WHEN 'S' THEN 'Single'
        WHEN 'M' THEN 'Married'
        ELSE 'n/a'
    END cst_marital_status
    ,CASE UPPER(cst_gndr)					-- Standardizing Data
        WHEN 'F' THEN 'Female'
        WHEN 'M' THEN 'Male'
        ELSE 'n/a'
    END cst_gndr
    ,[cst_create_date]
FROM (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last		-- Removing Duplicate Rows
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    )t
WHERE flag_last = 1;

SELECT * FROM silver.crm_cust_info;


-- silver.crm_prd_info Table

-- Creation of Table with correction in column schema
IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info
CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(100),
	prd_nm NVARCHAR(200),
	prd_cost INT,
	prd_line NVARCHAR(100),
	prd_start_dt DATE,
	prd_end_dt DATE
);

-- Inserting into the table
TRUNCATE TABLE silver.crm_prd_info; 
INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,		-- Extracting CategoryID
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,			-- Extracting ProductKey
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,							
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END	as prd_line,										-- Mapping Values into Descriptive Values
	CAST(prd_start_dt AS DATE) as prd_start_dt,				-- Calculate End Date as one day before next Start Date
	CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;


SELECT * from silver.crm_prd_info;



-- crm_sales_details table


-- Dropping and creation of table if exist with changes
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

-- Insrting the values 

TRUNCATE TABLE silver.crm_sales_details; 
INSERT INTO silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price)
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id, 
	CASE											--  Converrt format into date
		WHEN sls_order_dt= 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR(100)) AS DATE)
	END as sls_order_dt,
	CASE 
		WHEN sls_ship_dt= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR(100)) AS DATE)
	END as sls_ship_dt,
	CASE 
		WHEN sls_due_dt= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR(100)) AS DATE)
	END as sls_due_dt,
	CASE
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END as sls_sales,									-- Derive sales from price and quantity
	sls_quantity,
	CASE
		WHEN sls_price <=0 THEN ABS(sls_price)
		WHEN sls_price IS NULL THEN ABS(sls_sales) / sls_quantity
		ELSE sls_price
	END as sls_price									-- Derive missing price with sales and quantity

FROM bronze.crm_sales_details;

SELECT * FROM silver.crm_sales_details;


-- erp_cust_az12 Table
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12 (
	cid,
	bdate,
	gen
)
SELECT												-- Remove unwanted characters
	CASE 
		WHEN cid LIKE '%NAS%'
			THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
	END AS cid,
	CASE											-- Remove invalid birth day
		WHEN bdate > GETDATE()
			THEN NULL
		ELSE bdate
	END AS bdate,
	CASE											-- Standardization of gender
		WHEN gen LIKE 'F' THEN 'Female'
		WHEN gen LIKE 'M' THEN 'Male'
		ELSE 'n/a'
	END as gen
FROM bronze.erp_cust_az12

SELECT * FROM silver.erp_cust_az12;


-- erp_loc_a101 table

TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
)
SELECT
	REPLACE(cid,'-','') AS cid,
	CASE														-- Standardization
		WHEN TRIM(cntry) IN ('DE','Germany') THEN 'Germany'
		WHEN TRIM(cntry) IN ('USA','United States') THEN 'United States'
		WHEN TRIM(cntry) LIKE '' OR TRIM(cntry) IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101

SELECT * from silver.erp_loc_a101

-- erp_px_cat_g1v2 table
TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2
(
	id,
	cat,
	subcat,
	maintenance
)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT * FROM silver.erp_px_cat_g1v2
