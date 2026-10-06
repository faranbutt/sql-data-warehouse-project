CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_all   timestamp;
    v_end_all     timestamp;
    v_start_table timestamp;
    v_end_table   timestamp;
    v_duration    interval;
BEGIN
    v_start_all := clock_timestamp();

    RAISE NOTICE '=================================';
    RAISE NOTICE '=== Loading the silver layer ===';
    RAISE NOTICE 'Start time: %', v_start_all;
    RAISE NOTICE '=================================';

    BEGIN
        -- =======================================================
        -- Table silver.crm_cust_info
        -- =======================================================
        v_start_table := clock_timestamp();
        RAISE NOTICE '>> Truncating table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        RAISE NOTICE '>> Inserting Data: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname,
            cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        v_end_table := clock_timestamp();
        v_duration  := v_end_table - v_start_table;
        RAISE NOTICE '>> silver.crm_cust_info loaded in % (%.3f s)',
                     v_duration, EXTRACT(EPOCH FROM v_duration);

        -- =======================================================
        -- Table silver.crm_prd_info
        -- =======================================================
        v_start_table := clock_timestamp();
        RAISE NOTICE '>> Truncating table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        RAISE NOTICE '>> Inserting Data: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id, cat_id, prd_key, prd_nm, prd_cost,
            prd_line, prd_start_dt, prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LENGTH(prd_key)),
            prd_nm,
            COALESCE(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
                 - INTERVAL '1 day' AS DATE)
        FROM bronze.crm_prd_info;

        v_end_table := clock_timestamp();
        v_duration  := v_end_table - v_start_table;
        RAISE NOTICE '>> silver.crm_prd_info loaded in % (%.3f s)',
                     v_duration, EXTRACT(EPOCH FROM v_duration);

        -- =======================================================
        -- Table silver.crm_sales_details
        -- =======================================================
        v_start_table := clock_timestamp();
        RAISE NOTICE '>> Truncating table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        RAISE NOTICE '>> Inserting Data: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id,
            sls_order_dt, sls_ship_dt, sls_due_dt,
            sls_sales, sls_quantity, sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::text) != 8 THEN NULL
                 ELSE TO_DATE(sls_order_dt::text, 'YYYYMMDD') END,
            CASE WHEN sls_ship_dt  = 0 OR LENGTH(sls_ship_dt::text)  != 8 THEN NULL
                 ELSE TO_DATE(sls_ship_dt::text,  'YYYYMMDD') END,
            CASE WHEN sls_due_dt   = 0 OR LENGTH(sls_due_dt::text)   != 8 THEN NULL
                 ELSE TO_DATE(sls_due_dt::text,   'YYYYMMDD') END,
            CASE
                WHEN sls_sales IS NULL THEN sls_quantity * sls_price
                WHEN sls_sales < 0 THEN sls_sales * -1
                WHEN sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * sls_price
                ELSE sls_sales
            END,
            sls_quantity,
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        v_end_table := clock_timestamp();
        v_duration  := v_end_table - v_start_table;
        RAISE NOTICE '>> silver.crm_sales_details loaded in % (%.3f s)',
                     v_duration, EXTRACT(EPOCH FROM v_duration);

        -- =======================================================
        -- Table silver.erp_cust_az12
        -- =======================================================
        v_start_table := clock_timestamp();
        RAISE NOTICE '>> Truncating table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        RAISE NOTICE '>> Inserting Data: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
                 ELSE cid END,
            CASE WHEN bdate > NOW() THEN NULL ELSE bdate END,
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
                ELSE 'n/a'
            END
        FROM bronze.erp_cust_az12;

        v_end_table := clock_timestamp();
        v_duration  := v_end_table - v_start_table;
        RAISE NOTICE '>> silver.erp_cust_az12 loaded in % (%.3f s)',
                     v_duration, EXTRACT(EPOCH FROM v_duration);

        -- =======================================================
        -- Table silver.erp_loc_a101
        -- =======================================================
        v_start_table := clock_timestamp();
        RAISE NOTICE '>> Truncating table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        RAISE NOTICE '>> Inserting Data: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT
            REPLACE(cid, '-', ''),
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        v_end_table := clock_timestamp();
        v_duration  := v_end_table - v_start_table;
        RAISE NOTICE '>> silver.erp_loc_a101 loaded in % (%.3f s)',
                     v_duration, EXTRACT(EPOCH FROM v_duration);

        -- =======================================================
        -- Table silver.erp_px_cat_g1v2
        -- =======================================================
        v_start_table := clock_timestamp();
        RAISE NOTICE '>> Truncating table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        RAISE NOTICE '>> Inserting Data: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance
        FROM bronze.erp_px_cat_g1v2;

        v_end_table := clock_timestamp();
        v_duration  := v_end_table - v_start_table;
        RAISE NOTICE '>> silver.erp_px_cat_g1v2 loaded in % (%.3f s)',
                     v_duration, EXTRACT(EPOCH FROM v_duration);

        -- =======================================================
        -- Summary
        -- =======================================================
        v_end_all  := clock_timestamp();
        v_duration := v_end_all - v_start_all;

        RAISE NOTICE '=================================';
        RAISE NOTICE '=== Silver layer load complete ===';
        RAISE NOTICE 'End time : %', v_end_all;
        RAISE NOTICE 'Total    : % (%.3f s)',
                     v_duration, EXTRACT(EPOCH FROM v_duration);
        RAISE NOTICE '=================================';

    EXCEPTION
        WHEN OTHERS THEN
            v_end_all  := clock_timestamp();
            v_duration := v_end_all - v_start_all;

            RAISE NOTICE '*** ERROR in silver.load_silver ***';
            RAISE NOTICE 'SQLSTATE : %', SQLSTATE;
            RAISE NOTICE 'Message  : %', SQLERRM;
            RAISE NOTICE 'Failed after % (%.3f s)',
                         v_duration, EXTRACT(EPOCH FROM v_duration);
            RAISE;
    END;
END;
$$;
