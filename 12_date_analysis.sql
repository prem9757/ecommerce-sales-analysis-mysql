-- ==========================================
-- 12. DATE ANALYSIS
-- ==========================================
USE ecommerce_sales_analysis;

SELECT YEAR(order_date) AS order_year, COUNT(*) AS total_orders
FROM orders GROUP BY YEAR(order_date) ORDER BY order_year;

SELECT MONTH(order_date) AS order_month, COUNT(*) AS total_orders
FROM orders GROUP BY MONTH(order_date) ORDER BY order_month;

SELECT MONTHNAME(order_date) AS month_name, COUNT(*) AS total_orders
FROM orders
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY MONTH(order_date);

SELECT DAY(order_date) AS day_number, COUNT(*) AS total_orders
FROM orders GROUP BY DAY(order_date) ORDER BY day_number;

SELECT DAYNAME(order_date) AS day_name, COUNT(*) AS total_orders
FROM orders
GROUP BY DAYOFWEEK(order_date), DAYNAME(order_date)
ORDER BY DAYOFWEEK(order_date);

SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
       ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY sales_month;

SELECT YEAR(signup_date) AS signup_year,
       MONTH(signup_date) AS signup_month,
       COUNT(*) AS new_customers
FROM customers
GROUP BY YEAR(signup_date), MONTH(signup_date)
ORDER BY signup_year, signup_month;

WITH first_orders AS
(
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM orders GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, c.signup_date, f.first_order_date,
       DATEDIFF(f.first_order_date,c.signup_date) AS days_to_first_order
FROM customers c JOIN first_orders f ON c.customer_id = f.customer_id
ORDER BY days_to_first_order;

SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS total_orders,
       DATEDIFF(MAX(o.order_date),MIN(o.order_date)) AS active_days
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;

SELECT ROUND(AVG(TIMESTAMPDIFF(MONTH,c.signup_date,o.order_date)),2)
       AS average_months_from_signup_to_order
FROM customers c JOIN orders o ON c.customer_id = o.customer_id;
