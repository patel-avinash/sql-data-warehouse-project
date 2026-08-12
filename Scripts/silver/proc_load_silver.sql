/*
===============================================================================
Stored Procedure: Load Silver Layer
===============================================================================

Script Purpose:
    This procedure loads and transforms data from the Bronze layer
    into the Silver layer.

    The Silver layer performs:
        - Data cleaning
        - Data standardization
        - Data transformation
        - Duplicate removal
        - Invalid data handling
        - Business-friendly value mapping

Process:
    Bronze → Cleaning & Transformation → Silver

Tables loaded:
    1. silver.crm_cust_info
    2. silver.crm_prd_info
    3. silver.crm_sales_details
    4. silver.erp_cust_az12
    5. silver.erp_loc_a101
    6. silver.erp_px_cat_g1v2

Usage:
    CALL silver.load_silver();

===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time   TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time   TIMESTAMP;
BEGIN

    /*
    ===========================================================================
    Start Silver Layer
    ===========================================================================
    */

    batch_start_time := clock_timestamp();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '================================================';


    /*
    ===========================================================================
    CRM TABLES
    ===========================================================================
    */

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';


    /*
    ===========================================================================
    1. Loading silver.crm_cust_info
    ===========================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';

    TRUNCATE TABLE silver.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';

    INSERT INTO silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,

        TRIM(cst_firstname) AS cst_firstname,

        TRIM(cst_lastname) AS cst_lastname,

        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S'
                THEN 'Single'

            WHEN UPPER(TRIM(cst_marital_status)) = 'M'
                THEN 'Married'

            ELSE 'n/a'
        END AS cst_marital_status,

        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F'
                THEN 'Female'

            WHEN UPPER(TRIM(cst_gndr)) = 'M'
                THEN 'Male'

            ELSE 'n/a'
        END AS cst_gndr,

        cst_create_date

    FROM
    (
        SELECT
            *,
            ROW_NUMBER() OVER
            (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last

        FROM bronze.crm_cust_info

        WHERE cst_id IS NOT NULL
    ) t

    WHERE flag_last = 1;

    end_time := clock_timestamp();

    RAISE NOTICE
        '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

    RAISE NOTICE '>> -------------';


    /*
    ===========================================================================
    2. Loading silver.crm_prd_info
    ===========================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';

    TRUNCATE TABLE silver.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';

    INSERT INTO silver.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_name,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )

    SELECT
        prd_id,

        /*
        Extract category ID
        Example:
        AC-BR → AC_BR
        */
        REPLACE(
            SUBSTRING(prd_key FROM 1 FOR 5),
            '-',
            '_'
        ) AS cat_id,

        /*
        Extract product key
        */
        SUBSTRING(
            prd_key FROM 7
        ) AS prd_key,

        TRIM(prd_name) AS prd_name,

        /*
        Replace NULL cost with 0
        */
        COALESCE(prd_cost, 0) AS prd_cost,

        /*
        Convert product line codes
        */
        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M'
                THEN 'Mountain'

            WHEN UPPER(TRIM(prd_line)) = 'R'
                THEN 'Road'

            WHEN UPPER(TRIM(prd_line)) = 'S'
                THEN 'Other Sales'

            WHEN UPPER(TRIM(prd_line)) = 'T'
                THEN 'Touring'

            ELSE 'n/a'
        END AS prd_line,

        /*
        Convert start date
        */
        prd_start_dt::DATE AS prd_start_dt,

        /*
        Calculate end date:
        one day before next product start date
        */
        (
            LEAD(prd_start_dt) OVER
            (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ) - 1
        )::DATE AS prd_end_dt

    FROM bronze.crm_prd_info;

    end_time := clock_timestamp();

    RAISE NOTICE
        '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

    RAISE NOTICE '>> -------------';


    /*
    ===========================================================================
    3. Loading silver.crm_sales_details
    ===========================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';

    TRUNCATE TABLE silver.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';

    INSERT INTO silver.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )

    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        /*
        Convert order date YYYYMMDD → DATE
        */
        CASE
            WHEN sls_order_dt = 0
              OR LENGTH(sls_order_dt::TEXT) != 8
            THEN NULL

            ELSE TO_DATE(
                sls_order_dt::TEXT,
                'YYYYMMDD'
            )
        END AS sls_order_dt,

        /*
        Convert ship date
        */
        CASE
            WHEN sls_ship_dt = 0
              OR LENGTH(sls_ship_dt::TEXT) != 8
            THEN NULL

            ELSE TO_DATE(
                sls_ship_dt::TEXT,
                'YYYYMMDD'
            )
        END AS sls_ship_dt,

        /*
        Convert due date
        */
        CASE
            WHEN sls_due_dt = 0
              OR LENGTH(sls_due_dt::TEXT) != 8
            THEN NULL

            ELSE TO_DATE(
                sls_due_dt::TEXT,
                'YYYYMMDD'
            )
        END AS sls_due_dt,

        /*
        Fix invalid sales amount
        */
        CASE
            WHEN sls_sales <= 0
              OR sls_sales IS NULL
              OR sls_sales != sls_quantity * ABS(sls_price)

            THEN sls_quantity * ABS(sls_price)

            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        /*
        Fix invalid price
        */
        CASE
            WHEN sls_price <= 0
              OR sls_price IS NULL

            THEN sls_sales / NULLIF(sls_quantity, 0)

            ELSE sls_price
        END AS sls_price

    FROM bronze.crm_sales_details;

    end_time := clock_timestamp();

    RAISE NOTICE
        '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

    RAISE NOTICE '>> -------------';


    /*
    ===========================================================================
    ERP TABLES
    ===========================================================================
    */

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';


    /*
    ===========================================================================
    4. Loading silver.erp_cust_az12
    ===========================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';

    TRUNCATE TABLE silver.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';

    INSERT INTO silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )

    SELECT

        /*
        Remove NAS prefix from customer ID
        */
        CASE
            WHEN cid LIKE 'NAS%'
                THEN SUBSTRING(cid FROM 4)

            ELSE cid
        END AS cid,

        /*
        Remove future birthdates
        */
        CASE
            WHEN bdate > CURRENT_DATE
                THEN NULL

            ELSE bdate
        END AS bdate,

        /*
        Standardize gender
        */
        CASE
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                THEN 'Male'

            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                THEN 'Female'

            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;

    end_time := clock_timestamp();

    RAISE NOTICE
        '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

    RAISE NOTICE '>> -------------';


    /*
    ===========================================================================
    5. Loading silver.erp_loc_a101
    ===========================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';

    TRUNCATE TABLE silver.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';

    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )

    SELECT

        /*
        Remove '-' from customer ID
        */
        REPLACE(cid, '-', '') AS cid,

        /*
        Standardize country values
        */
        CASE

            WHEN TRIM(UPPER(cntry)) IN ('USA', 'US')
                THEN 'United States'

            WHEN TRIM(UPPER(cntry)) = 'DE'
                THEN 'Germany'

            WHEN cntry IS NULL
              OR TRIM(cntry) = ''
                THEN 'n/a'

            ELSE TRIM(cntry)

        END AS cntry

    FROM bronze.erp_loc_a101;

    end_time := clock_timestamp();

    RAISE NOTICE
        '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

    RAISE NOTICE '>> -------------';


    /*
    ===========================================================================
    6. Loading silver.erp_px_cat_g1v2
    ===========================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';

    INSERT INTO silver.erp_px_cat_g1v2
    (
        id,
        cat,
        subcat,
        maintenance
    )

    SELECT
        TRIM(id) AS id,
        TRIM(cat) AS cat,
        TRIM(subcat) AS subcat,
        TRIM(maintenance) AS maintenance

    FROM bronze.erp_px_cat_g1v2;

    end_time := clock_timestamp();

    RAISE NOTICE
        '>> Load Duration: % seconds',
        EXTRACT(EPOCH FROM (end_time - start_time));

    RAISE NOTICE '>> -------------';


    /*
    ===========================================================================
    End Silver Layer
    ===========================================================================
    */

    batch_end_time := clock_timestamp();

    RAISE NOTICE '================================================';

    RAISE NOTICE
        'Silver Layer Load Completed in % seconds',
        EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));

    RAISE NOTICE '================================================';
EXCEPTION
    WHEN OTHERS THEN

        RAISE NOTICE '================================================';
        RAISE NOTICE 'ERROR OCCURRED WHILE LOADING SILVER LAYER';
        RAISE NOTICE '================================================';

        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'SQL State: %', SQLSTATE;

        RAISE;
END;
$$;
call silver.load_silver()
