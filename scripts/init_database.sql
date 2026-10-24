
/*
=============================================================
Create Database: DataWarehouseProject
=============================================================
Script Purpose:
    This script creates the DataWarehouseProject database
    if it does not already exist.

    Bronze, Silver, and Gold layers are organized into
    separate folders in the project repository and
    distinguished using table-name prefixes:
        bronze_
        silver_
        gold_

WARNING:
    This script does not drop or recreate an existing database.
    Existing data will remain safe.
=============================================================
*/

-- Create database if it does not exist
CREATE DATABASE IF NOT EXISTS DataWarehouseProject;

-- Select the database
USE DataWarehouseProject;

-- Verify the active database
SELECT DATABASE();
