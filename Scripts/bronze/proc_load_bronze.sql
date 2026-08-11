/*
===============================================================================
Stored Procedure: Load Bronze Layer
===============================================================================

Script Purpose:
    This stored procedure loads raw data from CSV source files into the
    Bronze layer tables.

    The procedure follows a simple ETL process:

        Source CSV Files
              ↓
        Bronze Tables

Actions:
    - Truncates existing data from Bronze tables.
    - Loads data from CSV files using PostgreSQL COPY.
    - Measures the loading duration for each table.
    - Displays progress messages using RAISE NOTICE.
    - Measures the total Bronze layer loading time.
    - Handles errors using PostgreSQL exception handling.

Tables Loaded:
    - bronze.crm_cust_info
    - bronze.crm_prd_info
    - bronze.crm_sales_details
    - bronze.erp_cust_az12
    - bronze.erp_loc_a101
    - bronze.erp_px_cat_g1v2

Parameters:
    None.

Usage:
    CALL bronze.load_bronze();

Important:
    The procedure truncates Bronze tables before loading.
    Therefore, existing Bronze data will be removed and replaced
    with the latest source data.

===============================================================================
*/


CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$

DECLARE

    -- Timing variables
    batch_start_time TIMESTAMP;
    batch_end_time   TIMESTAMP;

    start_time TIMESTAMP;
    end_time   TIMESTAMP;

    -- Duration in seconds
    duration NUMERIC;

BEGIN

    /*
    ============================================================================
    START BRONZE LOAD
    ============================================================================
    */

    batch_start_time := clock_timestamp();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Starting Bronze Layer Load';
    RAISE NOTICE '================================================';


    /*
    ============================================================================
    LOAD: CRM CUSTOMER
    ============================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';

    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';

    COPY bronze.crm_cust_info
    FROM 'D:\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
    WITH (
        FORMAT CSV,
        HEADER,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    duration := EXTRACT(
        EPOCH FROM (end_time - start_time)
    );

    RAISE NOTICE '>> Load Duration: % seconds', duration;


    /*
    ============================================================================
    LOAD: CRM PRODUCT
    ============================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';

    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';

    COPY bronze.crm_prd_info
    FROM 'D:\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
    WITH (
        FORMAT CSV,
        HEADER,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    duration := EXTRACT(
        EPOCH FROM (end_time - start_time)
    );

    RAISE NOTICE '>> Load Duration: % seconds', duration;


    /*
    ============================================================================
    LOAD: CRM SALES DETAILS
    ============================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';

    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';

    COPY bronze.crm_sales_details
    FROM 'D:\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
    WITH (
        FORMAT CSV,
        HEADER,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    duration := EXTRACT(
        EPOCH FROM (end_time - start_time)
    );

    RAISE NOTICE '>> Load Duration: % seconds', duration;


    /*
    ============================================================================
    LOAD: ERP CUSTOMER
    ============================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';

    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';

    COPY bronze.erp_cust_az12
    FROM 'D:\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
    WITH (
        FORMAT CSV,
        HEADER,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    duration := EXTRACT(
        EPOCH FROM (end_time - start_time)
    );

    RAISE NOTICE '>> Load Duration: % seconds', duration;


    /*
    ============================================================================
    LOAD: ERP LOCATION
    ============================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';

    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';

    COPY bronze.erp_loc_a101
    FROM 'D:\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
    WITH (
        FORMAT CSV,
        HEADER,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    duration := EXTRACT(
        EPOCH FROM (end_time - start_time)
    );

    RAISE NOTICE '>> Load Duration: % seconds', duration;


    /*
    ============================================================================
    LOAD: ERP PRODUCT CATEGORY
    ============================================================================
    */

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

    COPY bronze.erp_px_cat_g1v2
    FROM 'D:\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
    WITH (
        FORMAT CSV,
        HEADER,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    duration := EXTRACT(
        EPOCH FROM (end_time - start_time)
    );

    RAISE NOTICE '>> Load Duration: % seconds', duration;


    /*
    ============================================================================
    BRONZE LOAD COMPLETED
    ============================================================================
    */

    batch_end_time := clock_timestamp();

    duration := EXTRACT(
        EPOCH FROM (batch_end_time - batch_start_time)
    );

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Bronze Layer Load Completed Successfully';
    RAISE NOTICE 'Total Load Duration: % seconds', duration;
    RAISE NOTICE '================================================';


EXCEPTION

    WHEN OTHERS THEN

        RAISE NOTICE '================================================';
        RAISE NOTICE 'ERROR OCCURRED DURING BRONZE LOAD';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'SQL State: %', SQLSTATE;
        RAISE NOTICE '================================================';

        RAISE;

END;
$$;
