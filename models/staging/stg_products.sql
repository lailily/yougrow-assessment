WITH products AS (
    SELECT * FROM {{ ref('product_data')}}
),

renamed AS (
    SELECT
        product AS product_id,
        title AS product_name,
        category AS category_id,
        price,
        cost,
        ROUND(price - cost, 2) as profit,
        vendor AS vendor_id,
        STRPTIME(created_at, '%m/%d/%Y %H:%M:%S') as created_at
    FROM products
)

SELECT *
FROM renamed