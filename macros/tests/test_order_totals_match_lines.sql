{% test test_order_totals_match_lines(model) %}

WITH order_lines_total AS (
    SELECT 
        order_id,
        ROUND(SUM(total_price), 2) as lines_total
    FROM {{ ref('stg_order_line') }}
    GROUP BY order_id
),

order_totals AS (
    SELECT
        order_id,
        ROUND(total_price, 2) as order_total
    FROM {{ model }}
),

discrepancies AS (
    SELECT
        order_totals.order_id,
        order_totals.order_total as order_header_total,
        COALESCE(order_lines_total.lines_total, 0) as sum_of_lines,
        ABS(order_totals.order_total - COALESCE(order_lines_total.lines_total, 0)) as difference
    FROM order_totals
    LEFT JOIN order_lines_total ON order_totals.order_id = order_lines_total.order_id
    WHERE ABS(order_totals.order_total - COALESCE(order_lines_total.lines_total, 0)) > 0.01  -- Allow for small rounding differences
)

SELECT * FROM discrepancies

{% endtest %} 