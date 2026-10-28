
/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    Creates views for the Gold Layer using data from the Silver Layer.

    The views form a star-schema structure consisting of customer and product
    dimensions, along with a sales fact view.

Views Created:
    1. gold_dim_customers
    2. gold_dim_products
    3. gold_fact_sales

Usage:
    These views can be queried directly for analytics and reporting.
===============================================================================
*/

USE DataWarehouseProject;


/*
===============================================================================
1. Dimension: gold_dim_customers
===============================================================================
Purpose:
    Combines CRM customer data with ERP customer and location information.

    CRM is the primary source for gender. ERP gender is used as a fallback
    when the CRM value is unavailable.
===============================================================================
*/

CREATE OR REPLACE VIEW gold_dim_customers AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY ci.cst_id
    ) AS customer_key,                       -- Generate a surrogate key

    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,

    -- Use ERP gender when the CRM value is unavailable
    CASE
        WHEN ci.cst_gndr <> 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date

FROM silver_crm_cust_info AS ci

LEFT JOIN silver_erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver_erp_loc_a101 AS la
    ON ci.cst_key = la.cid;


/*
===============================================================================
2. Dimension: gold_dim_products
===============================================================================
Purpose:
    Combines product information with ERP category data.

    Only current product records are included by filtering out products
    that have an end date.
===============================================================================
*/

CREATE OR REPLACE VIEW gold_dim_products AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,                        -- Generate a surrogate key

    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance AS maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date

FROM silver_crm_prd_info AS pn

LEFT JOIN silver_erp_px_cat_g1v2 AS pc
    ON pn.cat_id = pc.id

-- Keep current product records only
WHERE pn.prd_end_dt IS NULL;


/*
===============================================================================
3. Fact: gold_fact_sales
===============================================================================
Purpose:
    Combines sales transactions with customer and product dimension keys.

    The view supports sales analysis by order, customer, product, and date.
===============================================================================
*/

CREATE OR REPLACE VIEW gold_fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price

FROM silver_crm_sales_details AS sd

LEFT JOIN gold_dim_products AS pr
    ON sd.sls_prd_key = pr.product_number

LEFT JOIN gold_dim_customers AS cu
    ON sd.sls_cust_id = cu.customer_id;
