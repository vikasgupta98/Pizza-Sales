-- Q1 Retrieve the total number of orders placed.-- 

SELECT 
    COUNT(order_id) as total_orders
FROM
    orders;
    
--  Q2 Calculate the total revenue generated from pizza sales.

SELECT 
    SUM((orders_details.quantity * pizzas.price)) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;
    
-- Q3 Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Q4 Identify the most common pizza size ordered.

SELECT 
    pizzas.size AS size,
    COUNT(orders_details.quantity) AS quantity
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY size
ORDER BY quantity DESC;

-- Q5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name AS pizza_name,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_name
ORDER BY quantity DESC
LIMIT 5;

-- Q6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS total_qty
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY category
ORDER BY total_qty DESC
;

-- Q7 Determine the distribution of orders by hour of the day.

SELECT 
    hour(order_time) AS Hour, COUNT(order_id) AS count
FROM
    orders
GROUP BY Hour
ORDER BY count DESC;

-- Q8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id) AS count
FROM
    pizza_types
GROUP BY category;

-- Q9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(qty), 0) avg_per_day_order
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS qty
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS sum_data;

-- Q10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Q11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    CONCAT(ROUND((SUM(orders_details.quantity * pizzas.price) / (SELECT 
                            SUM(orders_details.quantity * pizzas.price) AS total_sales
                        FROM
                            orders_details
                                JOIN
                            pizzas ON orders_details.pizza_id = pizzas.pizza_id) * 100),
                    2),
            '%') AS revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Q12 Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over (order by order_date) as cum_revenue 
from (select orders.order_date, 
	sum(orders_details.quantity * pizzas.price) as revenue
from orders_details 
	join 
pizzas on orders_details.pizza_id = pizzas.pizza_id
	join 
orders on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;

-- Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category , pizza_types.name
ORDER BY revenue DESC) as a) as b
where rn<=3; 




