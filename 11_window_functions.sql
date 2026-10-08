-- ==========================================
-- 11. WINDOW FUNCTIONS
-- ==========================================
USE ecommerce_sales_analysis;

-- ROW_NUMBER / customer ranking
WITH customer_sales AS
(
    SELECT c.customer_id, c.customer_name,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS total_spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *, ROW_NUMBER() OVER (ORDER BY total_spending DESC) AS row_number_rank
FROM customer_sales ORDER BY total_spending DESC;

-- RANK
WITH customer_sales AS
(
    SELECT c.customer_id, c.customer_name,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS total_spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *, RANK() OVER (ORDER BY total_spending DESC) AS spending_rank
FROM customer_sales ORDER BY spending_rank;

-- DENSE_RANK and top 3 products per category
WITH product_sales AS
(
    SELECT p.product_id, p.product_name, p.category,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue
    FROM products p JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS
(
    SELECT *, DENSE_RANK() OVER
        (PARTITION BY category ORDER BY revenue DESC) AS category_rank
    FROM product_sales
)
SELECT * FROM ranked_products
WHERE category_rank <= 3
ORDER BY category, category_rank;

-- Second-highest product in every category
WITH product_sales AS
(
    SELECT p.product_id, p.product_name, p.category,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue
    FROM products p JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS
(
    SELECT *, DENSE_RANK() OVER
        (PARTITION BY category ORDER BY revenue DESC) AS category_rank
    FROM product_sales
)
SELECT * FROM ranked_products WHERE category_rank = 2;

-- LAG / monthly comparison
WITH monthly_sales AS
(
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Completed','Shipped')
    GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
)
SELECT sales_month, ROUND(revenue,2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY sales_month),2) AS previous_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY sales_month),2) AS revenue_change
FROM monthly_sales ORDER BY sales_month;

-- LEAD
WITH monthly_sales AS
(
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Completed','Shipped')
    GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
)
SELECT sales_month, ROUND(revenue,2) AS revenue,
       ROUND(LEAD(revenue) OVER (ORDER BY sales_month),2) AS next_month_revenue
FROM monthly_sales ORDER BY sales_month;

-- Running revenue
WITH monthly_sales AS
(
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Completed','Shipped')
    GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
)
SELECT sales_month, ROUND(revenue,2) AS monthly_revenue,
       ROUND(SUM(revenue) OVER (
           ORDER BY sales_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ),2) AS running_revenue
FROM monthly_sales ORDER BY sales_month;

-- AVG OVER / spending percentage / NTILE
WITH customer_sales AS
(
    SELECT c.customer_id, c.customer_name,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS total_spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(total_spending,2) AS total_spending,
       ROUND(AVG(total_spending) OVER (),2) AS average_customer_spending,
       ROUND(total_spending / SUM(total_spending) OVER () * 100,2) AS spending_percentage,
       NTILE(4) OVER (ORDER BY total_spending DESC) AS spending_quartile
FROM customer_sales;

-- First order per customer
WITH customer_orders AS
(
    SELECT c.customer_id, c.customer_name, o.order_id, o.order_date,
           ROW_NUMBER() OVER (
               PARTITION BY c.customer_id ORDER BY o.order_date, o.order_id
           ) AS rn
    FROM customers c JOIN orders o ON c.customer_id = o.customer_id
)
SELECT customer_id, customer_name, order_id, order_date
FROM customer_orders WHERE rn = 1;

-- Latest order per customer
WITH customer_orders AS
(
    SELECT c.customer_id, c.customer_name, o.order_id, o.order_date,
           ROW_NUMBER() OVER (
               PARTITION BY c.customer_id ORDER BY o.order_date DESC, o.order_id DESC
           ) AS rn
    FROM customers c JOIN orders o ON c.customer_id = o.customer_id
)
SELECT customer_id, customer_name, order_id, order_date
FROM customer_orders WHERE rn = 1;
