-- ==========================================
-- 19. FINAL DATA VALIDATION
-- ==========================================
USE ecommerce_sales_analysis;

-- Record counts
SELECT 'customers' AS table_name,COUNT(*) AS record_count FROM customers
UNION ALL SELECT 'products',COUNT(*) FROM products
UNION ALL SELECT 'orders',COUNT(*) FROM orders
UNION ALL SELECT 'order_items',COUNT(*) FROM order_items;

-- Duplicate IDs
SELECT customer_id,COUNT(*) AS duplicate_count FROM customers
GROUP BY customer_id HAVING COUNT(*)>1;

SELECT product_id,COUNT(*) AS duplicate_count FROM products
GROUP BY product_id HAVING COUNT(*)>1;

SELECT order_id,COUNT(*) AS duplicate_count FROM orders
GROUP BY order_id HAVING COUNT(*)>1;

-- NULL checks
SELECT
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(customer_name IS NULL) AS null_customer_name,
    SUM(email IS NULL) AS null_email,
    SUM(city IS NULL) AS null_city,
    SUM(state IS NULL) AS null_state,
    SUM(signup_date IS NULL) AS null_signup_date
FROM customers;

SELECT
    SUM(product_id IS NULL) AS null_product_id,
    SUM(product_name IS NULL) AS null_product_name,
    SUM(category IS NULL) AS null_category,
    SUM(price IS NULL) AS null_price,
    SUM(stock_quantity IS NULL) AS null_stock
FROM products;

SELECT
    SUM(order_id IS NULL) AS null_order_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(order_status IS NULL) AS null_status,
    SUM(payment_method IS NULL) AS null_payment_method
FROM orders;

SELECT
    SUM(order_item_id IS NULL) AS null_order_item_id,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(product_id IS NULL) AS null_product_id,
    SUM(quantity IS NULL) AS null_quantity,
    SUM(unit_price IS NULL) AS null_unit_price
FROM order_items;

-- Invalid foreign keys
SELECT o.* FROM orders o
LEFT JOIN customers c ON o.customer_id=c.customer_id
WHERE c.customer_id IS NULL;

SELECT oi.* FROM order_items oi
LEFT JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_id IS NULL;

SELECT oi.* FROM order_items oi
LEFT JOIN products p ON oi.product_id=p.product_id
WHERE p.product_id IS NULL;

-- Products with zero sales
SELECT p.product_id,p.product_name
FROM products p LEFT JOIN order_items oi ON p.product_id=oi.product_id
WHERE oi.order_item_id IS NULL;

-- Customers with zero orders
SELECT c.customer_id,c.customer_name
FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_id IS NULL;

-- Cancelled orders
SELECT COUNT(*) AS cancelled_orders
FROM orders WHERE order_status='Cancelled';

-- Invalid prices / stock / quantities
SELECT * FROM products WHERE price<0;
SELECT * FROM products WHERE stock_quantity<0;
SELECT * FROM order_items WHERE quantity<=0;
SELECT * FROM order_items WHERE unit_price<0;

-- Invalid statuses
SELECT DISTINCT order_status FROM orders
WHERE order_status NOT IN ('Completed','Pending','Cancelled','Shipped');

-- Invalid payment methods
SELECT DISTINCT payment_method FROM orders
WHERE payment_method NOT IN
('UPI','Credit Card','Debit Card','Net Banking','Cash on Delivery','Wallet');

-- Final KPI summary
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM order_items) AS total_order_items,
    (
        SELECT ROUND(SUM(oi.quantity*oi.unit_price),2)
        FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
        WHERE o.order_status IN ('Completed','Shipped')
    ) AS total_revenue,
    (
        SELECT ROUND(
            SUM(oi.quantity*oi.unit_price)/COUNT(DISTINCT o.order_id),2
        )
        FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
        WHERE o.order_status IN ('Completed','Shipped')
    ) AS average_order_value,
    (
        SELECT SUM(oi.quantity)
        FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
        WHERE o.order_status IN ('Completed','Shipped')
    ) AS total_units_sold,
    (
        SELECT ROUND(SUM(order_status='Cancelled')/COUNT(*)*100,2)
        FROM orders
    ) AS cancellation_rate_percentage;
