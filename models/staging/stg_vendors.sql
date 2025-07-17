WITH vendors AS (
    SELECT * FROM {{ ref('vendor_data')}}
),

renamed AS (
    SELECT
        id AS vendor_id,
        title AS vendor_name,
        STRPTIME(created_at, '%m/%d/%Y %H:%M:%S') AS created_at
    FROM vendors
)

SELECT *
FROM renamed