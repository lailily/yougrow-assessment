-- Monthly Cohort Analysis
WITH metrics AS (
    SELECT * FROM {{ ref('fct_customer_monthly_cohort') }}
),

-- First calculate customer purchase metrics
customer_purchase_metrics AS (
    SELECT
        cohort_month,
        activity_month,
        months_since_cohort,
        total_customers_in_cohort,
        -- Average Purchase Value = Total Revenue / Total Number of Orders
        SUM(total_revenue) / SUM(total_orders) as avg_purchase_value,
        
        -- Purchase Frequency = Total Number of Orders / Total Number of Customers
        SUM(total_orders) / COUNT(DISTINCT customer_id) as purchase_frequency,
        
        -- Count active customers for retention
        COUNT(DISTINCT CASE WHEN is_active = 1 THEN customer_id END) as active_customers,

        -- Average Activity Rate
        AVG(cumulative_active_months) as avg_customer_lifespan
        
    FROM metrics
    GROUP BY ALL
),

-- Calculate final metrics including CLV
cohort_metrics AS (
    SELECT
        cohort_month,
        activity_month,
        months_since_cohort,
        total_customers_in_cohort,
        active_customers,
        avg_customer_lifespan,
        ROUND(active_customers / total_customers_in_cohort, 3) as retention_rate,
        ROUND(avg_purchase_value, 2) as avg_purchase_value,
        -- Purchase Frequency (per month)
        ROUND(purchase_frequency, 2) as purchase_frequency,
        -- Customer Lifetime Value
        -- CLV = Average Purchase Value (Based on Total Revenue) × Purchase Frequency × Avg Customer Lifespan
        ROUND(
            avg_purchase_value * 
            purchase_frequency * 
            avg_customer_lifespan
        , 2) as customer_lifetime_value
    FROM customer_purchase_metrics
)

SELECT 
    cohort_month,
    activity_month,
    months_since_cohort,
    total_customers_in_cohort,
    active_customers,
    retention_rate,
    avg_purchase_value,
    purchase_frequency,
    ROUND(avg_customer_lifespan, 2) as avg_customer_lifespan,
    customer_lifetime_value as clv
FROM cohort_metrics
ORDER BY cohort_month, activity_month;
