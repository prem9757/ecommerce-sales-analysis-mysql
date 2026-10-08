-- ==========================================
-- 6. BASIC SQL
-- ==========================================
USE ecommerce_sales_analysis;

SELECT * FROM customers LIMIT 10;

SELECT DISTINCT state FROM customers;

SELECT * FROM products WHERE price > 10000;

SELECT * FROM products ORDER BY price DESC LIMIT 10;

SELECT * FROM products WHERE price BETWEEN 1000 AND 5000;

SELECT * FROM customers
WHERE state IN ('Maharashtra','Karnataka','Gujarat');

SELECT * FROM customers
WHERE state NOT IN ('Maharashtra','Karnataka','Gujarat');

SELECT * FROM customers WHERE customer_name LIKE 'A%';

SELECT * FROM customers WHERE email IS NULL;

SELECT * FROM customers WHERE email IS NOT NULL;

SELECT * FROM products
WHERE price > 5000 AND stock_quantity > 100;

SELECT * FROM customers
WHERE state = 'Maharashtra' OR state = 'Karnataka';

SELECT * FROM orders
WHERE NOT order_status = 'Cancelled';

-- Data exploration
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_order_items FROM order_items;

SELECT ROUND(SUM(oi.quantity * oi.unit_price),2) AS total_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

SELECT ROUND(
    SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2
) AS average_order_value
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

SELECT MIN(price) AS minimum_product_price FROM products;
SELECT MAX(price) AS maximum_product_price FROM products;
SELECT DISTINCT category FROM products;
SELECT DISTINCT order_status FROM orders;
SELECT DISTINCT payment_method FROM orders;
SELECT DISTINCT state FROM customers;
