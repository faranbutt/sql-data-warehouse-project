CREATE OR REPLACE PROCEDURE bronze.load_bronze() 
LANGUAGE plpgsql
AS $$
DECLARE 
	v_start_all timestamp;
	v_end_all timestamp;
	v_start_table timestamp;
	v_end_table timestamp;
	v_duration interval;
	
BEGIN
	v_start_all := clock_timestamp();
    RAISE NOTICE '=================================';
    RAISE NOTICE '=== Loading the bronze layer ===';
    RAISE NOTICE '=================================';
	BEGIN

	
	    RAISE NOTICE '---------------------------------';
	    RAISE NOTICE 'Loading CRM Tables';
	    RAISE NOTICE '---------------------------------';
		
		-- =======================================================
		-- Table bronze.crm_cust_info
		-- =======================================================
		v_start_table := clock_timestamp();
		
	    RAISE NOTICE '>> Truncating table: bronze.crm_cust_info';
	    TRUNCATE TABLE bronze.crm_cust_info;
	 
	    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
	    COPY bronze.crm_cust_info
	    FROM '/var/lib/postgresql/data_files/datasets/source_crm/cust_info.csv'
	    WITH (
	        FORMAT csv,
	        HEADER true,
	        DELIMITER ','
	    );
		
	    v_end_table := clock_timestamp();
		v_duration := v_end_table - v_start_table;
		RAISE NOTICE '>> bronze.crm_cust_info loaded in % (%.3f s)', v_duration, EXTRACT(EPOCH FROM v_duration);

		-- =======================================================
		-- Table bronze.crm_prd_info
		-- =======================================================

		v_start_table := clock_timestamp();
	    RAISE NOTICE '>> Truncating table: bronze.crm_prd_info';
	    TRUNCATE TABLE bronze.crm_prd_info;
	    
	    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
	    COPY bronze.crm_prd_info
	    FROM '/var/lib/postgresql/data_files/datasets/source_crm/prd_info.csv'
	    WITH (
	        FORMAT csv,
	        HEADER true,
	        DELIMITER ','
	    );
		v_end_table := clock_timestamp();
		v_duration := v_end_table - v_start_table;
		RAISE NOTICE '>> bronze.crm_prd_info loaded in % (%.3f s)', v_duration, EXTRACT(EPOCH FROM v_duration);

		-- =======================================================
		-- Table bronze.crm_sales_details
		-- =======================================================

		v_start_table := clock_timestamp();
	    RAISE NOTICE '>> Truncating table: bronze.crm_sales_details';
	    TRUNCATE TABLE bronze.crm_sales_details;
	    
	    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
	    COPY bronze.crm_sales_details
	    FROM '/var/lib/postgresql/data_files/datasets/source_crm/sales_details.csv'
	    WITH (
	        FORMAT csv,
	        HEADER true,
	        DELIMITER ','
	    );
		v_end_table := clock_timestamp();
		v_duration := v_end_table - v_start_table;
		RAISE NOTICE '>> bronze.crm_sales_details loaded in % (%.3f s)', v_duration, EXTRACT(EPOCH FROM v_duration);

		
		
	    RAISE NOTICE '---------------------------------';
	    RAISE NOTICE 'Loading ERP Tables';
	    RAISE NOTICE '---------------------------------';


		-- =======================================================
		-- Table bronze.erp_cust_az12
		-- =======================================================
		v_start_table := clock_timestamp();
	    RAISE NOTICE '>> Truncating table: bronze.erp_cust_az12';
	    TRUNCATE TABLE bronze.erp_cust_az12;
	    
	    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
	    COPY bronze.erp_cust_az12
	    FROM '/var/lib/postgresql/data_files/datasets/source_erp/CUST_AZ12.csv'
	    WITH (
	        FORMAT csv,
	        HEADER true,
	        DELIMITER ','
	    );
		v_end_table := clock_timestamp();
		v_duration := v_end_table - v_start_table;
		RAISE NOTICE '>> bronze.erp_cust_az12 loaded in % (%.3f s)', v_duration, EXTRACT(EPOCH FROM v_duration);

		-- =======================================================
		-- Table bronze.erp_loc_a101
		-- =======================================================
		v_start_table := clock_timestamp();
	    RAISE NOTICE '>> Truncating table: bronze.erp_loc_a101';
	    TRUNCATE TABLE bronze.erp_loc_a101;
	    
	    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
	    COPY bronze.erp_loc_a101
	    FROM '/var/lib/postgresql/data_files/datasets/source_erp/LOC_A101.csv'
	    WITH (
	        FORMAT csv,
	        HEADER true,
	        DELIMITER ','
	    );
		v_end_table := clock_timestamp();
		v_duration := v_end_table - v_start_table;
		RAISE NOTICE '>> bronze.erp_loc_a101 loaded in % (%.3f s)', v_duration, EXTRACT(EPOCH FROM v_duration);


		-- =======================================================
		-- Table bronze.erp_px_cat_g1v2
		-- =======================================================
	    v_start_table := clock_timestamp();
	    RAISE NOTICE '>> Truncating table: bronze.erp_px_cat_g1v2';
	    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	    
	    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
	    COPY bronze.erp_px_cat_g1v2
	    FROM '/var/lib/postgresql/data_files/datasets/source_erp/PX_CAT_G1V2.csv'
	    WITH (
	        FORMAT csv,
	        HEADER true,
	        DELIMITER ','
	    );
		v_end_table := clock_timestamp();
		v_duration := v_end_table - v_start_table;
		RAISE NOTICE '>> bronze.erp_px_cat_g1v2 loaded in % (%.3f s)', v_duration, EXTRACT(EPOCH FROM v_duration);
		
	    v_end_all  := clock_timestamp();
    v_duration := v_end_all - v_start_all;

    RAISE NOTICE '=================================';
    RAISE NOTICE '=== Bronze layer load complete ===';
    RAISE NOTICE 'End time : %', v_end_all;
    RAISE NOTICE 'Total    : % (%.3f s)',
                 v_duration, EXTRACT(EPOCH FROM v_duration);
    RAISE NOTICE '=================================';
	EXCEPTION
		WHEN OTHERS THEN
			RAISE NOTICE '*** ERROR in bronze.load_bronze ***';
			RAISE NOTICE 'SQLSTATE : %', SQLSTATE;
			RAISE NOTICE 'Message  : %', SQLERRM;
			RAISE;
	END;
END;
$$;
