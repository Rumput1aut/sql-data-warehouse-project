/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT
prd_id,
COUNT (*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for Unwanted Spaces
-- Expectation: No Result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM (prd_nm)

--Check for Nulls or Negative Numbers
-- Expectation: No Result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standarization & Consistency
SELECT DISTINCT 
cntry
FROM silver.erp_loc_a101

SELECT * FROM silver.erp_px_cat_g1v2

-- Check for Invalid Date Orders
SELECT 
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt 

SELECT *
FROM silver.crm_prd_info

-- Check for Invalid Dates
SELECT 
NULLIF(sls_due_dt,0) sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price	
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM silver.crm_sales_details

-- Identify Out-of-Range Dates

SELECT DISTINCT 
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE ()

SELECT * FROM silver.erp_cust_az12


EXEC silver.load_silver
EXEC bronze.load_bronze
