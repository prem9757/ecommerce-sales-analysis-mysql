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
