-- CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE IF NOT EXISTS warehouse.dim_order_items (
    order_item_id TEXT PRIMARY KEY,
    order_id TEXT,
    customer_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);
INSERT INTO warehouse.dim_order_items (
    order_item_id,
    order_id,
    customer_id,
    product_id,
    seller_id,
    price,
    freight_value,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)

SELECT 
    encode(sha256((o.order_id || '-' || COALESCE(oi.product_id, '') || '-' || COALESCE(oi.seller_id, ''))::bytea), 'hex') AS order_item_id,
    o.order_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    COALESCE(oi.price::NUMERIC, 0) AS price,  
    COALESCE(oi.freight_value::NUMERIC, 0) AS freight_value,
    o.order_status,
    o.order_purchase_timestamp::TIMESTAMP,
    o.order_approved_at::TIMESTAMP,
    o.order_delivered_carrier_date::TIMESTAMP,
    o.order_delivered_customer_date::TIMESTAMP,
    o.order_estimated_delivery_date::TIMESTAMP
FROM raw_data.olist_orders_dataset o
LEFT JOIN raw_data.olist_order_items_dataset oi
ON o.order_id = oi.order_id
ON CONFLICT (order_item_id) DO NOTHING;

