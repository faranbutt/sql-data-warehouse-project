-- CHECK DUPLICATES 
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- CHECK UNWANTED SPACE IN STRINGS COLS
SELECT 	
	cst_firstname
FROM 
	silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT 	
	cst_lastname
FROM 
	silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


--CHECK DATA STANDARIZATION & CONSISTENCY
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info



--------------------------------------------------------------------
-- CRM PRD INFO
--------------------------------------------------------------------
SELECT 
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--------------------------------------------------------------------
-- CRM Sales INFO
--------------------------------------------------------------------

SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


SELECT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
OR sls_sales IS NULL

--------------------------------------------------------------------
-- ERP CUST INFO
--------------------------------------------------------------------

SELECT *
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > NOW()


SELECT DISTINCT 
	gen
FROM silver.erp_cust_az12

--------------------------------------------------------------------
-- ERP LOC INFO
--------------------------------------------------------------------
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101

--------------------------------------------------------------------
-- ERP PX CAT INFO
--------------------------------------------------------------------

SELECT 
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2
where cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)
