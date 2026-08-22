
CREATE VIEW gold.dim_customers AS (
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS customer_firstname,
	ci.cst_lastname AS cutomer_lastname,
	li.cntry AS country,
	ci.cst_marital_status AS customer_marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE(cu.gen,'n/a')
	END AS gender,
	cu.bdate AS birthdate,
	ci.cst_create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 cu
	ON ci.cst_key = cu.cid
LEFT JOIN silver.erp_loc_a101 li
	ON ci.cst_key = li.cid
);

SELECT * FROM gold.dim_customers;


CREATE VIEW gold.dim_product AS 
SELECT
	ROW_NUMBER() OVER(ORDER BY pi.prd_start_dt,pi.prd_key) AS product_key,
	pi.prd_id AS product_id,
	pi.prd_key AS product_number,
	pi.prd_nm AS produuct_name,
	pi.cat_id AS category_id,
	pe.cat AS category,
	pe.subcat AS subcategory,
	pe.maintenance AS maintenance,
	pi.prd_cost AS product_cost,
	pi.prd_line AS product_line,
	pi.prd_start_dt AS product_start_date
FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pe
ON pi.cat_id = pe.id
WHERE pi.prd_end_dt IS NULL;  -- Filter out all historcal data
