# SQL Data Warehouse Project

## Overview

This project focuses on building a data warehouse using **MySQL** to consolidate sales data from two source systems: Enterprise Resource Planning (ERP) and Customer Relationship Management (CRM), provided as CSV files.

The project follows the **Medallion Architecture**, consisting of Bronze, Silver, and Gold layers, to organize data ingestion, cleansing, standardization, and transformation into a business-ready data model for analytical reporting and data-driven decision-making.

## Objectives

- **Data Integration:** Consolidate sales-related data from ERP and CRM source systems.
- **Data Cleansing:** Identify and resolve data quality issues to improve data consistency and reliability.
- **Data Transformation:** Standardize and transform raw data into a structured format suitable for analysis.
- **Data Modeling:** Develop an analytical data model to support SQL queries and business reporting.
- **Documentation:** Document the data architecture, data model, and transformation processes.

## Architecture

The project follows the Medallion Architecture:

- **Bronze Layer:** Stores raw data imported from ERP and CRM CSV files with minimal transformation.
- **Silver Layer:** Cleanses, standardizes, and validates data to improve quality and consistency.
- **Gold Layer:** Organizes processed data into a business-ready structure for analytical queries and reporting.

## Scope

- Data sources consist of ERP and CRM CSV files.
- The project focuses on the latest available dataset.
- Historical data tracking and historization are outside the current scope.
- MySQL is used for database management and SQL-based data processing.
- The data model is designed to support analytical queries and business reporting.

## Tools & Technologies

- **MySQL** — Database management and data processing.
- **SQL** — Data ingestion, cleansing, transformation, integration, and analysis.
- **CSV** — Source data format.
- **Draw.io** — Data architecture diagrams.
- **GitHub** — Version control and project documentation.

## Expected Outcomes

- A centralized data warehouse integrating ERP and CRM data.
- Improved data quality through cleansing and standardization.
- A structured data model for analytical queries.
- Documented data architecture and transformation workflows.
- A foundation for business intelligence reporting and further data analysis.

## Project Status

This project is currently under development. The repository will be updated as the architecture, SQL scripts, data transformations, validation processes, and documentation are implemented.
