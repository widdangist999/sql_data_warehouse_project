
/*
===============================================================================
Procedure: Prepare Bronze Layer
===============================================================================
Purpose:
    Prepare Bronze tables before loading raw CSV files.

Actions:
    1. Record the process start time.
    2. Truncate all six Bronze tables.
    3. Record the process duration.
    4. Report errors if a SQL exception occurs.

Database:
    DataWarehouseProject

Usage:
    CALL prepare_bronze();

Warning:
    TRUNCATE TABLE permanently removes all rows from each target table.
===============================================================================
*/

USE DataWarehouseProject;

DROP PROCEDURE IF EXISTS prepare_bronze;

DELIMITER $$

CREATE PROCEDURE prepare_bronze()
BEGIN
    DECLARE v_start_time DATETIME;
    DECLARE v_end_time DATETIME;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT
            'ERROR' AS status,
            'Bronze preparation failed.' AS message;

        RESIGNAL;
    END;

    SET v_start_time = NOW();

    SELECT 'Preparing Bronze Layer' AS message;

    TRUNCATE TABLE bronze_crm_cust_info;
    TRUNCATE TABLE bronze_crm_prd_info;
    TRUNCATE TABLE bronze_crm_sales_details;
    TRUNCATE TABLE bronze_erp_loc_a101;
    TRUNCATE TABLE bronze_erp_cust_az12;
    TRUNCATE TABLE bronze_erp_px_cat_g1v2;

    SET v_end_time = NOW();

    SELECT
        'SUCCESS' AS status,
        'Bronze tables are ready for loading.' AS message,
        TIMESTAMPDIFF(
            SECOND,
            v_start_time,
            v_end_time
        ) AS duration_seconds;
END $$

DELIMITER ;

-- Execute the procedure
CALL prepare_bronze();
