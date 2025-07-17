-- example query for cohort analysis can be found in analyses/cohort_analysis.sql
WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('int_orders') }}
),

-- Generate date spine for all possible months
date_spine AS (
    {{
        dbt_utils.date_spine(
            datepart="month",
            start_date="CAST('2021-01-01' AS TIMESTAMP)",
            end_date="CAST('2021-04-01' AS TIMESTAMP)"
        )
    }}
),

-- Create customer-month combinations
customer_months AS (
    SELECT
        customers.customer_id,
        cohort_month,
        date_spine.date_month as activity_month,
        DATEDIFF('month', DATE_TRUNC('month', customers.created_at), date_spine.date_month) as months_since_cohort
    FROM customers
    CROSS JOIN date_spine
    WHERE DATE_TRUNC('month', customers.created_at) <= date_spine.date_month
),


-- Calculate customer metrics by month
customer_metrics AS (
    SELECT
        -- Customer and time dimensions
        customer_months.customer_id,
        customer_months.cohort_month,
        customer_months.activity_month,
        customer_months.months_since_cohort,
        
        -- Order metrics
        COUNT(DISTINCT orders.order_id) as total_orders,
        COALESCE(SUM(CASE WHEN NOT(orders.is_refunded) THEN orders.total_revenue ELSE 0 END), 0) as total_revenue,
        COALESCE(SUM(CASE WHEN NOT(orders.is_refunded) THEN orders.total_profit ELSE 0 END), 0) as total_profit,
        COALESCE(AVG(CASE WHEN NOT(orders.is_refunded) THEN orders.total_revenue ELSE 0 END), 0) as avg_order_value,
        COALESCE(AVG(CASE WHEN NOT(orders.is_refunded) THEN orders.basket_size ELSE 0 END), 0) as avg_basket_size,
        MAX(CASE WHEN orders.order_id IS NOT NULL THEN 1 ELSE 0 END) as is_active,
        
    FROM customer_months
    LEFT JOIN orders 
        ON customer_months.customer_id = orders.customer_id
        AND DATE_TRUNC('month', orders.created_at) = customer_months.activity_month
    GROUP BY ALL
),

final AS (
    SELECT
        -- Dimensions
        customer_id,
        cohort_month,
        activity_month,
        months_since_cohort,
        
        -- Activity flags
        is_active,
        
        -- Previous month activity for retention calculation
        LAG(is_active) OVER (
            PARTITION BY customer_id 
            ORDER BY activity_month
        ) as was_active_last_month,
        
        -- Order metrics
        total_orders,
        total_revenue,
        total_profit,
        avg_order_value,
        avg_basket_size,
        
        -- Cumulative metrics
        SUM(total_orders) OVER (
            PARTITION BY customer_id 
            ORDER BY activity_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as cumulative_orders,
        
        SUM(total_revenue) OVER (
            PARTITION BY customer_id 
            ORDER BY activity_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as cumulative_revenue,
        
        SUM(total_profit) OVER (
            PARTITION BY customer_id 
            ORDER BY activity_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as cumulative_profit,
        
        SUM(is_active) OVER (
            PARTITION BY customer_id 
            ORDER BY activity_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as cumulative_active_months,
        
        -- Activity metrics
        COUNT(*) OVER (
            PARTITION BY customer_id
        ) as total_months,
        
        SUM(is_active) OVER (
            PARTITION BY customer_id
        ) as active_months,
        
    FROM customer_metrics
)

SELECT * FROM final