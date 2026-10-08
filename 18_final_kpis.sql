-- ==========================================
-- 18. FINAL KPI ANALYSIS
-- ==========================================
USE ecommerce_sales_analysis;

SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_order_items FROM order_items;

SELECT ROUND(SUM(oi.quantity*oi.unit_price),2) AS total_revenue
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

SELECT ROUND(
    SUM(oi.quantity*oi.unit_price)/COUNT(DISTINCT o.order_id),2
) AS average_order_value
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

SELECT SUM(oi.quantity) AS total_units_sold
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

SELECT p.product_id,p.product_name,SUM(oi.quantity) AS units_sold
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.product_id,p.product_name
ORDER BY units_sold DESC LIMIT 1;

SELECT p.category,SUM(oi.quantity) AS units_sold
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category ORDER BY units_sold DESC LIMIT 1;

SELECT c.customer_id,c.customer_name,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS total_spending
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY c.customer_id,c.customer_name
ORDER BY total_spending DESC LIMIT 1;

SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY revenue DESC LIMIT 1;

SELECT payment_method,COUNT(*) AS total_orders
FROM orders GROUP BY payment_method ORDER BY total_orders DESC LIMIT 1;

SELECT c.state,
       ROUND(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                      THEN oi.quantity*oi.unit_price ELSE 0 END),2) AS revenue
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY c.state ORDER BY revenue DESC LIMIT 1;

SELECT ROUND(SUM(order_status='Cancelled')/COUNT(*)*100,2)
       AS cancellation_rate_percentage
FROM orders;
