--Change DB
use SwiggyDB
go

--See Complete Data
select * from swiggy_data;

--Data Validation & Cleaning
--Null Check
select 
	SUM(case when State is null then 1 else 0 end) as null_state,
	SUM(case when City is null then 1 else 0 end) as null_city,
	SUM(case when Order_Date is null then 1 else 0 end) as null_Order_Date,
	SUM(case when Restaurant_Name is null then 1 else 0 end) as null_Restaurant,
	SUM(case when Location is null then 1 else 0 end) as null_location,
	SUM(case when Category is null then 1 else 0 end) as null_Category,
	sum(case when Dish_Name is null then 1 else 0 end) as null_Dish,
	SUM(case when Price_INR is null then 1 else 0 end) as null_PRice,
	SUM(case when Rating is null then 1 else 0 end) as null_rating,
	SUM(case when Rating_Count is null then 1 else 0 end) as null_rating_count
from 
	swiggy_data;

--Blank Or Empty Strings
select * 
from swiggy_data
where 
	State ='' OR City='' OR Restaurant_Name = '' OR Location='' OR Dish_Name=''
	OR Price_INR='' OR Rating='' OR Rating_Count='';

--Duplicate Detection
select 
	State, City, Order_Date, Restaurant_Name, Location, Category,
	Dish_Name, Price_INR, Rating, Rating_Count, count(*) as cnt
from 
	swiggy_data
group by
	State, City, Order_Date, Restaurant_Name, Location, Category,
	Dish_Name, Price_INR, Rating, Rating_Count
having count(*)>1;

--Delete Duplications
With CTE as (
select *, ROW_NUMBER() over(partition  by State, City, Order_Date, Restaurant_Name, Location, Category,
	Dish_Name, Price_INR, Rating, Rating_Count
order by ( select null) 
)as rn 
from swiggy_data
) 
delete from CTE where rn > 1;

--Creating Schema
--Dimension's
--Date Table
create table dim_date(
	date_id int IDENTITY(1,1) primary key,
	Full_date date,
	year int,
	month int,
	month_name varchar(20),
	quarter int,
	Day int
);

--Adding Week into Dim_Date
alter table dim_date
add week int;


--Dim_Location
create table dim_Location(
	Location_id int identity(1,1) primary key,
	State Varchar(100),
	City Varchar(100),
	Location Varchar(200)
);

--Dim_Restaurant
create table dim_Restaurant(
	restaurant_id int identity(1,1) primary key,
	Restaurant_Name varchar(200)
);

--Dim_Category
create table dim_Category(
	category_id int identity(1,1) primary key,
	Category varchar(200)
);

--Dim_Dish
create table Dim_Dish(
	Dish_id int identity(1,1) primary key,
	Dish_Name varchar(200)
);

--Creating Fact Table
Create Table fact_swiggy_orders(
	order_id int identity(1,1) primary key,
	date_id int,
	price_INR decimal(10,2),
	Rating decimal(4,2),
	Rating_Count int,

	Location_id int,
	restaurant_id int,
	category_id int,
	dish_id int,

	foreign key (date_id) references dim_date(date_id),
	foreign key (location_id) references dim_location(location_id),
	foreign key (restaurant_id) references dim_restaurant(restaurant_id),
	foreign key (category_id) references dim_category(category_id),
	foreign key (dish_id) references dim_dish(dish_id)
);

select * from dim_date;
select * from dim_Location;
select * from dim_Category;
select * from dim_Restaurant;
select * from Dim_Dish;
select * from fact_swiggy_orders;


--Insert Data Into Tables

--Dim_Date Table
insert into dim_date (Full_date, year, month, month_name, quarter, Day, Week)
select distinct 
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATENAME(month, Order_Date),
	DATEPART(quarter, Order_Date),
	DAY(Order_Date),
	DATEPART(week, Order_Date)
from 
	swiggy_data
where 
	Order_Date is not null;

--see data 
select * from dim_date;

--insert Data Into Dim_Location
--Dim_Location
insert into dim_Location (State, City, Location)
select Distinct 
	State,
	City,
	Location
from swiggy_data;

--See Data
select * from dim_Location

--insert Data Into Dim_Restaurant
--Dim_Restaurant
insert into dim_Restaurant(Restaurant_Name)
select distinct
	Restaurant_Name
from 
	swiggy_data;

-- See Data 
select * from dim_Restaurant;

--insert Data Into Dim_Category
--Dim_Category
insert into dim_Category(Category)
select distinct
	Category
from
	swiggy_data;

--See Data
select * from dim_Category;

--insert Data Into Dim_Dish
--Dim_Dish
insert into Dim_Dish(Dish_Name)
select distinct
	Dish_Name
from
	swiggy_data;

--See Data
select * from Dim_Dish;

----insert Data Into fact_swiggy_orders
--Fact_Table
insert into fact_swiggy_orders
(
	date_id,
	price_INR,
	Rating,
	Rating_Count,
	Location_id,
	restaurant_id,
	category_id,
	dish_id
)

select 
	dd.date_id,
	s.Price_INR,
	s.Rating,
	s.Rating_Count,

	dl.location_id,
	dr.restaurant_id,
	dc.category_id,
	dsh.dish_id
from 
	swiggy_data s

join dim_date dd
	on dd.Full_date = s.Order_Date

join dim_Location dl
	on dl.State = s.State
	and dl.City = s.City
	and dl.Location = s.Location

join dim_Restaurant dr
	on dr.Restaurant_Name = s.Restaurant_Name

join dim_Category dc
	on dc.Category = s.Category

join Dim_Dish dsh
	on dsh.Dish_Name = s.Dish_Name


--see Data on Fact_table
select * from fact_swiggy_orders

--see all data by using Joins
select * from fact_swiggy_orders f
join dim_date d on f.date_id = d.date_id
join dim_Location l on f.Location_id = l.Location_id
join dim_Restaurant r on f.restaurant_id = r.restaurant_id
join dim_Category c on f.category_id = c.category_id
join Dim_Dish di on f.dish_id = di.Dish_id;
	