-- ============================================================
-- E-COMMERCE SALES ANALYSIS USING MYSQL
-- MASTER SCRIPT - RUN THIS FILE FROM TOP TO BOTTOM
-- MySQL 8.0+
-- ============================================================


-- ======================================================================
-- FILE: 01_database_creation.sql
-- ======================================================================

-- ==========================================
-- 1. DATABASE CREATION
-- ==========================================
DROP DATABASE IF EXISTS ecommerce_sales_analysis;
CREATE DATABASE ecommerce_sales_analysis;
USE ecommerce_sales_analysis;

SET SESSION cte_max_recursion_depth = 20000;


-- ======================================================================
-- FILE: 02_table_creation.sql
-- ======================================================================

-- ==========================================
-- 2. TABLE CREATION
-- ==========================================
USE ecommerce_sales_analysis;

CREATE TABLE customers
(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL
);

CREATE TABLE products
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_product_price CHECK (price >= 0),
    CONSTRAINT chk_product_stock CHECK (stock_quantity >= 0)
);

CREATE TABLE orders
(
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    payment_method VARCHAR(30) NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT chk_order_status CHECK
        (order_status IN ('Completed','Pending','Cancelled','Shipped')),
    CONSTRAINT chk_payment_method CHECK
        (payment_method IN ('UPI','Credit Card','Debit Card','Net Banking',
                            'Cash on Delivery','Wallet'))
);

CREATE TABLE order_items
(
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id)
        REFERENCES products(product_id),
    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price CHECK (unit_price >= 0)
);


-- ======================================================================
-- FILE: 03_constraints_indexes.sql
-- ======================================================================

-- ==========================================
-- 3. CONSTRAINTS / INDEXES
-- ==========================================
USE ecommerce_sales_analysis;

CREATE INDEX idx_customers_state ON customers(state);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);


-- ======================================================================
-- FILE: 04_large_dataset_generation.sql
-- ======================================================================

-- ==========================================
-- 4. LARGE DATASET GENERATION
-- Generates:
-- Customers   = 2,000
-- Products    = 500
-- Orders      = 12,000
-- Order Items = 24,000
-- Total       = 38,500 rows
-- ==========================================
USE ecommerce_sales_analysis;
SET SESSION cte_max_recursion_depth = 20000;

-- 4.1 CUSTOMERS
INSERT INTO customers
(customer_id, customer_name, email, city, state, signup_date)
WITH RECURSIVE numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 2000
)
SELECT
    n,
    CONCAT(
        ELT(((n - 1) % 20) + 1,
        'Aarav','Aditi','Arjun','Ananya','Rahul','Priya','Rohan','Sneha',
        'Vikram','Neha','Aditya','Pooja','Karan','Kavya','Riya','Amit',
        'Nisha','Sahil','Meera','Rohit'),
        ' ',
        ELT(((n - 1) % 20) + 1,
        'Sharma','Patil','Pawar','Singh','Deshmukh','Kulkarni','Joshi','Gupta',
        'Mehta','Verma','Yadav','Khan','Shinde','Jadhav','Chavan','Mishra',
        'Reddy','Nair','Iyer','Kapoor')
    ),
    CASE WHEN n % 37 = 0 THEN NULL
         ELSE CONCAT('customer', n, '@example.com') END,
    ELT(((n - 1) % 20) + 1,
        'Mumbai','Pune','Nagpur','Nashik','Bengaluru','Mysuru','Ahmedabad',
        'Surat','Delhi','Amritsar','Chandigarh','Chennai','Hyderabad',
        'Lucknow','Jaipur','Kolkata','Thane','Aurangabad','Indore','Bhopal'),
    ELT(((n - 1) % 20) + 1,
        'Maharashtra','Maharashtra','Maharashtra','Maharashtra','Karnataka',
        'Karnataka','Gujarat','Gujarat','Delhi','Punjab','Punjab','Tamil Nadu',
        'Telangana','Uttar Pradesh','Rajasthan','West Bengal','Maharashtra',
        'Maharashtra','Madhya Pradesh','Madhya Pradesh'),
    DATE_ADD('2024-01-01', INTERVAL ((n * 17) % 500) DAY)
FROM numbers;

-- 4.2 PRODUCTS
INSERT INTO products
(product_id, product_name, category, price, stock_quantity)
WITH RECURSIVE numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 500
)
SELECT
    n,
    CONCAT(
        ELT(((n - 1) % 10) + 1,
        'Wireless Headphones','Smartphone','Laptop','Running Shoes','T-Shirt',
        'Backpack','Coffee Maker','Smart Watch','Office Chair','Bluetooth Speaker'),
        ' Model ', LPAD(n,3,'0')
    ),
    ELT(((n - 1) % 10) + 1,
        'Electronics','Electronics','Electronics','Fashion','Fashion',
        'Accessories','Home Appliances','Electronics','Furniture','Electronics'),
    ROUND(
        CASE
            WHEN n % 10 IN (1,8,10) THEN 1000 + RAND(n * 11) * 24000
            WHEN n % 10 IN (2,4) THEN 500 + RAND(n * 17) * 12000
            WHEN n % 10 IN (3,7) THEN 1000 + RAND(n * 23) * 18000
            ELSE 300 + RAND(n * 29) * 5000
        END, 2),
    FLOOR(10 + RAND(n * 31) * 490)
FROM numbers;

-- 4.3 ORDERS
INSERT INTO orders
(order_id, customer_id, order_date, order_status, payment_method)
WITH RECURSIVE numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 12000
)
SELECT
    n,
    ((n - 1) % 2000) + 1,
    DATE_ADD('2025-01-01', INTERVAL ((n * 7) % 638) DAY),
    CASE
        WHEN n % 20 BETWEEN 1 AND 2 THEN 'Cancelled'
        WHEN n % 20 BETWEEN 3 AND 5 THEN 'Pending'
        WHEN n % 20 BETWEEN 6 AND 10 THEN 'Shipped'
        ELSE 'Completed'
    END,
    ELT(((n - 1) % 6) + 1,
        'UPI','Credit Card','Debit Card','Net Banking','Cash on Delivery','Wallet')
FROM numbers;

-- 4.4 ORDER ITEMS: 2 items per order
INSERT INTO order_items
(order_item_id, order_id, product_id, quantity, unit_price)
WITH RECURSIVE numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 12000
),
item_slots AS
(
    SELECT 1 AS slot
    UNION ALL
    SELECT 2
)
SELECT
    ((n - 1) * 2) + slot,
    n,
    (((n * 13 + slot * 17) % 500) + 1),
    (((n * 7 + slot * 3) % 5) + 1),
    p.price
FROM numbers
CROSS JOIN item_slots
JOIN products p
    ON p.product_id = (((n * 13 + slot * 17) % 500) + 1);


-- ======================================================================
-- FILE: 05_data_validation.sql
-- ======================================================================

-- ==========================================
-- 5. DATA VALIDATION
-- ==========================================
USE ecommerce_sales_analysis;

SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_order_items FROM order_items;

SELECT * FROM customers LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_items LIMIT 10;


-- ======================================================================
-- FILE: 06_basic_sql.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 07_aggregate_groupby_having.sql
-- ======================================================================

-- ==========================================
-- 7. AGGREGATE FUNCTIONS / GROUP BY / HAVING
-- ==========================================
USE ecommerce_sales_analysis;

SELECT COUNT(*) AS total_orders FROM orders;
SELECT SUM(quantity) AS total_units_sold FROM order_items;
SELECT ROUND(AVG(price),2) AS average_product_price FROM products;
SELECT MIN(price) AS minimum_price FROM products;
SELECT MAX(price) AS maximum_price FROM products;

SELECT p.category, ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category ORDER BY revenue DESC;

SELECT c.state, COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.state ORDER BY total_orders DESC;

SELECT state, COUNT(*) AS total_customers
FROM customers GROUP BY state ORDER BY total_customers DESC;

SELECT o.payment_method, ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY o.payment_method ORDER BY revenue DESC;

SELECT category, ROUND(AVG(price),2) AS average_price
FROM products GROUP BY category ORDER BY average_price DESC;

SELECT p.product_id, p.product_name, SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

SELECT o.order_status, ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_status ORDER BY revenue DESC;

SELECT p.category, ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM products p JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) > 1000000
ORDER BY revenue DESC;

SELECT c.state, COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.state
HAVING COUNT(DISTINCT o.order_id) > 500
ORDER BY total_orders DESC;


-- ======================================================================
-- FILE: 08_joins.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 09_subqueries.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 10_ctes.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 11_window_functions.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 12_date_analysis.sql
-- ======================================================================

-- ==========================================
-- 12. DATE ANALYSIS
-- ==========================================
USE ecommerce_sales_analysis;

SELECT YEAR(order_date) AS order_year, COUNT(*) AS total_orders
FROM orders GROUP BY YEAR(order_date) ORDER BY order_year;

SELECT MONTH(order_date) AS order_month, COUNT(*) AS total_orders
FROM orders GROUP BY MONTH(order_date) ORDER BY order_month;

SELECT MONTHNAME(order_date) AS month_name, COUNT(*) AS total_orders
FROM orders
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY MONTH(order_date);

SELECT DAY(order_date) AS day_number, COUNT(*) AS total_orders
FROM orders GROUP BY DAY(order_date) ORDER BY day_number;

SELECT DAYNAME(order_date) AS day_name, COUNT(*) AS total_orders
FROM orders
GROUP BY DAYOFWEEK(order_date), DAYNAME(order_date)
ORDER BY DAYOFWEEK(order_date);

SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
       ROUND(SUM(oi.quantity * oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY sales_month;

SELECT YEAR(signup_date) AS signup_year,
       MONTH(signup_date) AS signup_month,
       COUNT(*) AS new_customers
FROM customers
GROUP BY YEAR(signup_date), MONTH(signup_date)
ORDER BY signup_year, signup_month;

WITH first_orders AS
(
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM orders GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, c.signup_date, f.first_order_date,
       DATEDIFF(f.first_order_date,c.signup_date) AS days_to_first_order
FROM customers c JOIN first_orders f ON c.customer_id = f.customer_id
ORDER BY days_to_first_order;

SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS total_orders,
       DATEDIFF(MAX(o.order_date),MIN(o.order_date)) AS active_days
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;

SELECT ROUND(AVG(TIMESTAMPDIFF(MONTH,c.signup_date,o.order_date)),2)
       AS average_months_from_signup_to_order
FROM customers c JOIN orders o ON c.customer_id = o.customer_id;


-- ======================================================================
-- FILE: 13_case_expressions.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 14_string_functions.sql
-- ======================================================================

-- ==========================================
-- 14. STRING FUNCTIONS
-- ==========================================
USE ecommerce_sales_analysis;

SELECT customer_id, CONCAT(customer_name,' - ',city,', ',state) AS customer_location
FROM customers LIMIT 20;

SELECT customer_name, UPPER(customer_name) AS uppercase_name
FROM customers LIMIT 20;

SELECT customer_name, LOWER(customer_name) AS lowercase_name
FROM customers LIMIT 20;

SELECT TRIM(customer_name) AS cleaned_name
FROM customers LIMIT 20;

SELECT customer_name, LEFT(customer_name,5) AS first_five_characters
FROM customers LIMIT 20;

SELECT customer_name, RIGHT(customer_name,5) AS last_five_characters
FROM customers LIMIT 20;

SELECT customer_name, SUBSTRING(customer_name,1,5) AS name_part
FROM customers LIMIT 20;

SELECT customer_name, REPLACE(customer_name,' ','_') AS formatted_name
FROM customers LIMIT 20;


-- ======================================================================
-- FILE: 15_null_handling.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 16_advanced_business_analysis.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 17_business_questions.sql
-- ======================================================================

-- ==========================================
-- 17. 25 BUSINESS QUESTIONS
-- ==========================================
USE ecommerce_sales_analysis;

-- Q1 Total revenue
SELECT ROUND(SUM(oi.quantity * oi.unit_price),2) AS total_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

-- Q2 Top 10 customers by spending
SELECT c.customer_id,c.customer_name,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS spending
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY c.customer_id,c.customer_name
ORDER BY spending DESC LIMIT 10;

-- Q3 Top 10 products by revenue
SELECT p.product_id,p.product_name,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.product_id,p.product_name
ORDER BY revenue DESC LIMIT 10;

-- Q4 Highest revenue category
SELECT p.category,ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category ORDER BY revenue DESC LIMIT 1;

-- Q5 Highest revenue state
SELECT c.state,ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY c.state ORDER BY revenue DESC LIMIT 1;

-- Q6 Monthly revenue
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m') ORDER BY month;

-- Q7 Most popular payment method
SELECT payment_method,COUNT(*) AS total_orders
FROM orders GROUP BY payment_method ORDER BY total_orders DESC LIMIT 1;

-- Q8 Products with zero sales
SELECT p.product_id,p.product_name
FROM products p LEFT JOIN order_items oi ON p.product_id=oi.product_id
WHERE oi.order_item_id IS NULL;

-- Q9 Customers with zero orders
SELECT c.customer_id,c.customer_name
FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id
WHERE o.order_id IS NULL;

-- Q10 Average order value
SELECT ROUND(SUM(oi.quantity*oi.unit_price)/COUNT(DISTINCT o.order_id),2) AS average_order_value
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

-- Q11 Total units sold
SELECT SUM(oi.quantity) AS total_units_sold
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped');

-- Q12 Customers with most orders
SELECT c.customer_id,c.customer_name,COUNT(o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY total_orders DESC LIMIT 10;

-- Q13 Cancellation rate
SELECT ROUND(SUM(order_status='Cancelled')/COUNT(*)*100,2) AS cancellation_rate
FROM orders;

-- Q14 Completed order rate
SELECT ROUND(SUM(order_status='Completed')/COUNT(*)*100,2) AS completed_order_rate
FROM orders;

-- Q15 Best-selling category by units
SELECT p.category,SUM(oi.quantity) AS units_sold
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.category ORDER BY units_sold DESC LIMIT 1;

-- Q16 Cities with most customers
SELECT city,COUNT(*) AS total_customers
FROM customers GROUP BY city ORDER BY total_customers DESC LIMIT 10;

-- Q17 Day with most orders
SELECT DAYNAME(order_date) AS day_name,COUNT(*) AS total_orders
FROM orders
GROUP BY DAYOFWEEK(order_date),DAYNAME(order_date)
ORDER BY total_orders DESC LIMIT 1;

-- Q18 Highest-value order
SELECT o.order_id,c.customer_name,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS order_value
FROM orders o JOIN customers c ON o.customer_id=c.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY o.order_id,c.customer_name
ORDER BY order_value DESC LIMIT 1;

-- Q19 Average price by category
SELECT category,ROUND(AVG(price),2) AS average_price
FROM products GROUP BY category ORDER BY average_price DESC;

-- Q20 Customers above average spending
WITH customer_sales AS
(
    SELECT c.customer_id,c.customer_name,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity*oi.unit_price ELSE 0 END) AS spending
    FROM customers c
    LEFT JOIN orders o ON c.customer_id=o.customer_id
    LEFT JOIN order_items oi ON o.order_id=oi.order_id
    GROUP BY c.customer_id,c.customer_name
)
SELECT customer_id,customer_name,ROUND(spending,2) AS spending
FROM customer_sales
WHERE spending > (SELECT AVG(spending) FROM customer_sales)
ORDER BY spending DESC;

-- Q21 Best-selling product by quantity
SELECT p.product_id,p.product_name,SUM(oi.quantity) AS units_sold
FROM products p JOIN order_items oi ON p.product_id=oi.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY p.product_id,p.product_name
ORDER BY units_sold DESC LIMIT 1;

-- Q22 Best sales month
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
       ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.order_status IN ('Completed','Shipped')
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY revenue DESC LIMIT 1;

-- Q23 Payment method with highest revenue
SELECT o.payment_method,
       ROUND(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                      THEN oi.quantity*oi.unit_price ELSE 0 END),2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY o.payment_method ORDER BY revenue DESC LIMIT 1;

-- Q24 State with highest AOV
SELECT c.state,
       ROUND(SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                      THEN oi.quantity*oi.unit_price ELSE 0 END)
             / COUNT(DISTINCT o.order_id),2) AS average_order_value
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY c.state ORDER BY average_order_value DESC LIMIT 1;

-- Q25 Top 3 customers in every state
WITH customer_sales AS
(
    SELECT c.state,c.customer_id,c.customer_name,
           SUM(CASE WHEN o.order_status IN ('Completed','Shipped')
                    THEN oi.quantity*oi.unit_price ELSE 0 END) AS spending
    FROM customers c JOIN orders o ON c.customer_id=o.customer_id
    JOIN order_items oi ON o.order_id=oi.order_id
    GROUP BY c.state,c.customer_id,c.customer_name
),
ranked_customers AS
(
    SELECT *,DENSE_RANK() OVER(PARTITION BY state ORDER BY spending DESC) AS customer_rank
    FROM customer_sales
)
SELECT state,customer_id,customer_name,ROUND(spending,2) AS spending,customer_rank
FROM ranked_customers
WHERE customer_rank<=3
ORDER BY state,customer_rank;


-- ======================================================================
-- FILE: 18_final_kpis.sql
-- ======================================================================

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


-- ======================================================================
-- FILE: 19_final_data_validation.sql
-- ======================================================================

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
