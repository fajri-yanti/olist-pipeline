-- CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE IF NOT EXISTS warehouse.dim_seller (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state VARCHAR(2)
);

INSERT INTO warehouse.dim_seller (seller_id, seller_zip_code_prefix, seller_city, seller_state)
SELECT DISTINCT
    seller_id::TEXT,
    seller_zip_code_prefix::INTEGER,
    seller_city::TEXT,
    seller_state::VARCHAR(2)
FROM raw_data.olist_sellers_dataset
ON CONFLICT (seller_id) DO NOTHING;
