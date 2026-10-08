-- ==========================================
-- 9. SUBQUERIES
-- ==========================================
USE ecommerce_sales_analysis;

-- Customers spending above average customer spending
SELECT customer_id, customer_name, total_spending
FROM (
    SELECT c.customer_id, c.customer_name,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity * oi.unit_price ELSE 0 END) AS total_spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
) customer_sales
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM (
        SELECT c.customer_id,
               SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                        THEN oi.quantity * oi.unit_price ELSE 0 END) AS total_spending
        FROM customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        LEFT JOIN order_items oi ON o.order_id = oi.order_id
        GROUP BY c.customer_id
    ) avg_sales
);

-- Products above average price
SELECT product_id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- Customers with more orders than average
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT customer_id, COUNT(*) AS order_count
        FROM orders GROUP BY customer_id
    ) x
);

-- Highest-value order
SELECT order_id, order_value
FROM (
    SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Completed','Shipped')
    GROUP BY o.order_id
) x
WHERE order_value = (
    SELECT MAX(order_value)
    FROM (
        SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_value
        FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.order_status IN ('Completed','Shipped')
        GROUP BY o.order_id
    ) y
);

-- Second-highest product price
SELECT product_id, product_name, price
FROM products
WHERE price = (
    SELECT MAX(price) FROM products
    WHERE price < (SELECT MAX(price) FROM products)
);

-- Customers above 50,000 spending
SELECT c.customer_id, c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS spending
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY c.customer_id, c.customer_name
HAVING spending > 50000;
