/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    Validates the integrity and consistency of the Gold Layer views.

Checks:
    - Duplicate and NULL surrogate keys in dimension views.
    - Duplicate customer IDs and product numbers.
    - Sales records without matching customer or product dimensions.
    - Basic row counts for Gold views.

Usage:
    Run this script after creating the Gold views and loading the Silver Layer.
    Investigate any unexpected results.
===============================================================================
*/

USE DataWarehouseProject;


/*
===============================================================================
1. Customer Dimension: gold_dim_customers
===============================================================================
*/

-- Check for duplicate customer keys.
-- Expectation: No results.
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- Check for NULL customer keys.
-- Expectation: No results.
SELECT *
FROM gold_dim_customers
WHERE customer_key IS NULL;


-- Check for duplicate customer IDs.
-- Expectation: No results if each customer ID is unique.
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM gold_dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


/*
===============================================================================
2. Product Dimension: gold_dim_products
===============================================================================
*/

-- Check for duplicate product keys.
-- Expectation: No results.
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- Check for NULL product keys.
-- Expectation: No results.
SELECT *
FROM gold_dim_products
WHERE product_key IS NULL;


-- Check for duplicate product numbers.
-- Expectation: No results if each current product number is unique.
SELECT
    product_number,
    COUNT(*) AS duplicate_count
FROM gold_dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;


/*
===============================================================================
3. Sales Fact: gold_fact_sales
===============================================================================
*/

-- Find sales records without matching customer or product dimensions.
-- Expectation: No results if all dimension relationships are valid.
SELECT
    f.order_number,
    f.customer_key,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    f.price
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_customers AS c
    ON f.customer_key = c.customer_key
LEFT JOIN gold_dim_products AS p
    ON f.product_key = p.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;


-- Count sales records without a matching customer.
-- Expectation: 0.
SELECT
    COUNT(*) AS unmatched_customer_rows
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_customers AS c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


-- Count sales records without a matching product.
-- Expectation: 0.
SELECT
    COUNT(*) AS unmatched_product_rows
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_products AS p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


-- Check for NULL customer and product keys in the fact view.
-- Expectation: 0 for both columns if every transaction is matched.
SELECT
    SUM(
        CASE
            WHEN customer_key IS NULL THEN 1
            ELSE 0
        END
    ) AS null_customer_keys,

    SUM(
        CASE
            WHEN product_key IS NULL THEN 1
            ELSE 0
        END
    ) AS null_product_keys

FROM gold_fact_sales;


/*
===============================================================================
4. Sales Data Quality
===============================================================================
*/

-- Check for missing order numbers.
-- Expectation: No results.
SELECT *
FROM gold_fact_sales
WHERE order_number IS NULL
   OR TRIM(order_number) = '';


-- Check for invalid sales amounts or quantities.
-- Investigate any negative values or zero quantities.
SELECT *
FROM gold_fact_sales
WHERE sales_amount < 0
   OR quantity <= 0;


-- Check whether sales amounts are inconsistent with quantity and price.
-- Expectation: No results if sales_amount = quantity * price.
SELECT *
FROM gold_fact_sales
WHERE sales_amount <> quantity * price;


/*
===============================================================================
5. Gold View Row Counts
===============================================================================
*/

-- Review the number of records in each Gold view.
SELECT
    'gold_dim_customers' AS view_name,
    COUNT(*) AS total_rows
FROM gold_dim_customers

UNION ALL

SELECT
    'gold_dim_products',
    COUNT(*)
FROM gold_dim_products

UNION ALL

SELECT
    'gold_fact_sales',
    COUNT(*)
FROM gold_fact_sales;
