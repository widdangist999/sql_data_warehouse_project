# Data Catalog — DataWarehouseProject

## 1. Overview

The `DataWarehouseProject` database follows a Medallion Architecture with three layers:

- **Bronze Layer:** stores raw data imported from source CSV files.
- **Silver Layer:** cleans and standardizes CRM and ERP data.
- **Gold Layer:** presents business-ready views for analytics and reporting.

In this MySQL implementation, layers are represented by table-name prefixes (`bronze_`, `silver_`, and `gold_`) rather than separate schemas.

The Gold Layer is implemented as views built on top of Silver Layer tables. The views are designed as a simple star schema with customer and product dimensions connected to a sales fact view.

## 2. Naming Convention

| Prefix | Layer | Purpose |
|---|---|---|
| `bronze_` | Bronze | Raw imported data |
| `silver_` | Silver | Cleaned and standardized data |
| `gold_` | Gold | Business-ready analytical views |

All table and view names below use the exact naming convention currently used in the project.

---

## 3. Bronze Layer Tables

Bronze tables store data imported from the CRM and ERP source files. They are the starting point for the transformation pipeline.

### 3.1 `bronze_crm_cust_info`

**Purpose:** Stores raw CRM customer records.

| Column | Data type | Description |
|---|---|---|
| `cst_id` | Source-defined | Customer identifier from CRM. |
| `cst_key` | `VARCHAR` | Customer business key used to connect customer records across source systems. |
| `cst_firstname` | `VARCHAR` | Customer first name as supplied by the source. |
| `cst_lastname` | `VARCHAR` | Customer last name as supplied by the source. |
| `cst_marital_status` | Source-defined | Raw marital status code. |
| `cst_gndr` | Source-defined | Raw gender code. |
| `cst_create_date` | Source-defined | Customer record creation date from CRM. |

*Note: Bronze column types should be confirmed against the actual table DDL.*

### 3.2 `bronze_crm_prd_info`

**Purpose:** Stores raw CRM product records.

| Column | Data type | Description |
|---|---|---|
| `prd_id` | Source-defined | Product identifier. |
| `cat_id` | `VARCHAR` | Raw category identifier or product-key prefix. |
| `prd_key` | `VARCHAR` | Product business key. |
| `prd_nm` | `VARCHAR` | Product name. |
| `prd_cost` | Source-defined | Product cost. |
| `prd_line` | Source-defined | Raw product line code. |
| `prd_start_dt` | Source-defined | Product start date. |
| `prd_end_dt` | Source-defined | Source product end date, if present. |

### 3.3 `bronze_crm_sales_details`

**Purpose:** Stores raw CRM sales transaction details.

| Column | Data type | Description |
|---|---|---|
| `sls_ord_num` | Source-defined | Sales order number. |
| `sls_prd_key` | `VARCHAR` | Product business key associated with the transaction. |
| `sls_cust_id` | Source-defined | Customer identifier associated with the transaction. |
| `sls_order_dt` | Source-defined | Raw order date, often represented as `YYYYMMDD`. |
| `sls_ship_dt` | Source-defined | Raw shipping date, often represented as `YYYYMMDD`. |
| `sls_due_dt` | Source-defined | Raw due date, often represented as `YYYYMMDD`. |
| `sls_sales` | Source-defined | Raw sales amount. |
| `sls_quantity` | Source-defined | Quantity sold. |
| `sls_price` | Source-defined | Unit price. |

### 3.4 `bronze_erp_cust_az12`

**Purpose:** Stores raw ERP customer demographic data.

| Column | Data type | Description |
|---|---|---|
| `cid` | Source-defined | ERP customer identifier. |
| `bdate` | Source-defined | Customer birth date. |
| `gen` | Source-defined | Raw gender value. |

### 3.5 `bronze_erp_loc_a101`

**Purpose:** Stores raw ERP customer location data.

| Column | Data type | Description |
|---|---|---|
| `cid` | Source-defined | ERP customer identifier. |
| `cntry` | Source-defined | Raw country name or country code. |

### 3.6 `bronze_erp_px_cat_g1v2`

**Purpose:** Stores raw ERP product category information.

| Column | Data type | Description |
|---|---|---|
| `id` | Source-defined | Category identifier. |
| `cat` | Source-defined | Product category. |
| `subcat` | Source-defined | Product subcategory. |
| `maintenance` | Source-defined | Maintenance attribute from the source. |

---

## 4. Silver Layer Tables

Silver tables contain cleaned and standardized records loaded from Bronze. Their current DDL includes a `dwh_create_date` column with a default timestamp.

### 4.1 `silver_crm_cust_info`

**Purpose:** Stores deduplicated and standardized CRM customer information.

| Column | Data type | Description |
|---|---|---|
| `cst_id` | `INT` | Customer identifier. |
| `cst_key` | `VARCHAR(50)` | Customer business key. |
| `cst_firstname` | `VARCHAR(50)` | Trimmed first name. |
| `cst_lastname` | `VARCHAR(50)` | Trimmed last name. |
| `cst_marital_status` | `VARCHAR(50)` | Standardized marital status (`Single`, `Married`, or `n/a`). |
| `cst_gndr` | `VARCHAR(50)` | Standardized gender (`Female`, `Male`, or `n/a`). |
| `cst_create_date` | `DATE` | Customer record creation date. |
| `dwh_create_date` | `DATETIME` | Timestamp when the row is inserted into Silver by default. |

### 4.2 `silver_crm_prd_info`

**Purpose:** Stores standardized product information and derived product validity end dates.

| Column | Data type | Description |
|---|---|---|
| `prd_id` | `INT` | Product identifier. |
| `cat_id` | `VARCHAR(50)` | Category identifier derived from the product key. |
| `prd_key` | `VARCHAR(50)` | Extracted product business key. |
| `prd_nm` | `VARCHAR(100)` | Product name. |
| `prd_cost` | `INT` | Product cost; missing values are replaced with `0` during loading. |
| `prd_line` | `VARCHAR(50)` | Standardized product line (`Mountain`, `Road`, `Other Sales`, `Touring`, or `n/a`). |
| `prd_start_dt` | `DATE` | Product validity start date. |
| `prd_end_dt` | `DATE` | Derived end date, set to one day before the next start date for the same product key; may be `NULL` for the latest record. |
| `dwh_create_date` | `DATETIME` | Timestamp when the row is inserted into Silver by default. |

### 4.3 `silver_crm_sales_details`

**Purpose:** Stores sales records with converted dates and corrected price/sales values.

| Column | Data type | Description |
|---|---|---|
| `sls_ord_num` | `VARCHAR(50)` | Sales order number. |
| `sls_prd_key` | `VARCHAR(50)` | Product business key. |
| `sls_cust_id` | `INT` | Customer identifier. |
| `sls_order_dt` | `DATE` | Converted order date. |
| `sls_ship_dt` | `DATE` | Converted shipping date. |
| `sls_due_dt` | `DATE` | Converted due date. |
| `sls_sales` | `INT` | Cleaned sales amount. |
| `sls_quantity` | `INT` | Quantity sold. |
| `sls_price` | `INT` | Cleaned unit price. |
| `dwh_create_date` | `DATETIME` | Timestamp when the row is inserted into Silver by default. |

### 4.4 `silver_erp_cust_az12`

**Purpose:** Stores standardized ERP customer demographics.

| Column | Data type | Description |
|---|---|---|
| `cid` | `VARCHAR(50)` | Customer identifier, with the `NAS` prefix removed when present. |
| `bdate` | `DATE` | Birth date; future dates are replaced with `NULL`. |
| `gen` | `VARCHAR(50)` | Standardized gender (`Female`, `Male`, or `n/a`). |
| `dwh_create_date` | `DATETIME` | Timestamp when the row is inserted into Silver by default. |

### 4.5 `silver_erp_loc_a101`

**Purpose:** Stores standardized customer location information.

| Column | Data type | Description |
|---|---|---|
| `cid` | `VARCHAR(50)` | Customer identifier with hyphens removed. |
| `cntry` | `VARCHAR(100)` | Cleaned country name or original cleaned value; `DE` becomes `Germany`, `US`/`USA` becomes `United States`, and blank values become `n/a`. |
| `dwh_create_date` | `DATETIME` | Timestamp when the row is inserted into Silver by default. |

### 4.6 `silver_erp_px_cat_g1v2`

**Purpose:** Stores ERP product category and classification attributes.

| Column | Data type | Description |
|---|---|---|
| `id` | `VARCHAR(50)` | Category identifier. |
| `cat` | `VARCHAR(100)` | Product category. |
| `subcat` | `VARCHAR(100)` | Product subcategory. |
| `maintenance` | `VARCHAR(50)` | Maintenance attribute. |
| `dwh_create_date` | `DATETIME` | Timestamp when the row is inserted into Silver by default. |

---

## 5. Gold Layer Views

Gold views combine Silver data into business-friendly datasets. These are views, not physical tables, and their results are computed from the underlying Silver tables when queried.

### 5.1 `gold_dim_customers`

**Purpose:** Enriches CRM customer data with ERP demographic and geographic information.

| Column | Data type | Description |
|---|---|---|
| `customer_key` | `BIGINT` (derived) | Surrogate key generated using `ROW_NUMBER()`. It may change if the ordering or underlying data changes. |
| `customer_id` | `INT` | CRM customer identifier (`cst_id`). |
| `customer_number` | `VARCHAR(50)` | Customer business key (`cst_key`). |
| `first_name` | `VARCHAR(50)` | Customer first name. |
| `last_name` | `VARCHAR(50)` | Customer last name. |
| `country` | `VARCHAR(100)` | Country from ERP location data. |
| `marital_status` | `VARCHAR(50)` | Standardized marital status. |
| `gender` | `VARCHAR(50)` | CRM gender where available; otherwise ERP gender is used as fallback. |
| `birthdate` | `DATE` | Birth date from ERP customer data. |
| `create_date` | `DATE` | Customer creation date from CRM. |

**Source tables:**
- `silver_crm_cust_info`
- `silver_erp_cust_az12`
- `silver_erp_loc_a101`

**Join logic:**
- CRM customer key is joined to ERP customer ID.
- CRM customer key is joined to ERP location ID.

*Validation note: Confirm that identifier formats match across the three Silver tables; unmatched ERP data will result in `NULL` values.*

### 5.2 `gold_dim_products`

**Purpose:** Enriches CRM product data with ERP category and subcategory attributes. Only records where `prd_end_dt IS NULL` are included.

| Column | Data type | Description |
|---|---|---|
| `product_key` | `BIGINT` (derived) | Surrogate key generated using `ROW_NUMBER()`; may change when underlying data changes. |
| `product_id` | `INT` | Product identifier (`prd_id`). |
| `product_number` | `VARCHAR(50)` | Product business key (`prd_key`). |
| `product_name` | `VARCHAR(100)` | Product name. |
| `category_id` | `VARCHAR(50)` | Product category identifier. |
| `category` | `VARCHAR(100)` | Product category from ERP. |
| `subcategory` | `VARCHAR(100)` | Product subcategory from ERP. |
| `maintenance` | `VARCHAR(50)` | Maintenance attribute from ERP. |
| `cost` | `INT` | Product cost. |
| `product_line` | `VARCHAR(50)` | Standardized product line. |
| `start_date` | `DATE` | Product validity start date. |

**Source tables:**
- `silver_crm_prd_info`
- `silver_erp_px_cat_g1v2`

### 5.3 `gold_fact_sales`

**Purpose:** Provides sales transactions linked to the customer and product dimension views.

| Column | Data type | Description |
|---|---|---|
| `order_number` | `VARCHAR(50)` | Sales order number. |
| `product_key` | `BIGINT` (derived) | Product surrogate key from `gold_dim_products`; may be `NULL` if no matching product exists. |
| `customer_key` | `BIGINT` (derived) | Customer surrogate key from `gold_dim_customers`; may be `NULL` if no matching customer exists. |
| `order_date` | `DATE` | Order date. |
| `shipping_date` | `DATE` | Shipping date. |
| `due_date` | `DATE` | Due date. |
| `sales_amount` | `INT` | Cleaned sales amount for the transaction line. |
| `quantity` | `INT` | Units sold. |
| `price` | `INT` | Cleaned unit price. |

**Source tables:**
- `silver_crm_sales_details`
- `gold_dim_products`
- `gold_dim_customers`

**Join logic:**
- Sales product business key joins to `gold_dim_products.product_number`.
- Sales customer identifier joins to `gold_dim_customers.customer_id`.

---

## 6. Data Transformation Summary

| Layer / View | Transformation |
|---|---|
| `silver_crm_cust_info` | Removes invalid customer IDs, keeps the latest record per customer, trims names, standardizes marital status and gender. |
| `silver_crm_prd_info` | Derives category and product keys, replaces missing costs with zero, standardizes product line, derives product end dates. |
| `silver_crm_sales_details` | Converts date strings to dates, derives price when missing or invalid, recalculates invalid or inconsistent sales amounts. |
| `silver_erp_cust_az12` | Removes `NAS` ID prefixes, nulls future birth dates, standardizes gender. |
| `silver_erp_loc_a101` | Removes hyphens from IDs, cleans carriage returns, standardizes selected country codes. |
| `silver_erp_px_cat_g1v2` | Copies category attributes from Bronze without additional transformation. |
| `gold_dim_customers` | Combines CRM customer, ERP demographic, and ERP country information; prefers CRM gender and falls back to ERP gender. |
| `gold_dim_products` | Joins product and category data; filters to records with no end date. |
| `gold_fact_sales` | Joins sales transactions to customer and product dimension keys. |

---

## 7. Example Analytical Queries

### 7.1 Total sales, quantity, and orders

```sql
SELECT
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold_fact_sales;
```

### 7.2 Sales by product category

```sql
SELECT
    p.category,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;
```

### 7.3 Sales by country

```sql
SELECT
    c.country,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sales DESC;
```

### 7.4 Monthly sales trend

```sql
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    SUM(sales_amount) AS total_sales
FROM gold_fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;
```

---

## 8. Data Quality and Design Considerations

1. **Surrogate key stability:** `ROW_NUMBER()` generates keys based on the current view result. These keys are not guaranteed to remain stable when source records change. This is acceptable for a learning project but should be reconsidered for a production warehouse.
2. **Customer joins:** Confirm that `cst_key`, `cid`, and `sls_cust_id` use compatible formats and identifiers. A left join can preserve sales records while leaving dimension keys `NULL`.
3. **Product history:** `gold_dim_products` excludes rows with a non-`NULL` `prd_end_dt`. This gives a current-product view, but historical sales may not map to the product version that was active on the transaction date.
4. **Date dimension:** The current Gold design uses date columns directly in `gold_fact_sales`. A separate date dimension can be added later if richer calendar analysis is required.
5. **Data types:** Bronze source types are marked as source-defined where the exact DDL has not been confirmed. Verify actual DDL before treating this catalog as a formal schema contract.
6. **View refresh:** Gold views do not store their own copies of data. Their results reflect the current contents of the underlying Silver tables.

---

## 9. Project Structure

A suggested repository layout is:

```text
sql_data_warehouse_project/
├── datasets/
│   ├── source_crm/
│   └── source_erp/
├── scripts/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│       └── ddl_gold.sql
└── docs/
    └── data_catalog.md
```

The data catalog documents the intended meaning, source, and transformation logic of each table and view. Update it whenever the actual DDL or transformation logic changes.
