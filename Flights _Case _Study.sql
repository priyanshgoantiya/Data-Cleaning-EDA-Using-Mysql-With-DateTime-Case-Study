use laptop;
-- Flights Case Study
-- 1. Find the month with most number of flights

select monthname(Date_of_Journey) as month_name,count(*) as no_of_flight
from `flights - flights`
group by month_name
order by no_of_flight desc;

-- 2. Which week day has most costly flights.

select dayname(Date_of_Journey) as flight_day,avg(price) as most_exp
from `flights - flights`
group by  flight_day
order by  most_exp desc
limit 1;

-- 3. Find number of indigo flights every month.
select monthname(Date_of_Journey) as flight_month,count(*) as cnt
from `flights - flights`
where Airline like '%indigo%' 
group by flight_month;
-- Find list of all flights that depart between 10AM and 2PM from Delhi to
-- Banglore.
alter table `flights - flights`
modify column dep_time time;
select *
from `flights - flights`
where (hour(Dep_Time) between 10 and 14) and (Source ='Banglore') and (destination in ('Delhi','New Delhi'));
-- 5. Find the number of flights departing on weekends from Bangalore.
select count(*)
from `flights - flights`
where dayname(Date_of_Journey) in ('Saturday','Sunday') and Source='Banglore';

select dayname(dep_time) 
from `flights - flights`;
-- Calculate the arrival time for all flights by adding the duration to the departure
-- time.
select str_to_date(concat(Date_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i:%s')
from `flights - flights`;

alter table `flights - flights`
add column departure datetime;

update `flights - flights`
set departure= str_to_date(concat(Date_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i:%s');

select *
from `flights - flights`;
alter table `flights - flights`
add column duration_mins int;
UPDATE `flights - flights`
SET duration_mins =
    CASE
        -- When both hours and minutes are present
        WHEN Duration LIKE '%h%' AND Duration LIKE '%m%' THEN
            TRIM(REPLACE(SUBSTRING_INDEX(Duration, ' ', 1), 'h', '')) * 60 +
            TRIM(REPLACE(SUBSTRING_INDEX(Duration, ' ', -1), 'm', ''))

        -- When only hours are present
        WHEN Duration LIKE '%h%' THEN
            TRIM(REPLACE(Duration, 'h', '')) * 60

        -- When only minutes are present
        WHEN Duration LIKE '%m%' THEN
            TRIM(REPLACE(Duration, 'm', ''))

        ELSE NULL
    END;

select trim(replace(substring_index(Duration,' ',1),'h',''))*60+(case when 
trim(replace(substring_index(Duration,' ',-1),'m',''))=trim(replace(substring_index(Duration,' ',1),'m','')) then 0 else 
trim(replace(substring_index(Duration,' ',-1),'m','')) end ) as dep_time
from `flights - flights`;

alter table `flights - flights`
add column Arrival datetime;



select duration_mins,departure,date_add(departure ,interval duration_mins Minute )
from `flights - flights`;

update `flights - flights`
set Arrival=date_add(departure ,interval duration_mins Minute );

-- find number of flights which travel on multiple dates.
alter table `flights - flights`
modify column Date_of_Journey Datetime;
select count(*) as cnt
from `flights - flights`
where date(departure)!=date(Arrival);
-- Calculate the average duration of flights between all city pairs. The answer
-- should In xh ym format
select source,destination,time_format(sec_to_time(avg(duration_mins)*60),'%kh %im') as avg_duration
from `flights - flights`
group by source,destination
order by avg_duration;
-- Find all flights which departed before midnight but arrived at their destination
-- after midnight having only 0 stops.
select *
from `flights - flights`
where Hour(departure) > Hour(Arrival) and Total_Stops='non-stop';
-- 11. Find quarter wise number of flights for each airline
select airline,quarter(Date_of_Journey),count(*)
from `flights - flights`
group by airline,quarter(Date_of_Journey)
order by airline;
-- 12. Find the longest flight distance(between cities in terms of time) in India
select * from 
`flights - flights` 
where duration_mins=(select max(duration_mins)
from `flights - flights`);
-- 13. Average time duration for flights that have 1 stop vs more than 1 stops


with x as (select *,case when Total_Stops='1 stop'   then '1 stop'
 when Total_Stops in ('2 stops','3 stops','4 stops') then 'more then one stop'  else 'non stop' end as 'temp'
from `flights - flights`)
select temp,avg(duration_mins)
from x
group by temp;

select distinct Total_Stops
from `flights - flights`
;
-- 14. Find all Air India flights in a given date range originating from Delhi
select *
from `flights - flights`
where airline='Air India' and Source in ('Delhi','New Delhi') and dayofmonth(Date_of_Journey) between 15 and 21 
and month(Date_of_Journey)=3;
-- 15. Find the longest flight of each airline
select airline ,max(duration_mins)
from `flights - flights`
group by airline;
-- 16. Find all the pair of cities having average time duration > 3 hours
select source,destination,avg(duration_mins) as avg_
from `flights - flights`
group by source,destination
having avg_>180;
-- Make a weekday vs time grid showing frequency of flights from Banglore and
-- Delhi
SELECT DAYNAME(departure),
SUM(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS '12AM - 6AM',
SUM(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS '6AM - 12PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS '12PM - 6PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS '6PM - 12PM'
FROM `flights - flights`
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure);

-- 18. Make a weekday vs time grid showing avg flight price from Banglore and Delhi
SELECT DAYNAME(departure),
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price ELSE NULL END) AS '12AM - 6AM',
AVG(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS '6AM - 12PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS '12PM - 6PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS '6PM - 12PM'
FROM flights
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure)
