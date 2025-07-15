WITH vendors AS (
    SELECT * FROM {{ ref('vendor_data')}}
),

renamed AS (
    SELECT
        id AS vendor_id,
        title AS vendor_name,
        created_at
    FROM vendors
)

SELECT *
FROM renamed