-- 1. Retrieve the top 5 customers who have made the highest average order amounts in the last 6 months.
with cte as (select max(STR_TO_DATE(order_date, '%Y-%m-%d')) as max_od from orders)

SELECT 
    c.customer_id, 
    c.name , 
     AVG(o.total_price) AS average_order_amount
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id 
WHere DATEDIFF((select * from cte), STR_TO_DATE(o.order_date, '%Y-%m-%d')) <= 180
GROUP BY 
     c.customer_id, c.name
ORDER BY 
    3 DESC
LIMIT 5 ;


-- 2. Retrieve the list of customers whose order value is lower this year compared to the previous year.
with this_year_orders as (
	SELECT 
        customer_id, 
        SUM(total_price) AS total_this_year
     FROM 
        orders
     WHERE 
        YEAR(STR_TO_DATE(order_date, '%Y-%m-%d')) = 2024
     GROUP BY 
        customer_id
	),
last_year_orders as (
	SELECT 
        customer_id, 
        SUM(total_price) AS total_last_year
     FROM 
        orders
     WHERE 
        YEAR(STR_TO_DATE(order_date, '%Y-%m-%d')) = 2023
     GROUP BY 
        customer_id
	)
    
SELECT 
    c.customer_id, 
    c.name
FROM 
    customers c
JOIN 
    this_year_orders 
ON 
    c.customer_id = this_year_orders.customer_id
JOIN 
    last_year_orders 
ON 
    c.customer_id = last_year_orders.customer_id
WHERE 
    this_year_orders.total_this_year < last_year_orders.total_last_year ;










