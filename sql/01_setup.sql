CREATE DATABASE etl_db;
GO

USE etl_db;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'etl'
)
BEGIN
    EXEC('CREATE SCHEMA etl');
END;

IF OBJECT_ID('etl.staging_sales','U') IS NOT NULL
    DROP TABLE etl.staging_sales;

CREATE TABLE etl.staging_sales (
    store_id NVARCHAR(20),
    store_name NVARCHAR(100),
    product_category NVARCHAR(100),
    [date] NVARCHAR(20),
    unit_sales FLOAT NULL,
    dollar_sales FLOAT NULL,
    store_zip NVARCHAR(20),
    promotion_flag NVARCHAR(10)
);