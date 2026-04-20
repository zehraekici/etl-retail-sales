USE etl_db;

-- Extract (CSV’yi tabloya yükleme)
BULK INSERT etl.staging_sales
FROM '/tmp/LA_Retail_Sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

-- SELECT COUNT(*) AS total_rows FROM etl.staging_sales;
-- SELECT TOP 20 * FROM etl.staging_sales;

-- Clean table 
IF OBJECT_ID('etl.clean_sales','U') IS NOT NULL
    DROP TABLE etl.clean_sales;

CREATE TABLE etl.clean_sales (
    sales_key INT IDENTITY(1,1) PRIMARY KEY,
    store_id NVARCHAR(20),
    store_name NVARCHAR(100),
    product_category NVARCHAR(100),
    sale_date DATE,
    unit_sales INT,
    dollar_sales DECIMAL(12,2),
    avg_price DECIMAL(12,2),
    store_zip NVARCHAR(10),
    zip_is_masked BIT,
    promotion_flag BIT,
    load_datetime DATETIME2 DEFAULT SYSDATETIME()
);

-- Transform !!!
INSERT INTO etl.clean_sales
SELECT
    -- String temizleme
    LTRIM(RTRIM(store_id)),
    LTRIM(RTRIM(store_name)),

    -- category normalizasyonu
    UPPER(LTRIM(RTRIM(product_category))),

    -- type duzeltme
    TRY_CONVERT(DATE, [date], 1),
    TRY_CONVERT(INT, unit_sales),
    TRY_CONVERT(DECIMAL(12,2), dollar_sales),

    -- avg price
    -- artık NULL yok => division safe 
    TRY_CONVERT(DECIMAL(12,2), s.dollar_sales / s.unit_sales),

    -- 900XX'lar 90000 yapıldı
    CASE 
        WHEN store_zip LIKE '%X%' THEN '90000'
        ELSE LTRIM(RTRIM(store_zip))
    END,

    --  verinin değiştirildiği işaretlendi
    CASE 
        WHEN store_zip LIKE '%X%' THEN 1 ELSE 0
    END,

    -- promotion_flag temizlendi 
    CASE 
        WHEN UPPER(REPLACE(REPLACE(LTRIM(RTRIM(promotion_flag)), CHAR(13), ''), CHAR(10), '')) = 'TRUE'
        THEN 1 ELSE 0
    END

FROM etl.staging_sales
WHERE unit_sales IS NOT NULL AND dollar_sales IS NOT NULL;