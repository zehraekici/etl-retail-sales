# Los Angeles Retail Sales ETL Projesi

Bu proje, Los Angeles perakende satış verilerini içeren ham CSV dosyalarını SQL Server ortamına aktarmak, temizlemek ve analiz edilebilir bir veri modeline dönüştürmek için tasarlanmıştır. ETL (Extract, Transform, Load) süreci geliştirilmiştir. 

---

## Kullanılan Teknolojiler
- SQL Server / Azure SQL
- BULK INSERT

---

## ETL Süreci

### 1. Extract (Veri Alma)
- CSV dosyası `BULK INSERT` ile `etl.staging_sales` tablosuna yüklendi.

---

### 2. Transform (Temizleme ve Dönüştürme)

Uygulanan işlemler:

- String alanlarda boşluk temizleme (`LTRIM`, `RTRIM`)
- `product_category` kolonunu standartlaştırma (`UPPER`)
- `date` kolonunu `DATE` tipine dönüştürme
- Sayısal alanları uygun tipe çevirme (`INT`, `DECIMAL`)
- `unit_sales` ve `dollar_sales` NULL olan kayıtları filtreleme
- `avg_price = dollar_sales / unit_sales` hesaplama (0’a bölme kontrolü ile)
- `promotion_flag` alanındaki gizli karakterleri temizleme ve `BIT` tipine dönüştürme
- Maskelenmiş ZIP kodlarını düzeltme (`900XX → 90000`)
- Bu kayıtları `zip_is_masked` kolonu ile işaretleme

---

### 3. Load (Yükleme)
- Temizlenmiş veri `etl.clean_sales` tablosuna yüklendi.

---

## Veri Kalitesi Kontrolleri

Staging katmanında aşağıdaki kontroller yapılmıştır:

- NULL değer analizi (`unit_sales`, `dollar_sales`)
- Tarih formatı doğrulama
- Store ID format kontrolü (`LA###`)
- Maskelenmiş ZIP kodlarının tespiti
- Kategori alanında büyük/küçük harf tutarsızlıkları
- `promotion_flag` alanında gizli karakter kontrolü
- Negatif değer kontrolü
- Tutarsız NULL kombinasyonları

---

## Tablolar

### `etl.staging_sales`
- CSV’den alınan ham veri

### `etl.clean_sales`
- Temizlenmiş ve analiz için hazır veri

---

## Proje Yapısı
sql/
├── 01_setup.sql # Schema ve staging tablo
├── 02_etl.sql # Extract + Transform + Load
└── 03_reporting.sql # Veri kalite kontrolleri

---


## Çalıştırma

Scriptleri aşağıdaki sırayla çalıştır:

01_setup.sql
02_etl.sql
03_reporting.sql

---
## Önemli Not

`BULK INSERT` dosya yolu çalıştığınız ortama göre değiştirilmelidir:

```sql
FROM '/tmp/LA_Retail_Sales.csv'