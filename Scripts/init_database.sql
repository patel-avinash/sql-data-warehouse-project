/*
===============================================================================
Create Data Warehouse Database and Schemas
===============================================================================

Script Purpose:
    This script initializes the DataWarehouse database for the project.

    It creates:
        - DataWarehouse database
        - bronze schema
        - silver schema
        - gold schema

Architecture:
    Bronze → Silver → Gold

Important:
    PostgreSQL requires the database connection to be changed separately.
    Therefore, database creation and schema creation are handled in
    separate execution steps.

===============================================================================
*/

-- ============================================================================
-- STEP 1: Create DataWarehouse Database
-- ============================================================================
-- Run this section while connected to another database, such as "postgres".

CREATE DATABASE "DataWarehouse";


-- ============================================================================
-- STEP 2: Connect to DataWarehouse
-- ============================================================================
-- PostgreSQL does not support:
--     USE DataWarehouse;
--
-- In pgAdmin:
--     Databases → DataWarehouse → Query Tool
--
-- Continue with the following commands after connecting to DataWarehouse.


-- ============================================================================
-- STEP 3: Create Medallion Architecture Schemas
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;
