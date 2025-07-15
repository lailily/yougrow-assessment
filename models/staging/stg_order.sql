WITH orders AS (
    SELECT * FROM {{ ref('order_data')}}
),

renamed AS (
    SELECT
        id as order_id,
        customer_id,
        currency,
        total_price,
        created_at,
        refunded_at,
        CASE WHEN refunded_at IS NOT NULL THEN true ELSE false END as is_refunded
    FROM orders
)
SELECT *
FROM renamed