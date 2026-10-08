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
