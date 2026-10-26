use datawarehouseproject;

CREATE TABLE IF NOT EXISTS bronze_crm_cust_info(
cst_id int,
cst_key varchar(50),
cst_firstname varchar(100),
cst_lastname varchar(100),
cst_material_status varchar(50),
cst_gndr varchar(50),
cst_create_date date
);


CREATE TABLE IF NOT EXISTS bronze_crm_prd_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(100),
    prd_cost INT,
    prd_line VARCHAR(20),
    prd_start_dt DATE,
    prd_end_dt DATE
);


CREATE TABLE IF NOT EXISTS bronze_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);


CREATE TABLE IF NOT EXISTS bronze_erp_cust_az12 (
    CID VARCHAR(50),
    BDATE DATE,
    GEN VARCHAR(20)
);


CREATE TABLE IF NOT EXISTS bronze_erp_loc_a101 (
    CID VARCHAR(50),
    CNTRY VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS bronze_erp_px_cat_g1v2 (
    ID VARCHAR(50),
    CAT VARCHAR(100),
    SUBCAT VARCHAR(100),
    MAINTENANCE VARCHAR(10)
);

