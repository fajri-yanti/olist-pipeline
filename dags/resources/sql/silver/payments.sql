CREATE SCHEMA IF NOT EXISTS warehouse;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_type_enum') THEN
        CREATE TYPE payment_type_enum AS ENUM (
            'credit_card',
            'boleto',
            'voucher',
            'debit_card',
            'bank_transfer',
            'coupon',
            'not_defined'
        );
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS warehouse.dim_payment (
    payment_id TEXT PRIMARY KEY,
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type payment_type_enum,
    payment_installments INTEGER,
    payment_value NUMERIC(10, 2)
);

INSERT INTO warehouse.dim_payment (
    payment_id,
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    encode(sha256(CONCAT(order_id, '-', payment_sequential::TEXT)::bytea), 'hex') AS payment_id,
    order_id::TEXT AS order_id,
    payment_sequential::INTEGER AS payment_sequential,
    payment_type::payment_type_enum AS payment_type,
    payment_installments::INTEGER AS payment_installments,
    payment_value::NUMERIC(10, 2) AS payment_value
FROM raw_data.olist_order_payments_dataset
ON CONFLICT (payment_id) DO NOTHING;
