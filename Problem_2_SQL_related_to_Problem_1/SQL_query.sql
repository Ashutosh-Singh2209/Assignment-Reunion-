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



-- 3. Create a table showing cumulative purchase by a particular customer, broken down by product category.
SELECT 
    c.customer_id, 
    c.name AS customer_name,
    p.category as product_catagory, 
    SUM(o.total_price) AS cumulative_purchase_per_catagory
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
JOIN 
    products p ON o.product_id = p.product_id
GROUP BY 
    c.customer_id, c.name, p.category
ORDER BY 
    customer_id, p.category;


-- 4. Retrieve the list of top 5 selling products. Further bifurcate the sales by product variants.
-- Top 5 by product

SELECT 
	p.product_id, 
	p.product_name, 
	SUM(o.quantity) AS total_sold_by_product,
	min(p.category) as catagory
FROM 
	products p
JOIN 
	orders o ON p.product_id = o.product_id 
group by p.product_id, p.product_name
order by total_sold_by_product desc
limit 5 ;

-- Top 5 by Variant




with cte as (
	SELECT 
		p.product_id, 
		p.product_name, 
		SUM(o.quantity) over (partition by p.product_name) AS total_sold_by_product,
		SUM(o.quantity) over (partition by p.product_name, p.variant_name) AS total_sold_by_varient,
		p.category,
		p.variant_name
	FROM 
		products p
	JOIN 
		orders o ON p.product_id = o.product_id )

select * from cte ;
