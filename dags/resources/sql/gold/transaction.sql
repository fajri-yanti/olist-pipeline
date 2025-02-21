-- CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE IF NOT EXISTS warehouse.fact_orders (
    fact_order_item_id TEXT PRIMARY KEY,
    order_id TEXT,
    customer_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    payment_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(10, 2)
);
INSERT INTO warehouse.fact_orders (
    fact_order_item_id,
    order_id,
    customer_id,
    product_id,
    seller_id,
    payment_id,
    order_status,
    order_purchase_timestamp,
    price,
    freight_value,
    payment_type,
    payment_installments,
    payment_value
)

SELECT
    encode(sha256((o.order_id || '-' || oi.product_id || '-' || oi.seller_id)::bytea), 'hex') AS fact_order_item_id,
    o.order_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    encode(sha256((o.order_id || '-' || p.payment_sequential::TEXT)::bytea), 'hex') AS payment_id,
    o.order_status,
    o.order_purchase_timestamp::TIMESTAMP,
    COALESCE(oi.price::NUMERIC, 0) AS price,
    COALESCE(oi.freight_value::NUMERIC, 0) AS freight_value,
    p.payment_type,
    p.payment_installments::INTEGER,
    p.payment_value::NUMERIC
FROM raw_data.olist_orders_dataset o
LEFT JOIN raw_data.olist_order_items_dataset oi ON o.order_id = oi.order_id
LEFT JOIN raw_data.olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE oi.product_id IS NOT NULL AND oi.seller_id IS NOT NULL
ON CONFLICT (fact_order_item_id) DO NOTHING;

