-- The Sales Archive feature on Commerce removes entries from the sales_order_grid when they're archived.
-- Because of this, those orders seemed to be missing from the Open Source backend.
-- This SQL script backfills the sales_order_grid table based on the existing database info.

INSERT INTO sales_order_grid (entity_id, status, store_id, store_name, customer_id, base_grand_total, base_total_paid, grand_total, total_paid, increment_id, base_currency_code, order_currency_code, shipping_name, billing_name, created_at, updated_at, billing_address, shipping_address, shipping_information, customer_email, customer_group, subtotal, shipping_and_handling, customer_name, payment_method, total_refunded)
SELECT
o.entity_id, status, store_id, store_name, o.customer_id, base_grand_total, base_total_paid, grand_total, total_paid, increment_id, base_currency_code, order_currency_code, CONCAT(sa.firstname, ' ', sa.lastname), CONCAT(ba.firstname, ' ', ba.lastname), created_at, updated_at, CONCAT(ba.street, ' ', ba.city, ' ', ba.region, ' ', ba.postcode), CONCAT(sa.street, ' ', sa.city, ' ', sa.region, ' ', sa.postcode), shipping_description, customer_email, customer_group_id, subtotal, o.shipping_amount, CONCAT(o.customer_firstname, ' ', o.customer_lastname), p.method, total_refunded
FROM sales_order o
INNER JOIN sales_order_address AS ba ON o.entity_id = ba.parent_id AND ba.address_type = 'billing'
INNER JOIN sales_order_address AS sa ON o.entity_id = sa.parent_id AND sa.address_type = 'shipping'
INNER JOIN sales_order_payment as p ON o.entity_id = p.parent_id
WHERE o.entity_id NOT IN (SELECT entity_id from sales_order_grid)
