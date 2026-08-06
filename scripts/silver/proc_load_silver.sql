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
    ,TRIM(cst_firstname) AS cst_firstname
    ,TRIM(cst_lastname) AS cst_lastname
    ,CASE UPPER(cst_marital_status)
        WHEN 'S' THEN 'Single'
        WHEN 'M' THEN 'Married'
        ELSE 'n/a'
    END cst_marital_status
    ,CASE UPPER(cst_gndr)
        WHEN 'F' THEN 'Female'
        WHEN 'M' THEN 'Male'
        ELSE 'n/a'
    END cst_gndr
    ,[cst_create_date]
FROM (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    )t
WHERE flag_last = 1;

SELECT * FROM silver.crm_cust_info;


