WITH order_lines AS (
    SELECT *
    FROM {{ ref('stg_order_lines') }}
),

products AS (
    SELECT *
    FROM {{ ref('stg_products') }}
),

orders AS (
    SELECT *
    FROM {{ ref('stg_orders') }}
),

agg_order_lines AS (
    SELECT
        order_id,
        SUM(quantity) as basket_size,
        ROUND(CAST(SUM(profit*quantity) AS numeric), 2) as total_profit
    FROM order_lines
    INNER JOIN products ON order_lines.product_id = products.product_id
    GROUP BY order_id
),

joined AS (
    SELECT
        orders.order_id,
        orders.customer_id,
        orders.created_at,
        DATE_TRUNC('month', orders.created_at) as order_month,
        orders.currency,
        orders.total_price AS total_revenue,
        agg_order_lines.total_profit,
        agg_order_lines.basket_size,
        orders.is_refunded,
        orders.refunded_at
    FROM orders
    INNER JOIN agg_order_lines ON orders.order_id = agg_order_lines.order_id
)

SELECT * FROM joined




