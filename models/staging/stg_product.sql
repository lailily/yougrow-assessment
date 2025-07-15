WITH products AS (
    SELECT * FROM {{ ref('product_data')}}
),

renamed AS (
    SELECT
        product as product_id,
        title as product_name,
        category as category_id,
        price,
        cost,
        vendor as vendor_id,
        created_at
    FROM products
)

SELECT *
FROM renamed