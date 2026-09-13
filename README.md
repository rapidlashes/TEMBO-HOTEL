## PREREQUISITES
We assumed guest ratings were out of 10, and the highest rating given by a guest being 6.
The folder "RAW"  contains the raw `csv` file that needed cleaning before analysis. 
The folder "SQL scripts" contains `SQL` files where data is cleaned and analyzed.
The folder "VISUALIZATION" houses our project report and dashboard  done in power BI.

### CLEANING DATA
Data cleaning was done in the frist SQL script ,TEMBO(STAGING) where the `csv` table was loaded into a staging table having every column in `TEXT` format.

syntax:
```SQL
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
```

This is prior data transformation whre all columns will be converted into the correct data types and contstrains.

The next step in cleaning the data was standardization. 

Every column was handled individually.

Names of guests, cities, room types etc were put into proper cases, dates into proper formats as well as numerics.

Columns with numerical data were set to `NULL` where rows were missing data, while the ones with textual data set to `unknown` where rows were missing values.

Some columns were left blank where rows were missing values, eg the column `service_used`. This was necessary since not all the guests who booked used those services .They were just but extra services offered by the hotel.

Standardization necessary for consistency of data. 
We do not want to have an instance where there are duplicate guests having the same name but written in different cases.

### DATA TRANSFORMATION
Once data was cleaned, it was loaded into a production table which was created in a separate SQL script, TEMBO(PRODUCTION).

syntax:
```SQL
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
```

The Data loaded here will be transformed in to the correct data type and constrains before analysis.

### ANALYSIS OF DATA
After data is analysed , views will be created which are temporary tables in our SQL environment.

syntax:
```SQL
create or replace view v_completed_bookings as
select column_name
from table_name;
```
To see the content of your view, you can do this:
```SQL
select * from v_completed_bookngs;
```

The views will then be imported to power BI for visualisation and report.

<img width="1920" height="1080" alt="Screenshot (251)" src="https://github.com/user-attachments/assets/114eef28-3549-4143-bf38-ff948447c5e3" />

### VISUALIZATION AND REPORT
We used views to create visuals and a dashbaord in power BI . 
Slicers are added to make the dashboard more interactive .

<img width="1344" height="761" alt="Screenshot (250)" src="https://github.com/user-attachments/assets/0f93ca2d-939a-4a4a-bc7a-59ea743d8292" />

The final steps are generating insights and recommendations from our report.

<img width="1354" height="795" alt="Screenshot (248)" src="https://github.com/user-attachments/assets/cb7a1a3e-dba4-4b23-83ce-1be4d53a6172" />

<img width="1233" height="682" alt="Screenshot (246)" src="https://github.com/user-attachments/assets/5f98a05d-d6c3-4e8b-aab6-183fe3d4727b" />

## ER DIAGRAM
This is the Entity - Relation diagram in our report which is observed from the model view. 
It basically shows you how the tables are related to one another , and what they have in common.

<img width="827" height="702" alt="Screenshot (247)" src="https://github.com/user-attachments/assets/75dd97f5-8d0e-4cc9-8002-d703de52049f" />

### NOTE: For the dashboard to be interactive you have to establish relationships between the views you had imported.


