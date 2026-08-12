/*
===============================================================================
DDL Script: Create Silver Layer Tables
===============================================================================

Script Purpose:
    This script creates the tables required for the Silver Layer.

    The Silver Layer contains cleaned, standardized, and transformed data
    loaded from the Bronze Layer.

Actions:
    1. Create the silver schema if it does not exist.
    2. Drop existing Silver tables if they exist.
    3. Recreate all Silver Layer tables.
    4. Add dwh_create_date to track when each row was loaded.

Notes:
    - This script is designed for PostgreSQL.
    - Running this script will DROP existing Silver tables and recreate them.
    - Data in the Silver Layer will therefore be deleted when this script runs.
===============================================================================
*/


-- =============================================================================
-- Create Silver Schema
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS silver;


-- =============================================================================
-- CRM TABLES
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Table: silver.crm_cust_info
-- Purpose: Cleaned and standardized customer information
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE,

    -- Data Warehouse metadata
    dwh_create_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- -----------------------------------------------------------------------------
-- Table: silver.crm_prd_info
-- Purpose: Cleaned and standardized product information
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id              INT,
    prd_key             VARCHAR(50),
    prd_nm              VARCHAR(50),
    prd_cost            INT,
    prd_line            VARCHAR(50),
    prd_start_dt        DATE,
    prd_end_dt          DATE,

    -- Data Warehouse metadata
    dwh_create_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- -----------------------------------------------------------------------------
-- Table: silver.crm_sales_details
-- Purpose: Cleaned and standardized sales transaction information
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num         VARCHAR(50),
    sls_prd_key         VARCHAR(50),
    sls_cust_id         INT,
    sls_order_dt        DATE,
    sls_ship_dt         DATE,
    sls_due_dt          DATE,
    sls_sales           INT,
    sls_quantity        INT,
    sls_price           INT,

    -- Data Warehouse metadata
    dwh_create_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =============================================================================
-- ERP TABLES
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Table: silver.erp_cust_az12
-- Purpose: Cleaned customer information from ERP system
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
    cid                 VARCHAR(50),
    bdate               DATE,
    gen                 VARCHAR(50),

    -- Data Warehouse metadata
    dwh_create_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- -----------------------------------------------------------------------------
-- Table: silver.erp_loc_a101
-- Purpose: Cleaned customer location and country information
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
    cid                 VARCHAR(50),
    cntry               VARCHAR(50),

    -- Data Warehouse metadata
    dwh_create_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- -----------------------------------------------------------------------------
-- Table: silver.erp_px_cat_g1v2
-- Purpose: Product category and maintenance information from ERP
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
    id                  VARCHAR(50),
    cat                 VARCHAR(50),
    subcat              VARCHAR(50),
    maintenance         VARCHAR(50),

    -- Data Warehouse metadata
    dwh_create_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =============================================================================
-- END OF SILVER DDL
-- =============================================================================
