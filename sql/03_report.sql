-- Veri Kalitesi Kontrolü

-- Ham Verideki kontroller (buradaki islemlere gore etl adımları gerceklestirildi)
SELECT
    COUNT(*) AS total_rows, -- 750
    SUM(CASE WHEN store_id IS NULL OR LTRIM(RTRIM(store_id)) = '' THEN 1 ELSE 0 END) AS null_store_id, -- 0
    SUM(CASE WHEN store_name IS NULL OR LTRIM(RTRIM(store_name)) = '' THEN 1 ELSE 0 END) AS null_store_name, -- 0
    SUM(CASE WHEN product_category IS NULL OR LTRIM(RTRIM(product_category)) = '' THEN 1 ELSE 0 END) AS null_product_category, -- 0
    SUM(CASE WHEN [date] IS NULL OR LTRIM(RTRIM([date])) = '' THEN 1 ELSE 0 END) AS null_date, -- 0
    SUM(CASE WHEN unit_sales IS NULL THEN 1 ELSE 0 END) AS null_unit_sales, -- 5 !!!
    SUM(CASE WHEN dollar_sales IS NULL THEN 1 ELSE 0 END) AS null_dollar_sales, -- 7 !!!
    SUM(CASE WHEN store_zip IS NULL OR LTRIM(RTRIM(store_zip)) = '' THEN 1 ELSE 0 END) AS null_store_zip, -- 0
    SUM(CASE WHEN promotion_flag IS NULL OR LTRIM(RTRIM(promotion_flag)) = '' THEN 1 ELSE 0 END) AS null_promotion_flag -- 0
FROM etl.staging_sales;

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN unit_sales IS NULL THEN 1 ELSE 0 END) AS null_unit_sales,
    SUM(CASE WHEN dollar_sales IS NULL THEN 1 ELSE 0 END) AS null_dollar_sales
FROM etl.staging_sales;

--  DATE column'da tarih parse edilemeyecek kayıt var mi ? => Yok
SELECT * FROM etl.staging_sales WHERE TRY_CONVERT(DATE, [date], 1) IS NULL; -- 0

-- store_id column'da dogru formatta olmayan var mı ? => Yok
SELECT * FROM etl.staging_sales WHERE store_id NOT LIKE 'LA[0-9][0-9][0-9]'; -- 0

-- store_zip kodları kac gere geciyor 
SELECT store_zip, COUNT(*) AS row_count FROM etl.staging_sales GROUP BY store_zip ORDER BY row_count DESC; -- 900XX var !

-- 900XX old. icin kontrol
SELECT * FROM etl.staging_sales WHERE store_zip LIKE '%X%';

-- Kategori standartlaşma kısmı
-- SELECT DISTINCT product_category FROM etl.staging_sales ORDER BY product_category; 
-- Case Sensitive bu 
SELECT 
    product_category COLLATE Latin1_General_CS_AS,
    COUNT(*)
FROM etl.staging_sales
GROUP BY product_category COLLATE Latin1_General_CS_AS;

SELECT DISTINCT promotion_flag FROM etl.staging_sales; -- !!! bosluk var

SELECT * FROM etl.staging_sales WHERE unit_sales < 0 OR dollar_sales < 0; -- sorun yok

SELECT * FROM etl.staging_sales 
WHERE (unit_sales IS NULL AND dollar_sales IS NOT NULL) 
OR (unit_sales IS NOT NULL AND dollar_sales IS NULL); -- Sorun !!


-- Yeni tablo ile eski tablo karsilastirmasi 


SELECT COUNT(*) FROM etl.staging_sales; -- 750
SELECT COUNT(*) FROM etl.clean_sales;   -- 738 (beklenen)

SELECT DISTINCT product_category
FROM etl.clean_sales
ORDER BY product_category;

-- maskeli zip sayisi
SELECT zip_is_masked, COUNT(*) AS row_count
FROM etl.clean_sales
GROUP BY zip_is_masked;

SELECT
    SUM(CASE WHEN unit_sales IS NULL THEN 1 ELSE 0 END) AS null_unit_sales,
    SUM(CASE WHEN dollar_sales IS NULL THEN 1 ELSE 0 END) AS null_dollar_sales
FROM etl.clean_sales;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT store_id) AS store_count,
    COUNT(DISTINCT product_category) AS category_count
FROM etl.clean_sales;