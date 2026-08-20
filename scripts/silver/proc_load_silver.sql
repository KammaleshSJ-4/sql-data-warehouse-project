-- TABLE crm_cust_info 


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


