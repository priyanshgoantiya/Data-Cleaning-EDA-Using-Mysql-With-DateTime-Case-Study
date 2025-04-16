-- USE DATABASE
USE campusx;

-- COUNT TOTAL ROWS
SELECT COUNT(*) FROM laptop_;

-- EDA: MODIFY COLUMN TYPES
ALTER TABLE laptop_
MODIFY COLUMN Company VARCHAR(100),
MODIFY COLUMN TypeName VARCHAR(100),
MODIFY COLUMN OpSys VARCHAR(100);

ALTER TABLE laptop_
MODIFY COLUMN Cpu_Brand VARCHAR(100),
MODIFY COLUMN CPU_Model VARCHAR(100),
MODIFY COLUMN memory_type VARCHAR(100),
MODIFY COLUMN Gpu_brand_name VARCHAR(100),
MODIFY COLUMN Gpu_name VARCHAR(100);

-- HEAD, TAIL, AND SAMPLE
SELECT * FROM laptop_ ORDER BY price ASC LIMIT 5;
SELECT * FROM laptop_ ORDER BY price DESC LIMIT 5;
SELECT * FROM laptop_ ORDER BY RAND() LIMIT 5;

-- UNIVARIATE ANALYSIS ON NUMERIC DATA (price)

-- 8 NUMBER SUMMARY
SELECT 
    COUNT(price) AS total_count,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    STDDEV(price) AS std_price
FROM laptop_;

-- Q1
SELECT price AS q1
FROM (
    SELECT price, NTILE(4) OVER (ORDER BY price) AS quartile
    FROM laptop_
) AS t
WHERE quartile = 1
ORDER BY price DESC
LIMIT 1;

-- Q2
SELECT price AS q2
FROM (
    SELECT price, NTILE(4) OVER (ORDER BY price) AS quartile
    FROM laptop_
) AS t
WHERE quartile = 2
ORDER BY price DESC
LIMIT 1;

-- Q3
SELECT price AS q3
FROM (
    SELECT price, NTILE(4) OVER (ORDER BY price) AS quartile
    FROM laptop_
) AS t
WHERE quartile = 3
ORDER BY price DESC
LIMIT 1;

-- NULL VALUE CHECK
SELECT COUNT(*) AS null_prices FROM laptop_ WHERE price IS NULL;

-- OUTLIER DETECTION USING IQR METHOD
SELECT *
FROM laptop_
WHERE price > (((79866 - 32767) * 1.5) + 79866)
   OR price < (32767 - ((79866 - 32767) * 1.5));

SELECT COUNT(*) AS outlier_count
FROM laptop_
WHERE price > (((79866 - 32767) * 1.5) + 79866)
   OR price < (32767 - ((79866 - 32767) * 1.5));

-- HISTOGRAM USING STARS (VERTICAL BARS SIMULATED AS TEXT)
SELECT 
    '0-25k' AS Range_Label,
    REPEAT('*', FLOOR(SUM(CASE WHEN price BETWEEN 0 AND 25000 THEN 1 ELSE 0 END) / 5)) AS Histogram
FROM laptop_
UNION ALL
SELECT 
    '25-50k',
    REPEAT('*', FLOOR(SUM(CASE WHEN price BETWEEN 25001 AND 50000 THEN 1 ELSE 0 END) / 5))
FROM laptop_
UNION ALL
SELECT 
    '50-75k',
    REPEAT('*', FLOOR(SUM(CASE WHEN price BETWEEN 50001 AND 75000 THEN 1 ELSE 0 END) / 5))
FROM laptop_
UNION ALL
SELECT 
    '75-100k',
    REPEAT('*', FLOOR(SUM(CASE WHEN price BETWEEN 75001 AND 100000 THEN 1 ELSE 0 END) / 5))
FROM laptop_
UNION ALL
SELECT 
    '100-200k',
    REPEAT('*', FLOOR(SUM(CASE WHEN price BETWEEN 100001 AND 200000 THEN 1 ELSE 0 END) / 5))
FROM laptop_
UNION ALL
SELECT 
    '200-300k',
    REPEAT('*', FLOOR(SUM(CASE WHEN price BETWEEN 200001 AND 300000 THEN 1 ELSE 0 END) / 5))
FROM laptop_
UNION ALL
SELECT 
    '300-400k',
    REPEAT('*', FLOOR(SUM(CASE WHEN price BETWEEN 300001 AND 400000 THEN 1 ELSE 0 END) / 5))
FROM laptop_;

-- VALUE COUNT OF COMPANY COLUMN (also it is helpfull to spot missing values)
SELECT company, COUNT(*) AS total
FROM laptop_
GROUP BY company
ORDER BY total DESC;

-- numeric-numeric analysis 
-- 8-NUMBER SUMMARY FOR 'price' AND 'Processing_speed'

-- Summary for price
SELECT 'price' AS column_name,
    COUNT(price) AS total_count,
    MIN(price) AS min_val,
    MAX(price) AS max_val,
    AVG(price) AS mean_val,
    STDDEV(price) AS std_dev,(SELECT MAX(price) FROM (
        SELECT price, NTILE(4) OVER (ORDER BY price) AS q FROM laptop_
    ) AS t WHERE q = 1) AS Q1,
    (SELECT MAX(price) FROM (
        SELECT price, NTILE(4) OVER (ORDER BY price) AS q FROM laptop_
    ) AS t WHERE q = 2) AS Q2,
    (SELECT MAX(price) FROM (
        SELECT price, NTILE(4) OVER (ORDER BY price) AS q FROM laptop_
    ) AS t WHERE q = 3) AS Q3
FROM laptop_
UNION ALL

-- Summary for Processing_speed
SELECT 
    'Processing_speed' AS column_name,
    COUNT(Processing_speed) AS total_count,
    MIN(Processing_speed) AS min_val,
    MAX(Processing_speed) AS max_val,
    AVG(Processing_speed) AS mean_val,
    STDDEV(Processing_speed) AS std_dev,
    (SELECT MAX(Processing_speed) FROM (
        SELECT Processing_speed, NTILE(4) OVER (ORDER BY Processing_speed) AS q FROM laptop_
    ) AS t WHERE q = 1) AS Q1,
    (SELECT MAX(Processing_speed) FROM (
        SELECT Processing_speed, NTILE(4) OVER (ORDER BY Processing_speed) AS q FROM laptop_
    ) AS t WHERE q = 2) AS Q2,
    (SELECT MAX(Processing_speed) FROM (
        SELECT Processing_speed, NTILE(4) OVER (ORDER BY Processing_speed) AS q FROM laptop_
    ) AS t WHERE q = 3) AS Q3
from laptop_;
-- coorelation in mysql
SELECT 
    (AVG(Processing_speed * price) - AVG(Processing_speed) * AVG(price)) /
    (STDDEV(Processing_speed) * STDDEV(price)) AS corr_cpu_speed_price
FROM laptop_
WHERE Processing_speed IS NOT NULL AND price IS NOT NULL;

SELECT 
    'Inches' AS column_name,
    (AVG(Inches * price) - AVG(Inches) * AVG(price)) / (STDDEV(Inches) * STDDEV(price)) AS correlation
FROM laptop_ WHERE Inches IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'ScreenResolution_Width',
    (AVG(ScreenResolution_Width * price) - AVG(ScreenResolution_Width) * AVG(price)) / (STDDEV(ScreenResolution_Width) * STDDEV(price))
FROM laptop_ WHERE ScreenResolution_Width IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'ScreenResolution_Length',
    (AVG(ScreenResolution_Length * price) - AVG(ScreenResolution_Length) * AVG(price)) / (STDDEV(ScreenResolution_Length) * STDDEV(price))
FROM laptop_ WHERE ScreenResolution_Length IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'Has_Touch_Screen',
    (AVG(Has_Touch_Screen * price) - AVG(Has_Touch_Screen) * AVG(price)) / (STDDEV(Has_Touch_Screen) * STDDEV(price))
FROM laptop_ WHERE Has_Touch_Screen IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'Has_IPS_Panel',
    (AVG(Has_IPS_Panel * price) - AVG(Has_IPS_Panel) * AVG(price)) / (STDDEV(Has_IPS_Panel) * STDDEV(price))
FROM laptop_ WHERE Has_IPS_Panel IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'Processing_speed',
    (AVG(Processing_speed * price) - AVG(Processing_speed) * AVG(price)) / (STDDEV(Processing_speed) * STDDEV(price))
FROM laptop_ WHERE Processing_speed IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'Ram',
    (AVG(Ram * price) - AVG(Ram) * AVG(price)) / (STDDEV(Ram) * STDDEV(price))
FROM laptop_ WHERE Ram IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'primary_memory',
    (AVG(primary_memory * price) - AVG(primary_memory) * AVG(price)) / (STDDEV(primary_memory) * STDDEV(price))
FROM laptop_ WHERE primary_memory IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'secondary_memory',
    (AVG(secondary_memory * price) - AVG(secondary_memory) * AVG(price)) / (STDDEV(secondary_memory) * STDDEV(price))
FROM laptop_ WHERE secondary_memory IS NOT NULL AND price IS NOT NULL

UNION ALL

SELECT 
    'weight',
    (AVG(weight * price) - AVG(weight) * AVG(price)) / (STDDEV(weight) * STDDEV(price))
FROM laptop_ WHERE weight IS NOT NULL AND price IS NOT NULL
ORDER BY correlation DESC;


-- categorical-categorical analysis 
select Company,
sum(case when Has_Touch_Screen=1 then 1 else 0 end ) as Has_Touch_Screen,
sum(case when Has_Touch_Screen=0 then 1 else 0 end ) as not_Touch_Screen
from laptop_
group by Company;

select Company,
sum(case when Has_IPS_Panel=1 then 1 else 0 end ) as Has_IPS_Panel,
sum(case when Has_IPS_Panel=0 then 1 else 0 end ) as not_IPS_Panel
from laptop_
group by Company;


select Company,
sum(case when Cpu_Brand='Intel' then 1 else 0 end ) as 'Intel',
sum(case when Cpu_Brand='AMD' then 1 else 0 end ) as 'AMD',
sum(case when Cpu_Brand='Samsung' then 1 else 0 end ) as 'Samsung'
from laptop_
group by Company;

-- numeric - categoric columns analysis
select Company,min(price),max(price),avg(price),stddev(price)
from laptop_
group by Company;

select *
from laptop_
where price is null;

-- as we dont have null values so we can create it
UPDATE laptop_
SET price = NULL
ORDER BY RAND()
LIMIT 10;

-- missing value imputation 
update laptop_ as l1
join  (select Company,avg(price) as avg_price from laptop_ 
where price is not null
group by Company ) as l2
on l1.Company=l2.Company
set l1.price=l2.avg_price
where l1.price is null;

-- feature Engg.
SELECT 
    'PPI',
    (AVG(PPI * price) - AVG(PPI) * AVG(price)) / (STDDEV(PPI) * STDDEV(price))
FROM laptop_ WHERE PPI IS NOT NULL AND price IS NOT NULL;

alter table laptop_
add column PPI int after ScreenResolution_Length;

select round((SQRT((ScreenResolution_Width*ScreenResolution_Width) + (ScreenResolution_Length*ScreenResolution_Length)))/Inches,2)
from laptop_;
update laptop_
set PPI= round((SQRT((ScreenResolution_Width*ScreenResolution_Width) + (ScreenResolution_Length*ScreenResolution_Length)))/Inches,2);

select max(PPI)
from laptop_;

alter table laptop_
add column Screen_size varchar(50) after Inches;

select 
case
     when Ntile(4) over(order by Inches) =1 then 'Small' 
     when Ntile(4) over(order by Inches) =2 then 'Moderate' 
     when Ntile(4) over(order by Inches) =3 then 'High' 
     when Ntile(4) over(order by Inches) =4 then 'Very High'  end as screen_size
from laptop_;


update laptop_
set Screen_size=(case
     when Inches<=14 then 'Small' 
     when Inches>14  and Inches<=17 then 'Moderate' 
    else  'High' end);
    

select Screen_size,avg(price)
from laptop_
group by Screen_size
;


select distinct Gpu_brand_name
from laptop_;
-- one hot encoding in mysql
select Gpu_brand_name,
case when Gpu_brand_name='Intel' then 1 else 0 end as 'Intel',
case when Gpu_brand_name='AMD' then 1 else 0 end as 'AMD',
case when Gpu_brand_name='ARM' then 1 else 0 end as 'ARM',
case when Gpu_brand_name='Nvidia' then 1 else 0 end as 'Nvidia'
from laptop_;

ALTER TABLE laptop_ 
ADD COLUMN Intel INT,
ADD COLUMN AMD INT,
ADD COLUMN Nvidia INT;
     
UPDATE laptop_
SET 
    Intel = CASE WHEN Gpu_brand_name = 'Intel' THEN 1 ELSE 0 END,
    AMD = CASE WHEN Gpu_brand_name = 'AMD' THEN 1 ELSE 0 END,
    Nvidia = CASE WHEN Gpu_brand_name = 'Nvidia' THEN 1 ELSE 0 END;

select * 
from laptop_;

ALTER TABLE laptop_ 
drop COLUMN Gpu_brand_name;

-- less usefull
ALTER TABLE laptop_ 
drop COLUMN Gpu_name;

select distinct OpSys
from laptop_
;
--  macOS,N/A,Windows,Linux,Android

ALTER TABLE laptop_ 
ADD COLUMN  macOS INT,
ADD COLUMN Windows INT,
ADD COLUMN Linux INT,
ADD COLUMN Android INT;

UPDATE laptop_
SET 
    macOS = CASE WHEN OpSys = 'macOS' THEN 1 ELSE 0 END,
    Windows = CASE WHEN OpSys = 'Windows' THEN 1 ELSE 0 END,
    Linux = CASE WHEN OpSys = 'Linux' THEN 1 ELSE 0 END,
    Android = CASE WHEN OpSys = 'Android' THEN 1 ELSE 0 END
;
ALTER TABLE laptop_ 
drop COLUMN  OpSys;
select *
from laptop_;

select distinct CPU_Model
from laptop_;
