-- Table 6

SELECT *
FROM orders;

SELECT *, ROW_NUMBER() OVER(PARTITION BY user_id, order_amount, order_date ORDER BY order_id) as row_num
FROM orders
;

SELECT *
FROM users;

SELECT *, ROW_NUMBER() OVER(PARTITION BY user_name ORDER BY user_id) as row_num
FROM users
;

SELECT *
FROM orders as o
LEFT JOIN users as u
	ON o.user_id = u.user_id
    WHERE u.user_id IS NULL
;
# this checks to ensure that every user_id from the orders table exists in the users table

SELECT *
FROM users as u
LEFT JOIN orders as o
	ON u.user_id = o.user_id
;

SELECT *
FROM orders as o
RIGHT JOIN users as u
	ON o.user_id = u.user_id
;


SELECT *
FROM users as u
LEFT JOIN orders as o
	ON u.user_id = o.user_id
    WHERE o.order_id IS NULL
;
# shows which users never ordered

SELECT u.user_id, u.user_name, o.order_id, o.order_amount, o.order_date
FROM orders as o
RIGHT JOIN users as u
	ON o.user_id = u.user_id
    WHERE o.order_id IS NULL
;
# shows which users never ordered (same as the previous query)

SELECT u.user_id, u.user_name
FROM users as u
LEFT JOIN orders as o
    ON u.user_id = o.user_id
WHERE o.order_id IS NULL;
# shows exactly which users never ordered and their ids

SELECT sum(o.order_amount) as total_revenue
FROM users as u
LEFT JOIN orders as o
	ON u.user_id = o.user_id
;
# this shows the total revenue generated from all orders

SELECT count(*) as total_orders
FROM users as u
LEFT JOIN orders as o
	ON u.user_id = o.user_id
where o.order_id IS NOT NULL
;
# this shows the total number of orders for the dataset

SELECT count(distinct u.user_id) as num_of_buyers
FROM users as u
LEFT JOIN orders as o
	ON u.user_id = o.user_id
where o.order_id IS NOT NULL
;
# this shows the exact number of buyers out of all the customers/users

SELECT sum(o.order_amount) as revenue_per_buyer, u.user_id, u.user_name
FROM users as u
LEFT JOIN orders as o
	ON u.user_id = o.user_id
where o.order_id IS NOT NULL
GROUP BY u.user_id, u.user_name
;
# this shows the exact amount of revenue generated per buyer

SELECT avg(r) as avg_est
from
(SELECT sum(o.order_amount) as r, u.user_id, u.user_name
FROM users as u
LEFT JOIN orders as o
	ON u.user_id = o.user_id
where o.order_id IS NOT NULL
GROUP BY u.user_id, u.user_name) as rev_per_buyer
;
# this is an estimate of the average revenue generated per buyer

SELECT *
FROM users as u
LEFT JOIN orders as o
	ON u.user_id = o.user_id
WHERE o.order_amount IN ( SELECT max(o.order_amount)
							FROM users as u
							LEFT JOIN orders as o
								ON u.user_id = o.user_id )
;
# this shows all the data on the customer with the largest order amount
