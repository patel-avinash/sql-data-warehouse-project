/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================

Script Purpose:
    This script creates the tables required for the Bronze layer of the
    data warehouse.

    The Bronze layer stores raw data loaded from the source CSV files
    with minimal transformation.

Actions:
    - Creates the 'bronze' schema if it does not already exist.
    - Drops existing Bronze tables if they already exist.
    - Creates all Bronze layer tables with their required columns.

Tables Created:
    - bronze.crm_cust_info
    - bronze.crm_prd_info
    - bronze.crm_sales_details
    - bronze.erp_cust_az12
    - bronze.erp_loc_a101
    - bronze.erp_px_cat_g1v2

Important:
    This script recreates the Bronze tables.
    Existing data in these tables will be deleted.

Usage:
    Run this script before executing the Bronze loading procedure.

===============================================================================
*/


-- Create Bronze Schema
CREATE SCHEMA IF NOT EXISTS bronze;


-- ============================================================================
-- CRM Customer Information
-- ============================================================================

DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);


-- ============================================================================
-- CRM Product Information
-- ============================================================================

DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info(
    prd_id INT,
    prd_key VARCHAR(50),
    prd_name VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);


-- ============================================================================
-- CRM Sales Details
-- ============================================================================

DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details(
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);


-- ============================================================================
-- ERP Customer Information
-- ============================================================================

DROP TABLE IF EXISTS bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12(
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);


-- ============================================================================
-- ERP Location Information
-- ============================================================================

DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101(
    cid VARCHAR(50),
    cntry VARCHAR(50)
);


-- ============================================================================
-- ERP Product Category Information
-- ============================================================================

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2(
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);
