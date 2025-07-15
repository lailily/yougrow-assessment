WITH customers AS (
    SELECT * FROM {{ ref('customer_data')}}
),

renamed AS (
    SELECT
        id as customer_id,
        name,
        email,
        state,
        country,
        created_at
    FROM customers
)

SELECT *
FROM renamed