CREATE SCHEMA IF NOT EXISTS warehouse;


CREATE TABLE IF NOT EXISTS warehouse.dim_customer (
    customer_id TEXT PRIMARY KEY,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state VARCHAR(2)
);

INSERT INTO warehouse.dim_customer (customer_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT DISTINCT
    customer_id::TEXT,
    customer_zip_code_prefix::INTEGER,
    customer_city::TEXT,
    customer_state::VARCHAR(2)
FROM raw_data.olist_customers_dataset
ON CONFLICT (customer_id) DO NOTHING;
