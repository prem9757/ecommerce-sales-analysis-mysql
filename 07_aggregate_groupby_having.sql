-- ==========================================
-- 7. AGGREGATE FUNCTIONS / GROUP BY / HAVING
-- ==========================================
USE ecommerce_sales_analysis;

SELECT COUNT(*) AS total_orders FROM orders;
SELECT SUM(quantity) AS total_units_sold FROM order_items;
SELECT ROUND(AVG(price),2) AS average_product_price FROM products;
SELECT MIN(price) AS minimum_price FROM products;
SELECT MAX(price) AS maximum_price FROM products;

SELECT p.category, ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category ORDER BY revenue DESC;

SELECT c.state, COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.state ORDER BY total_orders DESC;

SELECT state, COUNT(*) AS total_customers
FROM customers GROUP BY state ORDER BY total_customers DESC;

SELECT o.payment_method, ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY o.payment_method ORDER BY revenue DESC;

SELECT category, ROUND(AVG(price),2) AS average_price
FROM products GROUP BY category ORDER BY average_price DESC;

SELECT p.product_id, p.product_name, SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

SELECT o.order_status, ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_status ORDER BY revenue DESC;

SELECT p.category, ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM products p JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) > 1000000
ORDER BY revenue DESC;

SELECT c.state, COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.state
HAVING COUNT(DISTINCT o.order_id) > 500
ORDER BY total_orders DESC;
