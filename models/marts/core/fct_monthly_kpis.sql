-- example query
-- SELECT * FROM fct_monthly_kpis
-- ORDER BY order_month DESC

WITH orders AS(
    SELECT 
        * 
    FROM {{ ref('int_orders') }}
),

agg_orders_by_month AS (
    SELECT
        order_month,
        ROUND(SUM(total_revenue), 2) AS gross_merchandise_value,
        ROUND(SUM(CASE WHEN NOT(is_refunded) THEN total_revenue ELSE 0 END), 2) AS gross_merchandise_value_excluding_refunds,
        ROUND(AVG(basket_size), 2) AS avg_basket_size,
        ROUND(AVG(total_revenue), 2) AS avg_order_value,
        COUNT(DISTINCT customer_id) AS total_active_customers
    FROM orders
    GROUP BY ALL
)

SELECT * FROM agg_orders_by_month