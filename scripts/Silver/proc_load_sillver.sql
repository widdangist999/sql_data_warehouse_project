
/*
===============================================================================
Stored Procedure: Silver Layer Loading
===============================================================================
Purpose:
    Loads and cleans data from Bronze Layer into Silver Layer.

Process:
    - Truncates existing Silver tables.
    - Cleans and standardizes source data.
    - Inserts transformed data into Silver tables.
    - Validates the number of rows after loading.

Usage:
    CALL silver_load_data();
===============================================================================
*/

-- Select the project database
USE DataWarehouseProject;

-- Remove the existing procedure before recreating it
DROP PROCEDURE IF EXISTS silver_load_data;

-- Change the delimiter to allow semicolons inside the procedure
DELIMITER $$

CREATE PROCEDURE silver_load_data()
BEGIN

    /*
    ===========================================================================
    1. CRM Customer Information
    ===========================================================================
    */

    -- Clear the existing data before reloading
    TRUNCATE TABLE silver_crm_cust_info;

    INSERT INTO silver_crm_cust_info (
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
        TRIM(cst_firstname) AS cst_firstname, -- Remove leading and trailing spaces
        TRIM(cst_lastname) AS cst_lastname,

        -- Standardize marital status codes
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S'
                THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M'
                THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,

        -- Standardize gender codes
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F'
                THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M'
                THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,

        cst_create_date

    FROM (
        SELECT
            *,
            -- Rank customer records from newest to oldest
            ROW_NUMBER() OVER (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last

        FROM bronze_crm_cust_info

        WHERE cst_id IS NOT NULL
          AND cst_id <> 0
    ) AS t

    -- Keep only the latest record for each customer
    WHERE flag_last = 1;


    /*
    ===========================================================================
    2. CRM Product Information
    ===========================================================================
    */

    TRUNCATE TABLE silver_crm_prd_info;

    INSERT INTO silver_crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,

        -- Extract the category ID and replace the hyphen with an underscore
        REPLACE(
            SUBSTRING(prd_key, 1, 5),
            '-',
            '_'
        ) AS cat_id,

        -- Extract the product key
        SUBSTRING(
            prd_key,
            7,
            LENGTH(prd_key)
        ) AS prd_key,

        prd_nm,

        -- Replace missing product costs with zero
        COALESCE(prd_cost, 0) AS prd_cost,

        -- Convert product line codes into descriptive values
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        prd_start_dt,

        -- Set the end date to one day before the next product start date
        CAST(
            DATE_SUB(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ),
                INTERVAL 1 DAY
            ) AS DATE
        ) AS prd_end_dt

    FROM bronze_crm_prd_info;


    /*
    ===========================================================================
    3. CRM Sales Details
    ===========================================================================
    */

    TRUNCATE TABLE silver_crm_sales_details;

    INSERT INTO silver_crm_sales_details (
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

    -- Convert date values and prepare data for price cleaning
    WITH cleaned_dates AS (
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            -- Convert order date from YYYYMMDD into a MySQL DATE
            CASE
                WHEN sls_order_dt IS NULL
                  OR CAST(sls_order_dt AS CHAR) = '0'
                  OR LENGTH(CAST(sls_order_dt AS CHAR)) <> 8
                    THEN NULL
                ELSE STR_TO_DATE(
                    CAST(sls_order_dt AS CHAR),
                    '%Y%m%d'
                )
            END AS sls_order_dt,

            -- Convert shipping date
            CASE
                WHEN sls_ship_dt IS NULL
                  OR CAST(sls_ship_dt AS CHAR) = '0'
                  OR LENGTH(CAST(sls_ship_dt AS CHAR)) <> 8
                    THEN NULL
                ELSE STR_TO_DATE(
                    CAST(sls_ship_dt AS CHAR),
                    '%Y%m%d'
                )
            END AS sls_ship_dt,

            -- Convert due date
            CASE
                WHEN sls_due_dt IS NULL
                  OR CAST(sls_due_dt AS CHAR) = '0'
                  OR LENGTH(CAST(sls_due_dt AS CHAR)) <> 8
                    THEN NULL
                ELSE STR_TO_DATE(
                    CAST(sls_due_dt AS CHAR),
                    '%Y%m%d'
                )
            END AS sls_due_dt,

            sls_sales,
            sls_quantity,
            sls_price

        FROM bronze_crm_sales_details
    ),

    -- Derive a usable price when the original price is missing or invalid
    cleaned_price AS (
        SELECT
            *,

            CASE
                WHEN sls_price IS NULL
                  OR sls_price <= 0
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS new_sls_price

        FROM cleaned_dates
    )

    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,

        -- Recalculate sales when the original value is invalid or inconsistent
        CASE
            WHEN sls_sales IS NULL
              OR sls_sales <= 0
              OR sls_sales <> sls_quantity * ABS(new_sls_price)
                THEN sls_quantity * ABS(new_sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,
        new_sls_price AS sls_price

    FROM cleaned_price;


    /*
    ===========================================================================
    4. ERP Customer Information
    ===========================================================================
    */

    TRUNCATE TABLE silver_erp_cust_az12;

    INSERT INTO silver_erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT
        -- Remove the NAS prefix from customer IDs when present
        CASE
            WHEN cid LIKE 'NAS%'
                THEN SUBSTRING(cid, 4, LENGTH(cid))
            ELSE cid
        END AS cid,

        -- Replace future birth dates with NULL
        CASE
            WHEN bdate > CURRENT_DATE()
                THEN NULL
            ELSE bdate
        END AS bdate,

        -- Remove carriage returns and standardize gender values
        CASE
            WHEN UPPER(
                TRIM(REPLACE(gen, CHAR(13), ''))
            ) IN ('F', 'FEMALE')
                THEN 'Female'

            WHEN UPPER(
                TRIM(REPLACE(gen, CHAR(13), ''))
            ) IN ('M', 'MALE')
                THEN 'Male'

            ELSE 'n/a'
        END AS gen

    FROM bronze_erp_cust_az12;


    /*
    ===========================================================================
    5. ERP Location Information
    ===========================================================================
    */

    TRUNCATE TABLE silver_erp_loc_a101;

    INSERT INTO silver_erp_loc_a101 (
        cid,
        cntry
    )
    SELECT
        -- Remove hyphens from customer IDs
        REPLACE(cid, '-', '') AS cid,

        -- Clean country values and standardize country codes
        CASE
            WHEN UPPER(
                TRIM(REPLACE(cntry, CHAR(13), ''))
            ) = 'DE'
                THEN 'Germany'

            WHEN UPPER(
                TRIM(REPLACE(cntry, CHAR(13), ''))
            ) IN ('US', 'USA')
                THEN 'United States'

            -- Handle NULL, empty, and whitespace-only values
            WHEN TRIM(
                REPLACE(cntry, CHAR(13), '')
            ) = ''
              OR cntry IS NULL
                THEN 'n/a'

            ELSE TRIM(
                REPLACE(cntry, CHAR(13), '')
            )
        END AS cntry

    FROM bronze_erp_loc_a101;


    /*
    ===========================================================================
    6. ERP Product Category Information
    ===========================================================================
    */

    TRUNCATE TABLE silver_erp_px_cat_g1v2;

    INSERT INTO silver_erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance

    FROM bronze_erp_px_cat_g1v2;

END $$

-- Restore the default delimiter
DELIMITER ;


/*
===============================================================================
Execute Silver Layer Loading
===============================================================================
*/

CALL silver_load_data();
