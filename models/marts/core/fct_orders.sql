WITH order_lines AS (
    SELECT
        order_id,
        SUM(quantity) as total_items,
        SUM(total_price) as order_value
    FROM {{ ref('stg_order_line') }}
    GROUP BY order_id
),

orders AS (
    SELECT *
    FROM {{ ref('stg_order') }}
),

renamed AS (
    SELECT
        id as order_id,
        customer_id,
        created_at,
        currency,
        refunded_at,
    FROM orders
)

SELECT
    orders.order_id,
    orders.customer_id,
    orders.created_at,
    orders.currency,
    order_lines.order_value,
    order_lines.total_items,
    CASE 
        WHEN orders.refunded_at IS NOT NULL THEN true 
        ELSE false 
    END as is_refunded,
    -- Calculate metrics per order
    COALESCE(order_lines.order_value, 0) / NULLIF(order_lines.total_items, 0) as avg_item_value,
    order_lines.total_items as basket_size
FROM orders
INNER JOIN order_lines ON orders.order_id = order_lines.order_id 