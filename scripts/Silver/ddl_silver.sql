
/*
===============================================================================
DDL Script: Create Silver Layer Tables
===============================================================================
Script Purpose:
    Creates the Silver Layer tables used to store cleaned and standardized
    data from the Bronze Layer.

    The Silver Layer contains data from CRM and ERP source systems.

Tables Created:
    1. silver_crm_cust_info
    2. silver_crm_prd_info
    3. silver_crm_sales_details
    4. silver_erp_cust_az12
    5. silver_erp_loc_a101
    6. silver_erp_px_cat_g1v2

Important:
    - Table names use the silver_ prefix instead of a separate schema.
    - Existing tables are dropped and recreated when this script runs.
    - Running this script deletes the existing data in these tables.
===============================================================================
*/

USE DataWarehouseProject;


/*
===============================================================================
1. CRM Customer Information
===============================================================================
Source:
    bronze_crm_cust_info

Purpose:
    Stores cleaned customer information, including standardized names,
    marital status, gender, and customer creation date.
===============================================================================
*/

DROP TABLE IF EXISTS silver_crm_cust_info;

CREATE TABLE silver_crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    DATE,

    -- Records when the row is created in the Silver Layer
    dwh_create_date    DATETIME DEFAULT CURRENT_TIMESTAMP
);


/*
===============================================================================
2. CRM Product Information
===============================================================================
Source:
    bronze_crm_prd_info

Purpose:
    Stores cleaned product information, including product keys, category IDs,
    product costs, product lines, and product validity dates.
===============================================================================
*/

DROP TABLE IF EXISTS silver_crm_prd_info;

CREATE TABLE silver_crm_prd_info (
    prd_id          INT,
    cat_id          VARCHAR(50),
    prd_key         VARCHAR(50),
    prd_nm          VARCHAR(100),
    prd_cost        INT DEFAULT 0,
    prd_line        VARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,

    -- Records when the row is created in the Silver Layer
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


/*
===============================================================================
3. CRM Sales Details
===============================================================================
Source:
    bronze_crm_sales_details

Purpose:
    Stores cleaned sales transaction data, including converted order dates,
    shipping dates, due dates, sales amounts, quantities, and prices.
===============================================================================
*/

DROP TABLE IF EXISTS silver_crm_sales_details;

CREATE TABLE silver_crm_sales_details (
    sls_ord_num     VARCHAR(50),
    sls_prd_key     VARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT,

    -- Records when the row is created in the Silver Layer
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


/*
===============================================================================
4. ERP Customer Information
===============================================================================
Source:
    bronze_erp_cust_az12

Purpose:
    Stores cleaned ERP customer information, including standardized customer
    IDs, birth dates, and gender values.
===============================================================================
*/

DROP TABLE IF EXISTS silver_erp_cust_az12;

CREATE TABLE silver_erp_cust_az12 (
    cid             VARCHAR(50),
    bdate           DATE,
    gen             VARCHAR(50),

    -- Records when the row is created in the Silver Layer
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


/*
===============================================================================
5. ERP Location Information
===============================================================================
Source:
    bronze_erp_loc_a101

Purpose:
    Stores cleaned customer location information, including standardized
    customer IDs and country names.
===============================================================================
*/

DROP TABLE IF EXISTS silver_erp_loc_a101;

CREATE TABLE silver_erp_loc_a101 (
    cid             VARCHAR(50),
    cntry           VARCHAR(100),

    -- Records when the row is created in the Silver Layer
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


/*
===============================================================================
6. ERP Product Category Information
===============================================================================
Source:
    bronze_erp_px_cat_g1v2

Purpose:
    Stores ERP product category data, including category IDs, categories,
    subcategories, and maintenance information.
===============================================================================
*/

DROP TABLE IF EXISTS silver_erp_px_cat_g1v2;

CREATE TABLE silver_erp_px_cat_g1v2 (
    id              VARCHAR(50),
    cat             VARCHAR(100),
    subcat          VARCHAR(100),
    maintenance     VARCHAR(50),

    -- Records when the row is created in the Silver Layer
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
