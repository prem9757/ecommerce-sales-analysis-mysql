-- ==========================================
-- 13. CASE EXPRESSIONS
-- ==========================================
USE ecommerce_sales_analysis;

WITH customer_sales AS
(
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                             THEN oi.quantity * oi.unit_price ELSE 0 END),0) AS total_spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(total_spending,2) AS total_spending,
       CASE
           WHEN total_spending >= 50000 THEN 'High Value'
           WHEN total_spending >= 20000 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS customer_segment
FROM customer_sales ORDER BY total_spending DESC;

SELECT product_id, product_name, price,
       CASE
           WHEN price >= 15000 THEN 'Expensive'
           WHEN price >= 5000 THEN 'Moderate'
           ELSE 'Low Price'
       END AS price_segment
FROM products ORDER BY price DESC;

SELECT order_id, order_status,
       CASE
           WHEN order_status = 'Completed' THEN 'Completed'
           WHEN order_status = 'Pending' THEN 'Pending'
           WHEN order_status = 'Cancelled' THEN 'Cancelled'
           WHEN order_status = 'Shipped' THEN 'Shipped'
           ELSE 'Unknown'
       END AS order_category
FROM orders;

SELECT p.category,
       SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                THEN oi.quantity * oi.unit_price ELSE 0 END) AS valid_revenue,
       SUM(CASE WHEN o.order_status = 'Cancelled'
                THEN oi.quantity * oi.unit_price ELSE 0 END) AS cancelled_value
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category
ORDER BY valid_revenue DESC;
