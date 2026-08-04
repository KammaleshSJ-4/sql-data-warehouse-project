
-- ===================================================================================
-- LOADING ALL THE VALUES IN CSV FILES INTO THE DATABASES 
-- ===================================================================================

EXEC bronze.load_bronze


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY

		DECLARE @whole_start AS DATETIME, @whole_end AS DATETIME;
		DECLARE @start_time AS DATETIME, @end_time AS DATETIME;

		PRINT '====================================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '====================================================';
	
		SET @whole_start = GETDATE();

		-- -----------------------------------------------------------------------------------
		--	Loading CRM Tables			
		-- -----------------------------------------------------------------------------------

		PRINT '----------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '----------------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Loading Into Table crm_cust_info';
		BULK INSERT bronze.crm_cust_info 
		FROM 'D:\Projects\sql_data_warehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();

		PRINT '>> Loading Table:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		
		print '-----------------------------'
	
		SET @start_time = GETDATE();
		
		PRINT '>> Truncating Table crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Loading Into Table crm_prd_info';
		BULK INSERT bronze.crm_prd_info 
		FROM 'D:\Projects\sql_data_warehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();

		PRINT '>> Loading Table:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		
		print '-----------------------------'
		
		SET @start_time = GETDATE();

		PRINT '>> Truncating Table crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Loading Into Table crm_sales_details';
		BULK INSERT bronze.crm_sales_details 
		FROM 'D:\Projects\sql_data_warehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();

		PRINT '>> Loading Table:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		
		print '-----------------------------'

		-- --------------------------------------------------------------------------------------
		--	Loading ERP Tables
		-- --------------------------------------------------------------------------------------

		PRINT '------------------------------------------------------'
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------------'

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Loading Into Table erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12 
		FROM 'D:\Projects\sql_data_warehouse\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();

		PRINT '>> Loading Table:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		
		print '-----------------------------'

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Loading Into Table erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101 
		FROM 'D:\Projects\sql_data_warehouse\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();

		PRINT '>> Loading Table:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		
		print '-----------------------------'

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Loading Into Table erp_loc_a101';
		BULK INSERT bronze.erp_px_cat_g1v2 
		FROM 'D:\Projects\sql_data_warehouse\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();

		PRINT '>> Loading Table:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		
		print '-----------------------------'

		
		SET @whole_end = GETDATE();
		PRINT '>> Loading Bronze Layer Tables:' + CAST(DATEDIFF(second,@whole_start,@whole_end) AS NVARCHAR) + ' seconds';

	END TRY
	BEGIN CATCH
		PRINT '=============================================';
		PRINT 'ERROR OCCURED IN LOADING BRONZE LAYER';
		PRINT '=============================================';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Eroor Line No' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END
