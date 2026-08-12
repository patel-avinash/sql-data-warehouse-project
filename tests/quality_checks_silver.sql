/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================

Script Purpose:
    This script performs various quality checks for data consistency,
    accuracy, completeness, and standardization across the Silver Layer.

Checks include:
    - NULL or duplicate primary keys
    - Unwanted spaces in string fields
    - Data standardization and consistency
    - Invalid date ranges
    - Invalid date values
    - Data consistency between related fields

Expectation:
    Each quality check should return NO RESULTS unless otherwise specified.

Database:
    PostgreSQL
===============================================================================
*/


-- =============================================================================
-- Checking: silver.crm_cust_info
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check for NULLs or Duplicates in Customer ID
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces in Customer Key
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key);


-- -----------------------------------------------------------------------------
-- Check Data Standardization: Marital Status
-- Expectation: Only Single, Married, or n/a
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info
ORDER BY cst_marital_status;


-- -----------------------------------------------------------------------------
-- Check Data Standardization: Gender
-- Expectation: Only Male, Female, or n/a
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info
ORDER BY cst_gndr;



-- =============================================================================
-- Checking: silver.crm_prd_info
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check for NULLs or Duplicates in Product ID
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces in Product Name
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


-- -----------------------------------------------------------------------------
-- Check for NULL or Negative Product Cost
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0
    OR prd_cost IS NULL;


-- -----------------------------------------------------------------------------
-- Check Data Standardization: Product Line
-- Expectation: Only Mountain, Road, Other Sales, Touring, or n/a
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info
ORDER BY prd_line;


-- -----------------------------------------------------------------------------
-- Check for Invalid Date Order
-- Start Date should NOT be greater than End Date
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- -----------------------------------------------------------------------------
-- Check for NULL Product Start Dates
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    prd_id,
    prd_key,
    prd_start_dt
FROM silver.crm_prd_info
WHERE prd_start_dt IS NULL;



-- =============================================================================
-- Checking: silver.crm_sales_details
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check Invalid Order Dates in Bronze
--
-- Source column is stored as an integer in YYYYMMDD format.
--
-- Valid range:
--     1900-01-01
--     to
--     2050-01-01
--
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0
   OR LENGTH(sls_order_dt::TEXT) <> 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;


-- -----------------------------------------------------------------------------
-- Check Invalid Ship Dates in Bronze
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt = 0
   OR LENGTH(sls_ship_dt::TEXT) <> 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;


-- -----------------------------------------------------------------------------
-- Check Invalid Due Dates in Bronze
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt = 0
   OR LENGTH(sls_due_dt::TEXT) <> 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;


-- -----------------------------------------------------------------------------
-- Check for Invalid Date Orders
--
-- Order Date should be <= Ship Date
-- Order Date should be <= Due Date
--
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- -----------------------------------------------------------------------------
-- Check Data Consistency:
-- Sales = Quantity * Price
--
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;


-- -----------------------------------------------------------------------------
-- Check for NULL Sales Order Numbers
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL;


-- -----------------------------------------------------------------------------
-- Check for NULL Customer IDs
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_cust_id IS NULL;


-- =============================================================================
-- Checking: silver.erp_cust_az12
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check for Out-of-Range Birth Dates
--
-- Expected range:
--     1924-01-01
--     to
--     Current Date
--
-- PostgreSQL equivalent of SQL Server GETDATE():
--     CURRENT_DATE
--
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < DATE '1924-01-01'
   OR bdate > CURRENT_DATE;


-- -----------------------------------------------------------------------------
-- Check Data Standardization: Gender
-- Expectation: Only Male, Female, or n/a
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    gen
FROM silver.erp_cust_az12
ORDER BY gen;


-- -----------------------------------------------------------------------------
-- Check for NULL Customer IDs
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    *
FROM silver.erp_cust_az12
WHERE cid IS NULL;



-- =============================================================================
-- Checking: silver.erp_loc_a101
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check Data Standardization: Country
-- Expectation: Standardized country values
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- -----------------------------------------------------------------------------
-- Check for NULL Customer IDs
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    *
FROM silver.erp_loc_a101
WHERE cid IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces in Country
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    cntry
FROM silver.erp_loc_a101
WHERE cntry <> TRIM(cntry);



-- =============================================================================
-- Checking: silver.erp_px_cat_g1v2
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


-- -----------------------------------------------------------------------------
-- Check Data Standardization: Maintenance
-- Expectation: Standardized values
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2
ORDER BY maintenance;


-- -----------------------------------------------------------------------------
-- Check for NULL Category IDs
-- Expectation: No Results
-- -----------------------------------------------------------------------------

SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL;


-- =============================================================================
-- END OF SILVER QUALITY CHECKS
-- =============================================================================
