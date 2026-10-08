-- ==========================================
-- 15. NULL HANDLING
-- ==========================================
USE ecommerce_sales_analysis;

SELECT customer_id, customer_name, email
FROM customers WHERE email IS NULL;

SELECT customer_id, customer_name,
       IFNULL(email,'Email Not Available') AS email_status
FROM customers;

SELECT c.customer_id, c.customer_name,
       COALESCE(SUM(
           CASE WHEN o.order_status IN ('Completed','Shipped')
                THEN oi.quantity * oi.unit_price ELSE 0 END
       ),0) AS total_spending
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;
