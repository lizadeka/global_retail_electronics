-- What does the data tell us about Maven Electronics' declining revenue?"

-- Overall Sales Performance

-- Total Revenue
-- Total Units Sold
-- Total Orders
-- Total Customers
-- Total Products Sold
-- Average Order Value

select 
round(sum(p.unit_price_usd * f.quantity),2) as total_revenue,
sum(f.quantity) as total_units_sold,
count(distinct f.order_number) as total_orders_sold,
count(distinct f.customer_key) as total_customers,
count(distinct f.product_key) as total_products_sold,
round(sum(p.unit_price_usd * f.quantity) / count(distinct f.order_number),2) as average_order_value
from warehouse.fact_sales f
join warehouse.dim_products p on p.product_key = f.product_key;


-- How has revenue changed over time?

select 
extract(year from f.order_date)::integer as sales_year,
sum(p.unit_price_usd * f.quantity) as total_revenue,
sum(f.quantity) as total_units_sold,
count(distinct f.order_number) as total_orders
from warehouse.fact_sales f
join warehouse.dim_products p on p.product_key = f.product_key
group by extract(year from f.order_date)
order by sales_year;

-- whether the decline was concentrated in Online or physical stores

select
case
when s.country = 'Online' then 'Online'
else 'Physical'
end as channel,
extract(year from f.order_date)::integer as sales_year,
sum(p.unit_price_usd * f.quantity) as total_revenue,
sum(f.quantity) as total_units_sold,
count(distinct f.order_number) as total_orders
from warehouse.fact_sales f
join warehouse.dim_products p on p.product_key = f.product_key
join warehouse.dim_store s on s.store_key = f.store_key
group by
case
when s.country = 'Online' then 'Online'
else 'Physical'
end,
extract(year from f.order_date)
order by sales_year;

-- The 2020 revenue decline was broad-based, 
-- affecting both Online and Physical sales, with physical sales experiencing the slightly larger percentage decline.

-- compare 2019 vs 2020 revenue by country

select
s.country,
round(sum(
case
when extract(year from f.order_date) = 2019
then p.unit_price_usd * f.quantity
else 0
end),2) as revenue_2019,
round(sum(
case
when extract(year from f.order_date) = 2020
then p.unit_price_usd * f.quantity
else 0
end),2) as revenue_2020
from warehouse.fact_sales f
join warehouse.dim_products p on p.product_key = f.product_key
join warehouse.dim_store s on s.store_key = f.store_key
where extract(year from order_date) in (2019,2020)
group by s.country
;

-- The decline was widespread.
-- Every country experienced a decline in revenue between 2019 and 2020. 
-- So this doesn't look like a problem isolated to one market.

-- The United States is the biggest contributor to the overall decline.
-- The US lost approximately:
-- $3.69 million in revenue
-- between 2019 and 2020.
-- That's much larger than the decline in any other individual country.
-- Germany had the largest percentage decline among the physical markets
-- at approximately 59%, but because the US is much larger, the US contributed the most to the overall dollar decline.

-- Is the decline coming from fewer orders or lower order value?

select 
extract(year from f.order_date)::integer as sales_year,
round(sum(p.unit_price_usd * f.quantity),2) as total_revenue,
count(distinct f.order_number) as total_orders_sold,
round(sum(p.unit_price_usd * f.quantity) / count(distinct f.order_number),2) as average_order_value
from warehouse.fact_sales f
join warehouse.dim_products p on p.product_key = f.product_key
group by extract(year from f.order_date);

-- Between 2019 and 2020:
-- Revenue fell 49.1%
-- Orders fell 49.0%
-- Average Order Value fell only 0.3%

-- So the revenue decline was primarily 
-- driven by a sharp reduction in the number of orders, rather than customers spending substantially less per order.

-- revenue and order by product category

select 
p.category,
extract(year from f.order_date)::integer as sales_year,
round(sum(p.unit_price_usd * f.quantity),2) as total_revenue,
count(distinct f.order_number) as total_orders_sold
from warehouse.fact_sales f
join warehouse.dim_products p on p.product_key = f.product_key
group by extract(year from f.order_date), p.category
order by sales_year, total_revenue desc;

-- Computers was the largest contributor to the revenue loss
-- in dollar terms, while Home Appliances and Audio experienced some of the steepest percentage declines.
-- Every category declined in 2020.
-- So, 2020 decline was broad-based rather than caused by one isolated product category, country, or sales channel

-- compare 2019 vs 2020 units sold by category

select
p.category,
sum(
case
when extract(year from f.order_date) = 2019
then f.quantity
else 0
end) as units_sold_2019,
sum(
case
when extract(year from f.order_date) = 2020
then f.quantity
else 0
end) as units_sold_2020
from warehouse.fact_sales f
join warehouse.dim_products p on p.product_key = f.product_key
join warehouse.dim_store s on s.store_key = f.store_key
where extract(year from order_date) in (2019,2020)
group by p.category
;

-- Maven Electronics' 2020 revenue decline was primarily volume-driven. 
-- Orders and units sold fell sharply across both Online and Physical channels, markets, and product categories, 
-- while Average Order Value remained relatively stable. Computers contributed the largest absolute revenue loss, 
-- while Home Appliances experienced one of the steepest percentage declines.

-- Customer activity
select 
extract(year from f.order_date)::integer as sales_year,
sum(f.quantity) as total_units_sold,
count(distinct f.order_number) as total_orders_sold,
count(distinct f.customer_key) as total_customers,
round(count(distinct f.order_number)::numeric / count(distinct f.customer_key),2) as orders_per_customer
from warehouse.fact_sales f
join warehouse.dim_products p on p.product_key = f.product_key
group by extract(year from f.order_date);

-- Revenue

-- 2019 → 2020: -49.1%

-- Orders

-- 9,083 → 4,635: -49.0%

-- Active customers

-- 6,497 → 3,868: -40.5%

-- Orders per customer

-- 1.40 → 1.20: -14.3%

-- Average Order Value

-- $2,010.83 → $2,005.31: -0.3%

-- Units sold

-- 68,440 → 34,463: -49.6%

