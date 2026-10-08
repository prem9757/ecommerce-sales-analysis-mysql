-- ==========================================
-- 8. JOINS
-- ==========================================
USE ecommerce_sales_analysis;

-- INNER JOIN: customers with orders
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date, o.order_status
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
LIMIT 20;

-- INNER JOIN: orders with customer details
SELECT o.order_id, o.order_date, c.customer_name, c.city, c.state
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
LIMIT 20;

-- INNER JOIN: products sold in orders
SELECT oi.order_id, p.product_name, p.category, oi.quantity, oi.unit_price
FROM order_items oi JOIN products p ON oi.product_id = p.product_id
LIMIT 20;

-- LEFT JOIN: every customer and spending
SELECT c.customer_id, c.customer_name,
       COALESCE(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                         THEN oi.quantity * oi.unit_price ELSE 0 END),0) AS total_spending
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;

-- LEFT JOIN: every product and revenue
SELECT p.product_id, p.product_name,
       COALESCE(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                         THEN oi.quantity * oi.unit_price ELSE 0 END),0) AS revenue
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- Customers with no orders
SELECT c.customer_id, c.customer_name
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Products never sold
SELECT p.product_id, p.product_name
FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- RIGHT JOIN
SELECT c.customer_id, c.customer_name, o.order_id
FROM orders o RIGHT JOIN customers c ON o.customer_id = c.customer_id
LIMIT 20;
