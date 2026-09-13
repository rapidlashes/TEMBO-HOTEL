set search_path to tembo;
create or replace view v_completed_bookings as
select *,
to_char(check_out_date, 'Month YYYY') as month_label
from tembo.tembo_productions
where booking_status = 'Checked Out';

select * from v_completed_bookings;









--ANALYSIS--
--1.1.	Revenue analysis: Total revenue by month, by room type, by payment method
with total_revenue as(
select
room_type,
payment_method,
month_label,
sum(total_amount) as monthly_revenue
from v_completed_bookings
group by month_label, room_type, payment_method
order by TO_DATE(month_label, 'Month YYYY')
)
select
room_type,
Payment_method,
month_label,
monthly_revenue,
sum(monthly_revenue) over (partition by month_label) as total_month_revenue
from total_revenue
order by TO_DATE(month_label, 'Month YYYY');



create or replace view v_revenue_analysis as
with total_revenue as(
select
room_type,
payment_method,
month_label,
sum(total_amount) as monthly_revenue
from v_completed_bookings
group by month_label, room_type, payment_method
order by TO_DATE(month_label, 'Month YYYY')
)
select
room_type,
Payment_method,
month_label,
monthly_revenue,
sum(monthly_revenue) over (partition by month_label) as total_month_revenue
from total_revenue
order by TO_DATE(month_label, 'Month YYYY');

select * from v_revenue_analysis;


















--2.Occupancy: Which room types are booked most? Average nights stayed per room type
select room_type, count(booking_id) as bookings, ceiling(avg(nights_stayed)) as average_nights
from v_completed_bookings
group by room_type 
order by bookings desc;




create or replace view v_occupancy as 
select room_type, count(booking_id) as bookings, ceiling(avg(nights_stayed)) as average_nights
from v_completed_bookings
group by room_type 
order by bookings desc;

select * from v_occupancy;


















--3.3.	Guest insights: Top 10 cities guests come from. Average rating per room type
select guest_city,count(booking_id) as total,room_type, avg(guest_rating) 
from v_completed_bookings
group by room_type, guest_city;


with cte_name1 as (
select guest_city,count(booking_id) as total,room_type, avg(guest_rating) as avg_guest_ratings
from v_completed_bookings
group by room_type, guest_city
),
cte_name2 as (
select guest_city,room_type, total, 
sum(total) over (partition by guest_city) as total_bookings_per_city ,ceiling(avg_guest_ratings) as average_guest_rating
from cte_name1 
order by total_bookings_per_city desc
)
select guest_city,room_type,total_bookings_per_city,average_guest_rating,
dense_rank() over (order by total_bookings_per_city desc, guest_city ) as city_rank
from cte_name2 ;



create or replace view v_guest_insights as
with cte_name1 as (
select guest_city,count(booking_id) as total,room_type, avg(guest_rating) as avg_guest_ratings
from v_completed_bookings
group by room_type, guest_city
),
cte_name2 as (
select guest_city,room_type, total, 
sum(total) over (partition by guest_city) as total_bookings_per_city ,ceiling(avg_guest_ratings) as average_guest_rating
from cte_name1 
order by total_bookings_per_city desc
)
select guest_city,room_type,total_bookings_per_city,average_guest_rating,
dense_rank() over (order by total_bookings_per_city desc, guest_city ) as city_rank
from cte_name2;

select * from v_guest_insights;


















--4.4.	Staff performance: Which staff handled the most bookings? Which department generates most revenue?
select staff_name, staff_department,count(booking_id) as bookings,sum(total_amount) as revenue
from v_completed_bookings
group by staff_name ,staff_department ;

with cte_name1 as (
select staff_name, staff_department,count(booking_id) as bookings,sum(total_amount) as revenue
from v_completed_bookings
group by staff_name ,staff_department
),
cte_name2 as (
select staff_name, staff_department,bookings,revenue,sum(revenue) over (partition by staff_department )as department_revenue
from cte_name1
)
select staff_name ,staff_department, bookings, dense_rank() over (order by bookings desc) as employee_rank, revenue, department_revenue 
 from cte_name2 
order by department_revenue desc;



create or replace view v_staff_performance as
with cte_name1 as (
select staff_name, staff_department,count(booking_id) as bookings,sum(total_amount) as revenue
from v_completed_bookings
group by staff_name ,staff_department
),
cte_name2 as (
select staff_name, staff_department,bookings,revenue,sum(revenue) over (partition by staff_department )as department_revenue
from cte_name1
)
select staff_name ,staff_department, bookings, dense_rank() over (order by bookings desc) as employee_rank, revenue, department_revenue 
 from cte_name2 
order by department_revenue desc;

select * from v_staff_performance;















--6.	Cancellations: Cancellation rate per room type. Revenue lost from cancellations and no-shows
select room_type, sum(total_amount) as lost_revenue
from tembo.tembo_productions 
where booking_status in ('No Show','Cancelled')
group by room_type
order by lost_revenue desc;

with cte_name as (
select room_type,guest_city, sum(total_amount) as lost_revenue, count(booking_id) as invalid_bookings
from tembo.tembo_productions 
where booking_status in ('No Show','Cancelled')
group by room_type, guest_city 
order by lost_revenue desc
)
select room_type, guest_city ,lost_revenue,invalid_bookings , sum(lost_revenue) over() as total_lost_revenue
from cte_name 
where guest_city = 'Nairobi';


create or replace view v_cancellations as 
with cte_name as (
select room_type, sum(total_amount) as lost_revenue, count(booking_id) as invalid_bookings
from tembo.tembo_productions 
where booking_status in ('No Show','Cancelled')
group by room_type
order by lost_revenue desc
)
select room_type, lost_revenue,invalid_bookings , sum(lost_revenue) over() as total_lost_revenue
from cte_name ;

select * from v_cancellations;




















--.5.	Trends: Revenue growth month over month (window function). Busiest vs quietest months
select month_label, sum(total_amount) as monthly_revenue
from v_completed_bookings
group by month_label 
order by to_date(month_label, 'Month YYYY') ;

with cte_name1 as (
select month_label, sum(total_amount) as monthly_revenue, count(booking_id) as total_bookings
from v_completed_bookings
group by month_label 
order by to_date(month_label, 'Month YYYY') 
),
cte_name2 as (
select month_label, total_bookings , monthly_revenue, lag(monthly_revenue,1,0) over (order by to_date(month_label, 'Month YYYY')) as previous_revenue
from cte_name1
)
select *, round( ((monthly_revenue - previous_revenue )/monthly_revenue )* 100,2) as percentage_change, rank() over (order by total_bookings desc) as bookings_rank
from cte_name2 
order by to_date(month_label, 'Month YYYY');

create or replace view v_trends as
with cte_name1 as (
select month_label, sum(total_amount) as monthly_revenue, count(booking_id) as total_bookings
from v_completed_bookings
group by month_label 
order by to_date(month_label, 'Month YYYY') 
),
cte_name2 as (
select month_label, total_bookings , monthly_revenue, lag(monthly_revenue,1,0) over (order by to_date(month_label, 'Month YYYY')) as previous_revenue
from cte_name1
)
select *, round( ((monthly_revenue - previous_revenue )/monthly_revenue )* 100,2) as percentage_change, rank() over (order by total_bookings desc) as bookings_rank
from cte_name2 
order by to_date(month_label, 'Month YYYY');

select * from v_trends;




















