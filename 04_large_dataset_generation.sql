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
