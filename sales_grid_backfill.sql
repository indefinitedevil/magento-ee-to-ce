-- The Sales Archive feature on Commerce removes entries from the sales_*_grid tables when they're archived.
-- Because of this, those orders seemed to be missing from the Open Source backend.
-- This SQL script backfills the sales_*_grid tables based on the existing database info.

INSERT INTO sales_order_grid (entity_id, status, store_id, store_name, customer_id, base_grand_total, base_total_paid, grand_total, total_paid, increment_id, base_currency_code, order_currency_code, shipping_name, billing_name, created_at, updated_at, billing_address, shipping_address, shipping_information, customer_email, customer_group, subtotal, shipping_and_handling, customer_name, payment_method, total_refunded)
SELECT
o.entity_id, status, store_id, store_name, o.customer_id, base_grand_total, base_total_paid, grand_total, total_paid, increment_id, base_currency_code, order_currency_code, CONCAT(sa.firstname, ' ', sa.lastname), CONCAT(ba.firstname, ' ', ba.lastname), created_at, updated_at, CONCAT(ba.street, ' ', ba.city, ' ', ba.region, ' ', ba.postcode), CONCAT(sa.street, ' ', sa.city, ' ', sa.region, ' ', sa.postcode), shipping_description, customer_email, customer_group_id, subtotal, o.shipping_amount, CONCAT(o.customer_firstname, ' ', o.customer_lastname), p.method, total_refunded
FROM sales_order o
INNER JOIN sales_order_address AS ba ON o.entity_id = ba.parent_id AND ba.address_type = 'billing'
INNER JOIN sales_order_address AS sa ON o.entity_id = sa.parent_id AND sa.address_type = 'shipping'
INNER JOIN sales_order_payment as p ON o.entity_id = p.parent_id
WHERE o.entity_id NOT IN (SELECT entity_id from sales_order_grid)

INSERT INTO sales_invoice_grid (entity_id, increment_id, state, store_id, store_name, order_id, order_increment_id, order_created_at, customer_name, customer_email, customer_group_id, payment_method, store_currency_code, order_currency_code, base_currency_code, global_currency_code, billing_name, billing_address, shipping_address, shipping_information, subtotal, shipping_and_handling, grand_total, base_grand_total, created_at, updated_at)
SELECT
i.entity_id, i.increment_id, i.state, i.store_id, store.name, order_id, o.increment_id, o.created_at, CONCAT(o.customer_firstname, ' ', o.customer_lastname), o.customer_email, o.customer_group_id, p.method, i.store_currency_code, i.order_currency_code, i.base_currency_code, i.global_currency_code, CONCAT(ba.firstname, ' ', ba.lastname), CONCAT(ba.street, ' ', ba.city, ' ', ba.region, ' ', ba.postcode), CONCAT(sa.street, ' ', sa.city, ' ', sa.region, ' ', sa.postcode), o.shipping_description, i.subtotal, i.shipping_amount, i.grand_total, i.base_grand_total, i.created_at, i.updated_at
FROM sales_invoice i
INNER JOIN store ON i.store_id = store.store_id
INNER JOIN sales_order o ON o.entity_id = i.order_id
INNER JOIN sales_order_address AS ba ON o.entity_id = ba.parent_id AND ba.address_type = 'billing'
INNER JOIN sales_order_address AS sa ON o.entity_id = sa.parent_id AND sa.address_type = 'shipping'
INNER JOIN sales_order_payment as p ON o.entity_id = p.parent_id
WHERE i.entity_id NOT IN (SELECT entity_id from sales_invoice_grid)

INSERT INTO sales_creditmemo_grid (entity_id, increment_id, created_at, updated_at, order_id, order_increment_id, order_created_at, billing_name, billing_address, shipping_address, customer_name, customer_email, customer_group_id, payment_method, shipping_information, subtotal, shipping_and_handling, adjustment_positive, adjustment_negative, order_base_grand_total)
SELECT
c.entity_id, c.increment_id, c.created_at, c.updated_at, order_id, o.increment_id, o.created_at, IFNULL(CONCAT(ba.firstname, ' ', ba.lastname), IFNULL(CONCAT(o.customer_firstname, ' ', o.customer_lastname), 'Unknown name')), CONCAT(ba.street, ' ', ba.city, ' ', ba.region, ' ', ba.postcode), CONCAT(sa.street, ' ', sa.city, ' ', sa.region, ' ', sa.postcode), IFNULL(CONCAT(o.customer_firstname, ' ', o.customer_lastname), IFNULL(CONCAT(ba.firstname, ' ', ba.lastname), 'Unknown name')), o.customer_email, o.customer_group_id, p.method, o.shipping_description, c.subtotal, c.shipping_amount, c.adjustment_positive, c.adjustment_negative, o.base_grand_total
FROM sales_creditmemo c
INNER JOIN store ON c.store_id = store.store_id
INNER JOIN sales_order o ON o.entity_id = c.order_id
INNER JOIN sales_order_address AS ba ON o.entity_id = ba.parent_id AND ba.address_type = 'billing'
INNER JOIN sales_order_address AS sa ON o.entity_id = sa.parent_id AND sa.address_type = 'shipping'
INNER JOIN sales_order_payment as p ON o.entity_id = p.parent_id
WHERE c.entity_id NOT IN (SELECT entity_id from sales_creditmemo_grid)

INSERT INTO sales_shipment_grid (entity_id, increment_id, store_id, order_id, order_increment_id, order_created_at, customer_name, total_qty, shipment_status, order_status, billing_name, billing_address, shipping_address, customer_email, customer_group_id, payment_method, shipping_information, created_at, updated_at)
SELECT
s.entity_id, s.increment_id, s.store_id, order_id, o.increment_id, o.created_at, IFNULL(CONCAT(o.customer_firstname, ' ', o.customer_lastname), IFNULL(CONCAT(ba.firstname, ' ', ba.lastname), 'Unknown name')), s.total_qty, shipment_status, o.status, IFNULL(CONCAT(ba.firstname, ' ', ba.lastname), IFNULL(CONCAT(o.customer_firstname, ' ', o.customer_lastname), 'Unknown name')), CONCAT(ba.street, ' ', ba.city, ' ', ba.region, ' ', ba.postcode), CONCAT(sa.street, ' ', sa.city, ' ', sa.region, ' ', sa.postcode), o.customer_email, o.customer_group_id, p.method, o.shipping_description, s.created_at, s.updated_at
FROM sales_shipment s
INNER JOIN store ON s.store_id = store.store_id
INNER JOIN sales_order o ON o.entity_id = s.order_id
INNER JOIN sales_order_address AS ba ON o.entity_id = ba.parent_id AND ba.address_type = 'billing'
INNER JOIN sales_order_address AS sa ON o.entity_id = sa.parent_id AND sa.address_type = 'shipping'
INNER JOIN sales_order_payment as p ON o.entity_id = p.parent_id
WHERE s.entity_id NOT IN (SELECT entity_id from sales_shipment_grid)
