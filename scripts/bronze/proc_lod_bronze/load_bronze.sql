
/*
===============================================================================
Script: Load Bronze Layer
===============================================================================
Purpose:
    Load raw CSV files into the Bronze tables in DataWarehouseProject.

Source:
    01_datasets/source_crm/
    01_datasets/source_erp/

Target:
    Six Bronze tables.

Prerequisites:
    1. Bronze tables have been created.
    2. CSV paths have been updated to match the local machine.
    3. LOCAL INFILE is enabled and permitted.

Important:
    Run 01_prepare_bronze.sql first if you want to replace existing data.
    This script does not perform data cleansing or business transformations.
===============================================================================
*/

USE DataWarehouseProject;

-- CRM: Customer Information
LOAD DATA LOCAL INFILE
'C:/Users/User/OneDrive/Dokumen/sql-data-warehouse-project-main/01_datasets/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- CRM: Product Information
LOAD DATA LOCAL INFILE
'C:/Users/User/OneDrive/Dokumen/sql-data-warehouse-project-main/01_datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- CRM: Sales Details
LOAD DATA LOCAL INFILE
'C:/Users/User/OneDrive/Dokumen/sql-data-warehouse-project-main/01_datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ERP: Location
LOAD DATA LOCAL INFILE
'C:/Users/User/OneDrive/Dokumen/sql-data-warehouse-project-main/01_datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ERP: Customer Information
LOAD DATA LOCAL INFILE
'C:/Users/User/OneDrive/Dokumen/sql-data-warehouse-project-main/01_datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ERP: Product Category
LOAD DATA LOCAL INFILE
'C:/Users/User/OneDrive/Dokumen/sql-data-warehouse-project-main/01_datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
