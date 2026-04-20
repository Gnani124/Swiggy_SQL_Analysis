--Change DataBase
use SwiggyDB
go

--Bussiness Analysis Metrics

--KPI's 

--Total Orders
select count(*) as Total_Orders
from fact_swiggy_orders;

--Total Revenue (INR Million)
select FORMAT(sum(convert(float,price_INR))/1000000, 'N2') + ' INR Million'
as Total_Revenue
from fact_swiggy_orders

--Average Dish Price 
select 
format(avg(convert(float, price_INR)), 'N2') + 'INR'
as Total_Revenue
from fact_swiggy_orders

--Average Rating
select 
	avg(rating) as Avg_Rating
from 
	fact_swiggy_orders




--Deep Bussiness Analysis

--Monthly Order Trends
select 
	d.year,
	d.month,
	d.month_name,
	count(*) as Total_Orders
from 
	fact_swiggy_orders f
join
	dim_date d on f.date_id = d.date_id
group by 
	d.year,
	d.month,
	d.month_name
order by 
	d.year,
	d.month;


--Monthly Total Revenue
select 
	d.year,
	d.month,
	d.month_name,
	SUM(price_INR) as Total_Revenue
from 
	fact_swiggy_orders f
join
	dim_date d on f.date_id = d.date_id 
group by
	d.year,
	d.month,
	d.month_name
order by 
	SUM(price_INR) desc;


--Quaterly Trend
select
	d.year,
	d.quarter,
	COUNT(*) as Total_Orders
from 
	fact_swiggy_orders f
join 
	dim_date d on f.date_id = d.date_id
group by 
	d.year,
	d.quarter
order by
	count(*) desc;

--Yearly Trend
select
	d.year,
	COUNT(*) as Total_Orders
from 
	fact_swiggy_orders f
join 
	dim_date d on f.date_id = d.date_id
group by 
	d.year
order by
	count(*) desc;

--Orders On Day Of Week (Mon - Sun)
select 
	DATENAME(weekday, d.full_date) as Day_Name,
	count(*) as Total_Orders
from 
	fact_swiggy_orders f
join 
	dim_date d on f.date_id = d.date_id
group by 
	DATENAME(weekday, d.full_date), DATEPART(weekday, d.full_date)
order by 
	DATEPART(weekday, d.full_date);

--Top 10 Cities by Order Volume
select
	top 10
	l.city,
	count(*) as Total_Orders
from
	fact_swiggy_orders f
join 
	dim_Location l
on f.Location_id = l.Location_id
group by 
	l.City
order by 
	count(*) desc;

select
	top 10
	l.city,
	count(*) as Total_Orders
from
	fact_swiggy_orders f
join 
	dim_Location l
on f.Location_id = l.Location_id
group by 
	l.City
order by 
	SUM(f.price_INR) desc;

--Revenue Contribution By Status
select
	l.State,
	count(*) as Total_Orders
from
	fact_swiggy_orders f
join 
	dim_Location l
on f.Location_id = l.Location_id
group by 
	l.State
order by 
	SUM(f.price_INR) desc;

--Top 10 restaurants by Orders
select 
	r.restaurant_Name,
	SUM(f.price_INR) as Total_Revenue
from
	fact_swiggy_orders f
join dim_Restaurant r
	on r.restaurant_id = f.restaurant_id
group by 
	r.Restaurant_Name
order by 
	SUM(f.price_INR) desc;

--Top Categories By Order Volume
select 
	Top 10
	c.category,
	count(*) total_orders
from 
	fact_swiggy_orders f
join dim_Category c
	on f.category_id = c.category_id
group by 
	c.Category
order by
	total_orders desc;

--Most ordered Dish's
select 
	Top 10
	d.dish_Name,
	count(*) as Orders_Count
from
	fact_swiggy_orders f
join Dim_Dish d
	on f.dish_id = d.Dish_id
group by 
	d.Dish_Name
order by
	Orders_Count desc;


--Cuisine Performance (Orders + Avg Rating)
--Orders
select
	c.category,
	COUNT(*) as total_orders,
	AVG(f.rating) as avg_rating
from
	fact_swiggy_orders f
join dim_Category c 
	on f.category_id = c.category_id
group by 
	c.Category
order by 
	total_orders desc;

--Avg Rating
select
	c.category,
	COUNT(*) as total_orders,
	AVG(f.rating) as avg_rating
from
	fact_swiggy_orders f
join dim_Category c 
	on f.category_id = c.category_id
group by 
	c.Category
order by 
	avg_rating desc;

select
	Top 10
	c.category,
	COUNT(*) as total_orders,
	AVG(f.rating) as avg_rating
from
	fact_swiggy_orders f
join dim_Category c 
	on f.category_id = c.category_id
group by 
	c.Category
order by 
	total_orders desc;


--Total Orders By Price Range
select
	case
		when CONVERT(float, price_INR) < 100 then 'Under 100'
		when CONVERT(float, price_INR) between 100 and 199 then '100-199'
		when convert(float, price_INR) between 200 and 299 then '200-299'
		when CONVERT(float, price_INR) between 300 and 499 then '300-499'
		else '500+'
	end as price_range,
	COUNT(*) as total_orders
from 
	fact_swiggy_orders f
group by 
	case
		when CONVERT(float, price_INR) < 100 then 'Under 100'
		when CONVERT(float, price_INR) between 100 and 199 then '100-199'
		when convert(float, price_INR) between 200 and 299 then '200-299'
		when CONVERT(float, price_INR) between 300 and 499 then '300-499'
		else '500+'
	end
order by total_orders desc;
