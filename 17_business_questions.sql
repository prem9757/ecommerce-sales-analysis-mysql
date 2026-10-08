-- ==========================================
-- 17. 25 BUSINESS QUESTIONS
-- ==========================================
USE ecommerce_sales_analysis;

-- Q1 Total revenue
SELECT ROUND(SUM(oi.quantity * oi.unit_price),2) AS total_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

-- Q2 Top 10 customers by spending
SELECT c.customer_id,c.customer_name,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS spending
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY c.customer_id,c.customer_name
ORDER BY spending DESC LIMIT 10;

-- Q3 Top 10 products by revenue
SELECT p.product_id,p.product_name,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.product_id,p.product_name
ORDER BY revenue DESC LIMIT 10;

-- Q4 Highest revenue category
SELECT p.category,ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category ORDER BY revenue DESC LIMIT 1;

-- Q5 Highest revenue state
SELECT c.state,ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY c.state ORDER BY revenue DESC LIMIT 1;

-- Q6 Monthly revenue
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m') ORDER BY month;

-- Q7 Most popular payment method
SELECT payment_method,COUNT(*) AS total_orders
FROM orders GROUP BY payment_method ORDER BY total_orders DESC LIMIT 1;

-- Q8 Products with zero sales
SELECT p.product_id,p.product_name
FROM products p LEFT JOIN order_items oi ON p.product_id=oi.product_id
WHERE oi.order_item_id IS NULL;

-- Q9 Customers with zero orders
SELECT c.customer_id,c.customer_name
FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_id IS NULL;

-- Q10 Average order value
SELECT ROUND(SUM(oi.quantity*oi.unit_price)/COUNT(DISTINCT o.order_id),2) AS average_order_value
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

-- Q11 Total units sold
SELECT SUM(oi.quantity) AS total_units_sold
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

-- Q12 Customers with most orders
SELECT c.customer_id,c.customer_name,COUNT(o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY total_orders DESC LIMIT 10;

-- Q13 Cancellation rate
SELECT ROUND(SUM(order_status='Cancelled')/COUNT(*)*100,2) AS cancellation_rate
FROM orders;

-- Q14 Completed order rate
SELECT ROUND(SUM(order_status='Completed')/COUNT(*)*100,2) AS completed_order_rate
FROM orders;

-- Q15 Best-selling category by units
SELECT p.category,SUM(oi.quantity) AS units_sold
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category ORDER BY units_sold DESC LIMIT 1;

-- Q16 Cities with most customers
SELECT city,COUNT(*) AS total_customers
FROM customers GROUP BY city ORDER BY total_customers DESC LIMIT 10;

-- Q17 Day with most orders
SELECT DAYNAME(order_date) AS day_name,COUNT(*) AS total_orders
FROM orders
GROUP BY DAYOFWEEK(order_date),DAYNAME(order_date)
ORDER BY total_orders DESC LIMIT 1;

-- Q18 Highest-value order
SELECT o.order_id,c.customer_name,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS order_value
FROM orders o JOIN customers c ON o.customer_id=c.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY o.order_id,c.customer_name
ORDER BY order_value DESC LIMIT 1;

-- Q19 Average price by category
SELECT category,ROUND(AVG(price),2) AS average_price
FROM products GROUP BY category ORDER BY average_price DESC;

-- Q20 Customers above average spending
WITH customer_sales AS
(
    SELECT c.customer_id,c.customer_name,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity*oi.unit_price ELSE 0 END) AS spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id=o.customer_id
    LEFT JOIN order_items oi ON o.order_id=oi.order_id
    GROUP BY c.customer_id,c.customer_name
)
SELECT customer_id,customer_name,ROUND(spending,2) AS spending
FROM customer_sales
WHERE spending > (SELECT AVG(spending) FROM customer_sales)
ORDER BY spending DESC;

-- Q21 Best-selling product by quantity
SELECT p.product_id,p.product_name,SUM(oi.quantity) AS units_sold
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.product_id,p.product_name
ORDER BY units_sold DESC LIMIT 1;

-- Q22 Best sales month
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY revenue DESC LIMIT 1;

-- Q23 Payment method with highest revenue
SELECT o.payment_method,
       ROUND(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                      THEN oi.quantity*oi.unit_price ELSE 0 END),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY o.payment_method ORDER BY revenue DESC LIMIT 1;

-- Q24 State with highest AOV
SELECT c.state,
       ROUND(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                      THEN oi.quantity*oi.unit_price ELSE 0 END)
             / COUNT(DISTINCT o.order_id),2) AS average_order_value
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY c.state ORDER BY average_order_value DESC LIMIT 1;

-- Q25 Top 3 customers in every state
WITH customer_sales AS
(
    SELECT c.state,c.customer_id,c.customer_name,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity*oi.unit_price ELSE 0 END) AS spending
    FROM customers c JOIN orders o ON c.customer_id=o.customer_id
    JOIN order_items oi ON o.order_id=oi.order_id
    GROUP BY c.state,c.customer_id,c.customer_name
),
ranked_customers AS
(
    SELECT *,DENSE_RANK() OVER(PARTITION BY state ORDER BY spending DESC) AS customer_rank
    FROM customer_sales
)
SELECT state,customer_id,customer_name,ROUND(spending,2) AS spending,customer_rank
FROM ranked_customers
WHERE customer_rank<=3
ORDER BY state,customer_rank;
