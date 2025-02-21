-- CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE IF NOT EXISTS warehouse.dim_product (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    translation TEXT
);
INSERT INTO warehouse.dim_product (product_id, product_category_name, translation)
SELECT DISTINCT ON (pr.product_id)
    pr.product_id::TEXT AS product_id,
    COALESCE(pr.product_category_name, 'Unknown')::TEXT AS product_category_name,
    COALESCE(pt.product_category_name_english, 'Unknown')::TEXT AS translation
FROM raw_data.olist_products_dataset pr
LEFT JOIN raw_data.product_category_name_translation pt 
    ON pr.product_category_name = pt.product_category_name
ORDER BY pr.product_id, pr.product_category_name
ON CONFLICT (product_id) DO NOTHING;


