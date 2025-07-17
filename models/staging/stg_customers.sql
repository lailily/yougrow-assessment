WITH customers AS (
    SELECT * FROM {{ ref('customer_data')}}
),

renamed AS (
    SELECT
        id as customer_id,
        name,
        email,
        gender,
        state,
        country,
        STRPTIME(created_at, '%m/%d/%Y %H:%M:%S') as created_at,
        DATE(STRPTIME(created_at, '%m/%d/%Y %H:%M:%S')) as created_at_date,
        DATE_TRUNC('month', STRPTIME(created_at, '%m/%d/%Y %H:%M:%S')) as cohort_month
    FROM customers
)

SELECT *
FROM renamed