-- ==========================================
-- 10. CTEs
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
SELECT * FROM customer_sales ORDER BY total_spending DESC;

WITH product_sales AS
(
    SELECT p.product_id, p.product_name, p.category,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT * FROM product_sales ORDER BY revenue DESC;

WITH monthly_sales AS
(
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Completed','Shipped')
    GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
)
SELECT sales_month, ROUND(revenue,2) AS revenue
FROM monthly_sales ORDER BY sales_month;

WITH category_sales AS
(
    SELECT p.category,
           SUM(oi.quantity * oi.unit_price) AS revenue,
           SUM(oi.quantity) AS units_sold
    FROM products p JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status IN ('Completed','Shipped')
    GROUP BY p.category
)
SELECT category, ROUND(revenue,2) AS revenue, units_sold
FROM category_sales ORDER BY revenue DESC;

WITH customer_orders AS
(
    SELECT customer_id, COUNT(*) AS total_orders
    FROM orders GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
       COALESCE(co.total_orders,0) AS total_orders
FROM customers c LEFT JOIN customer_orders co
ON c.customer_id = co.customer_id
ORDER BY total_orders DESC;

WITH customer_sales AS
(
    SELECT c.customer_id,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS total_spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id
)
SELECT ROUND(AVG(total_spending),2) AS average_customer_spending
FROM customer_sales;
