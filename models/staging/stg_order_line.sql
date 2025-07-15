WITH order_lines AS (
    SELECT * FROM {{ ref('order_line_data')}}
),

renamed AS (
    SELECT
        id as order_line_id,
        order_id,
        product_id,
        quantity,
        total_price
    FROM order_lines
)

SELECT *
FROM renamed