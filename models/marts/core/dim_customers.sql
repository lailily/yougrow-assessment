WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('int_orders') }}
),

first_purchase_attributes AS (
    SELECT
        orders.customer_id,
        DATEDIFF('day', customers.created_at, orders.created_at) as days_from_registration_to_first_purchase,
        orders.total_revenue as first_purchase_value,
        orders.total_profit as first_purchase_profit,
        orders.basket_size as first_purchase_basket_size,
        CASE WHEN orders.is_refunded THEN 1 ELSE 0 END as is_first_purchase_refunded
    FROM orders
    INNER JOIN customers
    ON orders.customer_id = customers.customer_id
    QUALIFY ROW_NUMBER() OVER (PARTITION BY orders.customer_id ORDER BY orders.created_at) = 1
),

all_purchases AS (
    SELECT
        customers.customer_id,
        customers.name,
        customers.email,
        customers.state,
        customers.country,
        customers.gender,
        customers.created_at,
        COUNT(DISTINCT CASE WHEN orders.is_refunded = FALSE THEN orders.order_id END) as total_completed_orders,
        COUNT(DISTINCT CASE WHEN orders.is_refunded = TRUE THEN orders.order_id END) as total_refunded_orders,
        SUM(CASE WHEN orders.is_refunded = FALSE THEN orders.total_revenue END) as total_sales,
        SUM(CASE WHEN orders.is_refunded = TRUE THEN orders.total_revenue END) as total_refunds,
        SUM(CASE WHEN orders.is_refunded = FALSE THEN orders.total_profit END) as total_profit,
        SUM(CASE WHEN orders.is_refunded = FALSE THEN orders.basket_size END) as total_items_purchased,
        AVG(CASE WHEN orders.is_refunded = FALSE THEN orders.basket_size END) as avg_items_per_order
    FROM customers
    LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
    GROUP BY ALL
),

final AS (
    SELECT
        all_purchases.*,
        first_purchase_attributes.days_from_registration_to_first_purchase,
        first_purchase_attributes.first_purchase_value,
        first_purchase_attributes.first_purchase_profit,
        first_purchase_attributes.first_purchase_basket_size,
        first_purchase_attributes.is_first_purchase_refunded
    FROM all_purchases
    LEFT JOIN first_purchase_attributes
    ON all_purchases.customer_id = first_purchase_attributes.customer_id
)

SELECT * FROM final