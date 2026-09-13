drop table tembo.tembo_staging ;
set search_path to tembo;
create table tembo.tembo_staging(
booking_id text,
guest_name text,
guest_phone text,
guest_city text,
guest_nationality text,
room_no text,
room_type text,
room_rate_per_night text,
check_in_date text,
check_out_date text,
nights_stayed text,
staff_name text,
staff_department text,
staff_salary text,
payment_method text,
booking_status text,
total_amount text,
service_used text,
service_price text,
guest_rating text
);

select * from tembo.tembo_staging ts ;
select count (*) from tembo.tembo_staging ts ;


--checking for duplicate booking_ids
select booking_id, count(*) as grouping
from tembo.tembo_staging ts
group by booking_id 
having count(*) > 1
order by booking_id ; 









--1.cleaning guest_name
select distinct guest_name
from tembo.tembo_staging ts ;

select initcap(trim(guest_name))
from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set guest_name = initcap(trim(guest_name))
where ts.guest_name != initcap(trim(guest_name));












--2.cleaning guest_phone
select distinct guest_phone  from tembo.tembo_staging ;


select guest_phone
from tembo.tembo_staging ts 
where guest_phone like '+254%' or ts.guest_phone like '%-%';


update tembo.tembo_staging ts 
set guest_phone = regexp_replace(guest_phone, '[^0-9]','','g')
where guest_phone like '%-%';

update tembo.tembo_staging ts 
set guest_phone = 0 || substring(guest_phone,5)
where  ts.guest_phone  like '+254%';

update tembo.tembo_staging ts 
set guest_Phone = trim(ts.guest_phone )
where ts.guest_phone != trim(ts.guest_phone );















--3.cleaning guest_city
select distinct guest_city from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set guest_city = initcap(trim(guest_city))
where guest_city != initcap(trim(guest_city));

update tembo.tembo_staging ts 
set guest_city = 'Thika'
where ts.guest_city = 'Thikax';












--4.cleaning guest_nationality
select distinct guest_nationality from tembo.tembo_staging ts ;


update tembo.tembo_staging ts 
set guest_nationality  = 'Kenyan'
where ts.guest_nationality  != 'Kenyan';















--5.cleaning room_type
select distinct room_type from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set room_type = initcap(trim(room_type))
where ts.room_type  != initcap(trim(room_type));

update tembo.tembo_staging ts 
set room_type = 'Deluxe'
where room_type = 'Dlx';

update tembo.tembo_staging ts 
set room_type = 'Standard'
where room_type = 'Std';











--6.cleaning check in date
select distinct check_in_date from tembo.tembo_staging ts ;

select check_in_date  
from tembo.tembo_staging ts 
where check_in_date not similar to '[0-9]{4}-[0-9]{2}-[0-9]{2}';

update tembo.tembo_staging ts 
set check_in_date = to_date(ts.check_in_date ,'DD/MM/YYYY')::text
where ts.check_in_date  like '%/%';

update tembo.tembo_staging ts 
set check_in_date = to_date(ts.check_in_date ,'DD-MM-YY')::TEXT
where length(ts.check_in_date ) = 8 and ts.check_in_date like '%-%';

update tembo.tembo_staging ts 
set check_in_date  = to_date(ts.check_in_date ,'MM-DD-YYYY')::TEXT
where length(ts.check_in_date ) = 10 and check_in_date like '%-%' and split_part(check_in_date,'-',2)::integer > 12;














--7.cleaning check_out_date
select distinct check_out_date from tembo_staging ts;


update tembo.tembo_staging ts 
set check_out_date = to_date(ts.check_out_date ,'DD/MM/YYYY')
where ts.check_out_date like '%/%';

update tembo.tembo_staging ts 
set check_out_date = to_date(ts.check_out_date ,'DD-MM-YY')
where ts.check_out_date  like '%-%' and length(ts.check_out_date ) = 8;

update tembo.tembo_staging ts 
set check_out_date  = to_date(ts.check_out_date ,'MM-DD-YYYY')
where ts.check_out_date like '%-%' and length(ts.check_out_date ) = 10 and split_part(ts.check_out_date ,'-',2)::integer > 12;












select * from tembo.tembo_staging ts ;













--8cleaning nights stayed
select distinct nights_stayed from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set nights_stayed = regexp_replace(ts.nights_stayed ,'[^0-9]','','g')
where ts.nights_stayed = '-3';











--9.cleaning staff name
select distinct staff_name from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set staff_name = initcap(trim(staff_name))
where ts.staff_name != initcap(trim(staff_name));












--10.cleaning staff salary
select distinct ts.staff_salary  from tembo.tembo_staging ts ;

select staff_salary,
regexp_replace(staff_salary,'[^0-9.]','','g') as cleaned
from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set staff_salary = regexp_replace(staff_salary,'[^0-9.]','','g')
where staff_salary like '%KES%';












--11.cleaning payment method
select distinct payment_method from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set payment_method = 'M-Pesa'
where ts.payment_method = 'mpesa';










--12.cleaning booking_status
select distinct booking_status from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set booking_status = 'Checked Out'
where booking_status = 'checked out';












--13.cleaning totla_amount
select distinct total_amount from tembo.tembo_staging ts ;


select total_amount, regexp_replace(total_amount,'[^0-9.]','','g') as cleaned
from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set total_amount = regexp_replace(total_amount,'[^0-9.]','','g')
where total_amount = ',' or ts.total_amount like 'KES%';

update tembo.tembo_staging ts 
set total_amount = regexp_replace(total_amount,'[^0-9.]','','g')
where total_amount like '%,%';












--14.cleaning service_used
select distinct guest_rating from tembo.tembo_staging ts ;

update tembo.tembo_staging ts 
set guest_rating = trim(ts.guest_rating )
where ts.guest_rating != trim(ts.guest_rating );

select count(booking_id),guest_rating
from tembo.tembo_staging ts 
group by guest_rating;










--removing duplicates
select  min(ctid)
from tembo.tembo_staging ts
group by booking_id;


delete from tembo.tembo_staging 
where ctid not in (select  min(ctid)
from tembo.tembo_staging ts
group by booking_id );







--changing dates to 'YYYY-MM-DD' format
update tembo.tembo_staging
set check_in_date = TO_DATE(check_in_date, 'DD-MM-YYYY')::TEXT
WHERE
check_in_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';
 
update tembo.tembo_staging ts 
set check_out_date = TO_DATE(check_out_date, 'DD-MM-YYYY')::TEXT
WHERE
check_out_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';

