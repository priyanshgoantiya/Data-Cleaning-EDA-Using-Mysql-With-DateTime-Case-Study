use campusx;

select * 
from price_of_laptopdata;

-- create a backup as we are performing data cleaning with mysql 
create table laptop like laptop_backup;
insert into laptop
select * from laptop_backup;

-- show backup data
select * from laptop_backup;



-- Check no. of rows and columns
SELECT COUNT(*) FROM laptop_backup; 
DESCRIBE laptop_backup;

-- Memory occupied by data
SELECT Data_length 
FROM information_schema.Tables
WHERE table_schema = 'campusx' AND table_name = 'laptop_backup';

-- Drop non-important columns
ALTER TABLE laptop_backup
DROP COLUMN `Unnamed: 0`;

SELECT * FROM laptop_backup;

-- Drop null values
SELECT 
    SUM(ScreenResolution IS NULL),
    SUM(Ram IS NULL),
    SUM(Memory IS NULL),
    SUM(OpSys IS NULL), 
    SUM(Weight IS NULL), 
    SUM(price IS NULL),
    SUM(company IS NULL),
    SUM(Inches IS NULL)
FROM laptop_backup;

SELECT 
    COUNT(*) AS empty_screenres
FROM laptop_backup
WHERE TRIM(ScreenResolution) = '';

SELECT 
    COUNT(*) AS string_nulls
FROM laptop_backup
WHERE LOWER(ScreenResolution) = 'null';

SELECT * 
FROM laptop_backup
WHERE ScreenResolution IS NULL 
  AND Ram IS NULL 
  AND `Memory` IS NULL 
  AND OpSys IS NULL 
  AND Weight IS NULL 
  AND price IS NULL 
  AND company IS NULL 
  AND Inches IS NULL 
  AND Gpu IS NULL 
  AND `Cpu` IS NULL 
  AND TypeName IS NULL 
  AND company IS NULL;

-- Drop duplicate rows 
-- Showing duplicates
SELECT Company, TypeName, Inches, ScreenResolution, `Cpu`, Ram, `Memory`, Gpu, OpSys, Weight, Price, COUNT(*) AS cnt
FROM laptop_backup
GROUP BY Company, TypeName, Inches, ScreenResolution, `Cpu`, Ram, `Memory`, Gpu, OpSys, Weight, Price
HAVING cnt > 1;

-- Deleting duplicates
WITH cte AS (
    SELECT Company,
           TypeName,
           Inches,
           ScreenResolution,
           `Cpu`,
           Ram,
           `Memory`,
           Gpu,
           OpSys,
           Weight,
           Price,
           ROW_NUMBER() OVER (
               PARTITION BY Company, 
                            TypeName, 
                            Inches, 
                            ScreenResolution, 
                            `Cpu`, 
                            Ram, 
                            `Memory`, 
                            Gpu, 
                            OpSys, 
                            Weight, 
                            Price 
               ORDER BY (SELECT NULL)
           ) AS r1
    FROM laptop_backup
)
DELETE FROM laptop_backup
WHERE (Company, TypeName, Inches, ScreenResolution, `Cpu`, Ram, `Memory`, Gpu, OpSys, Weight, Price) IN (
    SELECT Company, TypeName, Inches, ScreenResolution, `Cpu`, Ram, `Memory`, Gpu, OpSys, Weight, Price
    FROM cte
    WHERE r1 > 1
);

SELECT COUNT(*) 
FROM laptop_backup;

-- Clean RAM 
SELECT * 
FROM laptop_backup;

UPDATE laptop_backup
SET Ram = REPLACE(Ram, 'GB', '');

ALTER TABLE laptop_backup
MODIFY COLUMN Ram INT;

-- Clean weight 
UPDATE laptop_backup
SET Weight = REPLACE(Weight, 'kg', '');

ALTER TABLE laptop_backup
MODIFY COLUMN Weight DECIMAL(10,1);

SELECT DISTINCT Weight AS x 
FROM laptop_backup
ORDER BY x;

DELETE FROM laptop_backup
WHERE Weight = '?';


-- clean price column 
select * 
from laptop_backup;

select floor(price)
from laptop_backup;

update laptop_backup
set price=floor(price);


ALTER TABLE laptop_backup
MODIFY COLUMN price int;

-- opsys cleaning 

select distinct opsys
from laptop_backup;

select opsys,substring_index(opsys,' ',1)
from laptop_backup;

update laptop_backup as l1 
set opsys= substring_index(opsys,' ',1) ;

update laptop_backup
set opsys = case when Opsys like 'Chrome%'  then 'Android' else opsys end ;


update laptop_backup
set opsys = case when Opsys like 'No'  then 'N/A' else opsys end ;

update laptop_backup
set opsys = case when Opsys like 'Mac' then 'macOS' else opsys end ;

-- GPU cleaning 
select *
from laptop_backup;

select gpu,substring_index(gpu,' ',1) as gpu_company_name 
from laptop_backup;

ALTER TABLE laptop_backup
MODIFY COLUMN gpu varchar(255);

ALTER TABLE laptop_backup
add column Gpu_brand_name varchar(50);

update laptop_backup
set Gpu_brand_name=substring_index(gpu,' ',1);

select gpu,substring_index(gpu,' ',4) as gpu_company_name 
from laptop_backup;
ALTER TABLE laptop_backup
add column Gpu_name varchar(50) after Gpu_brand_name;

select * 
from laptop_backup;


update laptop_backup
set Gpu_name=replace(Gpu,Gpu_brand_name,'');

select replace(Gpu,Gpu_brand_name,'')
from laptop_backup;

ALTER TABLE laptop_backup
drop column Gpu;


-- cpu 
select cpu,substring_index(cpu,' ',1),substring_index(cpu,' ',-1),replace(cpu,substring_index(cpu,' ',1),'')
from laptop_backup;

alter table laptop_backup
add column Cpu_Brand varchar(50) after cpu;
alter table laptop_backup
add column CPU_Model varchar(50) after Cpu_Brand;
alter table laptop_backup
add column Processing_speed varchar(50) after CPU_Model;


update laptop_backup
set Cpu_Brand=substring_index(cpu,' ',1);
update laptop_backup
set Cpu_Model=replace(cpu,substring_index(cpu,' ',1),'');
update laptop_backup
set Processing_speed=substring_index(cpu,' ',-1);

select * from laptop_backup;

update laptop_backup
set Processing_speed=trim(replace(Processing_speed,'GHz',''));

alter table laptop_backup
modify column Processing_speed decimal(10,2);

update laptop_backup
set CPU_Model=substring_index(replace(CPU_Model,'GHz',''),' ',3);


-- Memory

select distinct Memory from laptop_backup;

select memory , trim(replace(replace(replace(substring_index(Memory,' ' ,1),'GB',''),'TB',''),'?',''))
from laptop_backup;
alter table laptop_backup
add column memory_size int after memory;

UPDATE laptop_backup
SET memory_size=trim(replace(replace(replace(substring_index(Memory,' ' ,1),'GB',''),'TB',''),'?',0));

UPDATE laptop_backup
SET  memory_size= memory_size * 1000
WHERE memory_size = 1 or memory_size = 2 ;

delete from laptop_backup
where memory_size=0;

alter table laptop_backup
modify column memory_size int;



-- ScreenResolution

select * from laptop_backup;

alter table laptop_backup
add column ScreenResolution_Width  varchar(50) after ScreenResolution;
alter table laptop_backup
add column ScreenResolution_Length varchar(50) after ScreenResolution_Width;
alter table laptop_backup
add column Has_Touch_Screen varchar(50) after ScreenResolution_Length;

select ScreenResolution,substring_index(substring_index(ScreenResolution,' ',-1),'x',1),
substring_index(substring_index(ScreenResolution,' ',-1),'x',-1)
from laptop_backup;

update laptop_backup
set ScreenResolution_Width= substring_index(substring_index(ScreenResolution,' ',-1),'x',-1),
ScreenResolution_Length= substring_index(substring_index(ScreenResolution,' ',-1),'x',1);

ALTER TABLE laptop_backup
MODIFY COLUMN ScreenResolution_Length INT,
MODIFY COLUMN ScreenResolution_Width INT;

select ScreenResolution, case when ScreenResolution like '%Touchscreen%' then  1 else 0 end as touch_screen
from laptop_backup;
alter table laptop_backup
add column Has_Touch_Screen varchar(50) after ScreenResolution_Length;
update laptop_backup
set Has_Touch_Screen=case when ScreenResolution like '%Touchscreen%' then  1 else 0 end;


ALTER TABLE laptop_backup
add column   Has_IPS_Panel INT after Has_Touch_Screen ;
update laptop_backup
set Has_IPS_Panel=case when ScreenResolution like '%IPS Panel%' then  1 else 0 end;





alter table laptop_backup
drop column ScreenResolution;


select CPU_model,substring_index(trim(CPU_Model),' ',2)
from laptop_backup ;

update laptop_backup
set CPU_model=substring_index(trim(CPU_Model),' ',2);

select * 
from laptop_backup;

alter table laptop_backup
drop column Cpu;

-- memory 
select memory , 
case 
     when memory like '%SSD%' then 'SSD' 
     when memory like '%HDD%' then 'HDD' 
     when memory like '%Flash Storage%' then  'Flash Storage' 
     when memory like '%Hybrid%' then  'Hybrid'  
     end as a
from laptop_backup;

alter table laptop_backup
add column memory_type varchar(50) after memory;

update laptop_backup
set memory_type=case 
     when memory like '%SSD%' then 'SSD' 
     when memory like '%HDD%' then 'HDD' 
     when memory like '%Flash Storage%' then  'Flash Storage' 
     when memory like '%Hybrid%' then  'Hybrid' end ;
     
select  memory,substring_index(memory,'+',1),substring_index(substring_index(memory,'+',1),' ',1) as primary_memory
from laptop_backup;

alter table laptop_backup
drop column memory_size;

alter table laptop_backup
add column primary_memory int after memory_type;

update laptop_backup
set primary_memory=trim(replace(replace(substring_index(substring_index(memory,'+',1),' ',1),'GB',''),'TB',''));

update laptop_backup
set primary_memory=primary_memory*1024
where primary_memory=1 or primary_memory=2;

select memory_type
from laptop_backup
where Memory_type is null;

select primary_memory
from laptop_backup
where primary_memory is null;

select  memory, trim(case when memory like '%+%' then regexp_substr(substring_index(memory,'+',-1),'[0-9]+') else 0 end) as secondary_memory
from laptop_backup;

alter table laptop_backup
add column secondary_memory int after primary_memory ;


update laptop_backup
set secondary_memory=trim(case when memory like '%+%' then regexp_substr(substring_index(memory,'+',-1),'[0-9]+') else 0 end);


select distinct secondary_memory from laptop_backup;

update laptop_backup
set secondary_memory=secondary_memory*1024
where secondary_memory=1 or secondary_memory=2;

ALTER TABLE laptop_backup
MODIFY COLUMN weight decimal(5,1);

select count(distinct Gpu_name)
from laptop_backup;


UPDATE laptop_backup
SET Gpu_name = CASE
    WHEN Gpu_name LIKE '%hd 6%' THEN 'Intel HD 600 Series'
    WHEN Gpu_name LIKE '%hd 5%' THEN 'Intel HD 500 Series'
    WHEN Gpu_name LIKE '%iris%' THEN 'Intel Iris Series'
    WHEN Gpu_name LIKE '%uhd%' THEN 'Intel UHD Series'
    WHEN Gpu_name LIKE '%mx150%' THEN 'NVIDIA MX150'
    WHEN Gpu_name LIKE '%mx%' THEN 'NVIDIA MX Series'
    WHEN Gpu_name LIKE '%gtx 1050%' THEN 'NVIDIA GTX 1050 Series'
    WHEN Gpu_name LIKE '%gtx 1060%' THEN 'NVIDIA GTX 1060 Series'
    WHEN Gpu_name LIKE '%gtx 1070%' THEN 'NVIDIA GTX 1070 Series'
    WHEN Gpu_name LIKE '%940mx%' THEN 'NVIDIA 940MX'
    WHEN Gpu_name LIKE '%930mx%' THEN 'NVIDIA 930MX'
    WHEN Gpu_name LIKE '%920mx%' THEN 'NVIDIA 920MX'
    WHEN Gpu_name LIKE '%radeon pro%' THEN 'AMD Radeon Pro'
    WHEN Gpu_name LIKE '%radeon r5%' THEN 'AMD Radeon R5'
    WHEN Gpu_name LIKE '%r5 m%' THEN 'AMD Radeon R5 M Series'
    WHEN Gpu_name LIKE '%radeon rx%' THEN 'AMD Radeon RX Series'
    WHEN Gpu_name LIKE '%radeon 530%' THEN 'AMD Radeon 530'
    WHEN Gpu_name LIKE '%radeon 520%' THEN 'AMD Radeon 520'
    WHEN Gpu_name LIKE '%radeon%' THEN 'AMD Radeon Series'
    ELSE 'Other'
END;

SELECT Gpu_name, COUNT(*) 
FROM laptop_backup
GROUP BY Gpu_name
ORDER BY COUNT(*) DESC;

SELECT Gpu_brand_name,Gpu_name
FROM laptop_backup;
alter table laptop_backup
drop column Memory;


ALTER TABLE laptop_backup
MODIFY COLUMN Has_Touch_Screen INT;
select  *
from laptop_backup;

