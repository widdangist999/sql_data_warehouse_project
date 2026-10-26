# Data Warehouse Project — Bronze Layer

## Overview

This project implements the Bronze Layer of a data warehouse using MySQL. The Bronze Layer serves as the initial landing layer for raw data imported from CRM and ERP CSV files.

The primary objective is to load source data into MySQL tables while minimizing data transformations during ingestion.

## Objectives

- Import raw CSV files into MySQL Bronze tables.
- Organize source data from CRM and ERP systems.
- Use a Stored Procedure to prepare Bronze tables before reloading.
- Separate table preparation and CSV ingestion into individual SQL scripts.
- Establish a foundation for subsequent Silver and Gold Layer development.

## Technology Stack

- **Database:** MySQL
- **SQL Client:** MySQL Workbench
- **Source Format:** CSV
- **SQL Features:** Stored Procedures, `TRUNCATE TABLE`, `LOAD DATA LOCAL INFILE`

## Project Structure

```text
DataWarehouseProject/
├── 01_datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── LOC_A101.csv
│       ├── CUST_AZ12.csv
│       └── PX_CAT_G1V2.csv
├── scripts/
│   └── bronze/
│       ├── 01_prepare_bronze.sql
│       └── 02_load_bronze.sql
└── README.md
```

## Source Data

The Bronze Layer receives six CSV files from two source systems.

| Source System | CSV File | Target Table |
|---|---|---|
| CRM | `cust_info.csv` | `bronze_crm_cust_info` |
| CRM | `prd_info.csv` | `bronze_crm_prd_info` |
| CRM | `sales_details.csv` | `bronze_crm_sales_details` |
| ERP | `LOC_A101.csv` | `bronze_erp_loc_a101` |
| ERP | `CUST_AZ12.csv` | `bronze_erp_cust_az12` |
| ERP | `PX_CAT_G1V2.csv` | `bronze_erp_px_cat_g1v2` |

## Data Loading Workflow

### 1. Prepare Bronze Tables

Execute `01_prepare_bronze.sql` in MySQL Workbench.

This script creates and calls the `prepare_bronze()` Stored Procedure. The procedure:

- Records the start time.
- Truncates the six Bronze tables.
- Calculates the elapsed time.
- Returns a success message or reports an SQL exception.

**Warning:** Truncating the tables removes their existing rows. Confirm that the source CSV files are available before running this step.

### 2. Load CSV Files

Execute `02_load_bronze.sql` after preparing the tables.

The script uses `LOAD DATA LOCAL INFILE` to import each CSV file into its corresponding Bronze table. The first row is skipped because it contains column headers.

No business-level cleansing or transformation is intentionally performed during this loading step.

### 3. Validate the Loaded Data

After loading, check the number of rows in each table.

```sql
USE DataWarehouseProject;

SELECT 'bronze_crm_cust_info' AS table_name,
       COUNT(*) AS total_rows
FROM bronze_crm_cust_info

UNION ALL

SELECT 'bronze_crm_prd_info',
       COUNT(*)
FROM bronze_crm_prd_info

UNION ALL

SELECT 'bronze_crm_sales_details',
       COUNT(*)
FROM bronze_crm_sales_details

UNION ALL

SELECT 'bronze_erp_loc_a101',
       COUNT(*)
FROM bronze_erp_loc_a101

UNION ALL

SELECT 'bronze_erp_cust_az12',
       COUNT(*)
FROM bronze_erp_cust_az12

UNION ALL

SELECT 'bronze_erp_px_cat_g1v2',
       COUNT(*)
FROM bronze_erp_px_cat_g1v2;
```

Compare the results with the number of data records in the source CSV files. The expected row counts should be verified against the actual files rather than assumed.

## Prerequisites

Before running the scripts:

1. Create the `DataWarehouseProject` database and the six Bronze tables.
2. Update the CSV file paths in `02_load_bronze.sql` to match your local environment.
3. Ensure that `LOCAL INFILE` is enabled and permitted by the MySQL client and server configuration.
4. Ensure that the target tables have columns compatible with the CSV data.
5. Keep a backup if the existing Bronze data must be retained.

## Important Notes

- The `prepare_bronze()` Stored Procedure handles table preparation; it does not load CSV files.
- The CSV loading commands are executed separately in MySQL Workbench.
- Re-running the loading script without truncating the tables first may append duplicate rows.
- Raw ingestion minimizes transformations, but MySQL data types and CSV parsing rules can still affect how values are stored.
- This implementation does not yet provide a single-command orchestration of the complete loading process.

## Next Steps

- Develop the Silver Layer for data cleaning and standardization.
- Implement data quality checks.
- Build the Gold Layer for analytical reporting.
- Add automated logging and orchestration for the ingestion workflow.

## Project Status

**Current stage:** Bronze Layer ingestion and preparation.

The current implementation supports table preparation through a Stored Procedure and CSV loading through separate MySQL statements.
