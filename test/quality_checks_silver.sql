/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    Validates data quality, consistency, and standardization in the Silver Layer.

Checks:
    - NULL or duplicate business keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and values.
    - Consistency between sales, quantity, and price.

Usage:
    Run these checks after loading the Silver Layer.
    Investigate any unexpected results.
===============================================================================
*/

USE DataWarehouseProject;


/*
===============================================================================
1. CRM Customer Information: silver_crm_cust_info
===============================================================================
*/

-- Check for NULL or duplicate customer IDs.
-- Expectation: No results.
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- Check for unwanted spaces in customer keys and names.
-- Expectation: No results.
SELECT
    cst_key,
    cst_firstname,
    cst_lastname
FROM silver_crm_cust_info
WHERE cst_key <> TRIM(cst_key)
   OR cst_firstname <> TRIM(cst_firstname)
   OR cst_lastname <> TRIM(cst_lastname);


-- Check marital status standardization.
-- Review the distinct values.
SELECT DISTINCT
    cst_marital_status
FROM silver_crm_cust_info;


-- Check gender standardization.
-- Review the distinct values.
SELECT DISTINCT
    cst_gndr
FROM silver_crm_cust_info;


/*
===============================================================================
2. CRM Product Information: silver_crm_prd_info
===============================================================================
*/

-- Check for NULL or duplicate product IDs.
-- Expectation: No results.
SELECT
    prd_id,
    COUNT(*) AS record_count
FROM silver_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- Check for unwanted spaces in product names and keys.
-- Expectation: No results.
SELECT
    prd_key,
    prd_nm
FROM silver_crm_prd_info
WHERE prd_key <> TRIM(prd_key)
   OR prd_nm <> TRIM(prd_nm);


-- Check for NULL or negative product costs.
-- Expectation: No results.
SELECT
    prd_id,
    prd_cost
FROM silver_crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


-- Check product line standardization.
-- Review the distinct values.
SELECT DISTINCT
    prd_line
FROM silver_crm_prd_info;


-- Check for invalid product date ranges.
-- Expectation: No results.
SELECT *
FROM silver_crm_prd_info
WHERE prd_start_dt IS NOT NULL
  AND prd_end_dt IS NOT NULL
  AND prd_end_dt < prd_start_dt;


/*
===============================================================================
3. CRM Sales Details: silver_crm_sales_details
===============================================================================
*/

-- Check for NULL order numbers.
-- Expectation: No results.
SELECT *
FROM silver_crm_sales_details
WHERE sls_ord_num IS NULL
   OR TRIM(sls_ord_num) = '';


-- Check for invalid date sequences.
-- Order date should not be later than shipping or due dates.
-- Expectation: No results, subject to business rules.
SELECT *
FROM silver_crm_sales_details
WHERE (sls_order_dt > sls_ship_dt
       AND sls_ship_dt IS NOT NULL)
   OR (sls_order_dt > sls_due_dt
       AND sls_due_dt IS NOT NULL);


-- Check consistency between sales, quantity, and price.
-- Expectation: No results if sales = quantity * price.
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver_crm_sales_details
WHERE sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
   OR sls_sales <> sls_quantity * sls_price
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;


-- Check for invalid or missing dates in the Silver Layer.
-- Review any NULL values.
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN sls_order_dt IS NULL THEN 1 ELSE 0 END)
        AS null_order_dates,
    SUM(CASE WHEN sls_ship_dt IS NULL THEN 1 ELSE 0 END)
        AS null_shipping_dates,
    SUM(CASE WHEN sls_due_dt IS NULL THEN 1 ELSE 0 END)
        AS null_due_dates
FROM silver_crm_sales_details;


/*
===============================================================================
4. ERP Customer Information: silver_erp_cust_az12
===============================================================================
*/

-- Identify birth dates outside the accepted range.
-- Expectation: No dates before 1924-01-01 or after today.
SELECT DISTINCT
    bdate
FROM silver_erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > CURRENT_DATE();


-- Check gender standardization.
-- Review the distinct values.
SELECT DISTINCT
    gen
FROM silver_erp_cust_az12;


/*
===============================================================================
5. ERP Location Information: silver_erp_loc_a101
===============================================================================
*/

-- Review standardized country values.
SELECT DISTINCT
    cntry
FROM silver_erp_loc_a101
ORDER BY cntry;


-- Check for unwanted spaces in country values.
-- Expectation: No results.
SELECT
    cid,
    cntry
FROM silver_erp_loc_a101
WHERE cntry <> TRIM(cntry);


/*
===============================================================================
6. ERP Product Category Information: silver_erp_px_cat_g1v2
===============================================================================
*/

-- Check for unwanted spaces in category fields.
-- Expectation: No results.
SELECT *
FROM silver_erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


-- Review maintenance values.
SELECT DISTINCT
    maintenance
FROM silver_erp_px_cat_g1v2;


/*
===============================================================================
7. Silver Layer Row Counts
===============================================================================
*/

-- Review the number of rows in each Silver table.
SELECT
    'silver_crm_cust_info' AS table_name,
    COUNT(*) AS total_rows
FROM silver_crm_cust_info

UNION ALL

SELECT
    'silver_crm_prd_info',
    COUNT(*)
FROM silver_crm_prd_info

UNION ALL

SELECT
    'silver_crm_sales_details',
    COUNT(*)
FROM silver_crm_sales_details

UNION ALL

SELECT
    'silver_erp_cust_az12',
    COUNT(*)
FROM silver_erp_cust_az12

UNION ALL

SELECT
    'silver_erp_loc_a101',
    COUNT(*)
FROM silver_erp_loc_a101

UNION ALL

SELECT
    'silver_erp_px_cat_g1v2',
    COUNT(*)
FROM silver_erp_px_cat_g1v2;
