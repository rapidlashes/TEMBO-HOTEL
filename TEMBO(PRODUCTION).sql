
create table if not exists tembo.tembo_productions(
booking_id          VARCHAR(10) primary key,
guest_name          VARCHAR(50),
guest_phone         VARCHAR(50),
guest_city          VARCHAR(50),
guest_nationality   VARCHAR(50),
room_no             VARCHAR(50),
room_type           VARCHAR(50),
room_rate_per_night numeric(12,2),
check_in_date       DATE,
check_out_date      DATE,
nights_stayed       numeric(12,2),
staff_name          VARCHAR(50),
staff_department    VARCHAR(50),
staff_salary        numeric(12,2),
payment_method      VARCHAR(50),
booking_status      VARCHAR(50),
total_amount        numeric(12,2),
service_used        VARCHAR(50),
service_price       numeric(12,2),
guest_rating        INTEGER
);

select * from tembo.tembo_productions;

insert into tembo.tembo_productions(
booking_id,
guest_name,
guest_phone,
guest_city,
guest_nationality,
room_no,
room_type,
room_rate_per_night,
check_in_date,
check_out_date,
nights_stayed,
staff_name,
staff_department,
staff_salary,
payment_method,
booking_status,
total_amount,
service_used,
service_price,
guest_rating
)
select
booking_id,
TRIM(guest_name),
nullif(TRIM(guest_phone),''),
coalesce(nullif(TRIM(guest_city),''),'unknown'),
guest_nationality,
room_no::integer,
room_type,
room_rate_per_night::numeric,
check_in_date::DATE,
check_out_date::DATE,
nights_stayed::numeric,
staff_name,
staff_department,
nullif(regexp_replace(staff_salary,'[^0-9.]','','g'),'')::numeric,
payment_method,
booking_status,
nullif(regexp_replace(total_amount,'[^0-9.]','','g'),'')::numeric,
nullif(service_used,''),
nullif(service_price,'')::numeric,
nullif(guest_rating,'')::integer
from tembo.tembo_staging ts
where check_out_date similar to '[0-9]{4}-[0-9]{2}-[0-9]{2}' and check_in_date similar to '[0-9]{4}-[0-9]{2}-[0-9]{2}';
