-- ==========================================
-- 16. ADVANCED BUSINESS ANALYSIS
-- ==========================================
USE ecommerce_sales_analysis;

-- Customer Lifetime Value
WITH customer_ltv AS
(
    SELECT c.customer_id, c.customer_name,
           COUNT(DISTINCT o.order_id) AS total_orders,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS total_revenue
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_orders,
       ROUND(total_revenue,2) AS lifetime_value,
       CASE
           WHEN total_revenue >= 100000 THEN 'Premium'
           WHEN total_revenue >= 50000 THEN 'High Value'
           WHEN total_revenue >= 20000 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS customer_segment
FROM customer_ltv ORDER BY lifetime_value DESC;

-- Product performance
WITH product_performance AS
(
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity) AS units_sold,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT *, RANK() OVER (ORDER BY revenue DESC) AS overall_rank
FROM product_performance ORDER BY revenue DESC;

-- Category market share
WITH category_sales AS
(
    SELECT p.category,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue
    FROM products p JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY p.category
)
SELECT category, ROUND(revenue,2) AS revenue,
       ROUND(revenue / SUM(revenue) OVER () * 100,2) AS revenue_percentage
FROM category_sales ORDER BY revenue DESC;

-- State performance
SELECT c.state,
       COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                      THEN oi.quantity * oi.unit_price ELSE 0 END),2) AS revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.state ORDER BY revenue DESC;

-- Payment method performance
SELECT o.payment_method,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                      THEN oi.quantity * oi.unit_price ELSE 0 END),2) AS revenue,
       ROUND(
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END)
           / COUNT(DISTINCT o.order_id), 2
       ) AS average_order_value
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.payment_method ORDER BY revenue DESC;
