WITH orders AS (
    SELECT * FROM {{ ref('order_data')}}
),

renamed AS (
    SELECT
        id AS order_id,
        customer_id,
        currency,
        total_price,
        STRPTIME(created_at, '%m/%d/%Y %H:%M:%S') AS created_at,
        DATE(STRPTIME(created_at, '%m/%d/%Y %H:%M:%S')) AS created_at_date,
        CASE 
            WHEN refunded_at IS NOT NULL THEN STRPTIME(refunded_at, '%m/%d/%Y %H:%M:%S')
            ELSE NULL
        END AS refunded_at,
        refunded_at IS NOT NULL AS is_refunded
    FROM orders
)
SELECT *
FROM renamed