/*
===============================================================================
Gold Layer - Dimension & Fact Views
===============================================================================

Script Purpose:
    This script creates the Gold layer views used for analytics and reporting.

Objects Created:
    1. gold.dim_products  - Product dimension
    2. gold.dim_customers - Customer dimension
    3. gold.fact_sales    - Sales fact

Notes:
    - Surrogate keys are generated using ROW_NUMBER().
    - Dimension views expose business-friendly column names.
    - fact_sales uses surrogate keys from the Gold dimensions.
===============================================================================
*/

-- =============================================================================
-- Create Gold Schema
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS gold;


-- =============================================================================
-- Create Product Dimension
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_products;

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pi.prd_id) AS product_key,
    pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    pi.prd_name AS product_name,
    pi.cat_id AS category_id,
    cat.cat AS category,
    cat.subcat AS subcategory,
    cat.maintenance AS maintenance,
    pi.prd_cost AS cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS start_date,
    pi.prd_end_dt AS end_date
FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS cat
    ON pi.cat_id = cat.id
WHERE pi.prd_end_dt IS NULL;


-- =============================================================================
-- Create Customer Dimension
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_customers;

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;


-- =============================================================================
-- Create Sales Fact
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_sales;

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_cust_id AS customer_id,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
    ON sd.sls_cust_id = cu.customer_id;


-- =============================================================================
-- Validation Queries
-- =============================================================================

-- View Product Dimension
-- SELECT * FROM gold.dim_products;

-- View Customer Dimension
-- SELECT * FROM gold.dim_customers;

-- View Sales Fact
-- SELECT * FROM gold.fact_sales;
