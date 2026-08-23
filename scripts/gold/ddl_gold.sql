
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
	pi.prd_nm AS product_name,
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


CREATE VIEW gold.fact_sales AS
SELECT
	so.sls_ord_num AS order_number,
	dp.product_number AS product_number,
	dc.customer_id AS customer_id,
	so.sls_order_dt AS order_date,
	so.sls_ship_dt AS shipping_date,
	so.sls_due_dt AS due_date,
	so.sls_sales AS sales_amount,
	so.sls_quantity AS quantity,
	so.sls_price AS price
FROM silver.crm_sales_details so
LEFT JOIN gold.dim_product dp
	on so.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers dc
	on so.sls_cust_id = dc.customer_id

SELECT * FROM gold.fact_sales
