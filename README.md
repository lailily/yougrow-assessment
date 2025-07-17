# YouGrowth - Analytics Engineer Assessment

## Question 1:
To help Beth track her key metrics—Gross Merchandise Value (GMV), Average Order Value, Average Basket Size, and Active Customers—I've created a central model called `fct_monthly_kpis`. This model aggregates these KPIs on a monthly basis, making it easy for Beth to monitor YouGrow’s performance over time.

Here’s how each metric is defined:
- Gross Merchandise Value (GMV): Total monthly revenue from all orders, including refunds
- Average Order Value: Average revenue per order in the month, including refunds
- Active Customers: Number of customers who placed an order during the month (including refunds)

Here’s a simple query you can use to view these monthly KPIs:
```
SELECT *
FROM {{ref('fct_monthly_kpis')}}
ORDER BY order_month
```

The result can be found below:
Order Month | GMV | Basket Size | Order Value | Active Customers
--- | --- | --- | --- | ---
2021-01-01 | $171.38 | 2.00 | $57.13 | 3
2021-02-01 | $424.23 | 2.25 | $106.06 | 4
2021-03-01 | $696.25 | 3.14 | $99.46 | 7

## Question 2:
To track Customer Lifetime Value and Retention Rate, I’ve built a model called `fct_customer_monthly_cohort`. This table records each customer’s activity for every month since they joined, and includes the following key columns:

- `cohort_month`: The month the customer first joined (their cohort)
- `activity_month`: The month for which the metrics are calculated
- `months_since_cohort`: Number of months since the customer joined
- `is_active`: Whether the customer placed an order in that month
- `was_active_last_month`: Whether the customer was active in the previous month
- `cumulative_active_months`: Number of months the customer has been active so far (up to and including the current month)
- `total_orders`: Number of orders placed by the customer in that month (including refunds)
- `total_revenue`: Total revenue from the customer in that month (excluding refunds)
- `avg_order_value`: Average order value for the customer in that month
- `avg_basket_size`: Average number of items per order for the customer in that month

In Looker, we can set up two main views:
- The `fct_customer_monthly_cohort` view includes:
  - All cohort and activity dimensions for each customer and month
  - Key measures such as:
    - Retention rate: calculated as the sum of all `is_active` customers in a cohort divided by the total number of customers in that cohort
    - Customer Lifetime Value (CLV), defined as:
      - average purchase value (excluding refunds): average `total_revenue`
      - × purchase frequency◊ (total orders divided by total customers, including refunds): `total_orders` / total customers in cohort 
      - × average customer lifespan (average cumulative active months): `cumulative_active_months`
- The `dim_customers` view, which provides additional customer attributes for slicing and filtering.

With these views, Beth can easily track retention and CLV by cohort each month, and also break down the results by any of the main customer dimensions from `dim_customers`, such as name, email, state, country, gender, and signup date as well as first purchase attributes such as first purchase value, first purchase basket size

(If we don’t want to use Looker, we can also define these measures in a semantic layer and use them in another tool, such as Tableau.)

The result for a basic segmentation by cohort month can be found below
Cohort Month | Activity Month | Months Since Cohort | Total Customers in Cohort | Active Customers | Retention Rate | Avg Purchase Value | Purchase Frequency | Avg Customer Lifespan | CLV
--- | --- | --- | --- | --- | --- | --- | --- | --- | ---
2021-01-01 | 2021-01-01 | 0 | 3 | 3 | 100.0% | $57.13 | 1.00 | 1.00 | $57.13
2021-01-01 | 2021-02-01 | 1 | 3 | 1 | 33.3% | $104.22 | 0.33 | 1.33 | $46.32
2021-01-01 | 2021-03-01 | 2 | 3 | 1 | 33.3% | $134.60 | 0.33 | 1.67 | $74.78
2021-02-01 | 2021-02-01 | 0 | 3 | 3 | 100.0% | $73.33 | 1.00 | 1.00 | $73.33
2021-02-01 | 2021-03-01 | 1 | 3 | 2 | 66.7% | $40.68 | 0.67 | 1.67 | $45.20
2021-03-01 | 2021-03-01 | 0 | 4 | 4 | 100.0% | $79.81 | 1.00 | 1.00 | $79.81

## Question 3:
With the introduction of a subscription model, we should first create a new staging model to handle subscription-specific data, including:
- subscription id
- customer id
- subscription price
- start and end dates

For updates to existing models:
- In `fct_monthly_kpis`, we should add:
    - Number of active subscribers
    - Subscription revenue (MRR)
    - For existing metrics, ensure they only reflect non-subscription components.
- In `fct_customer_monthly_cohort`, we should include:
    - Indicator for whether the customer’s membership is active in a given month
    - Indicator for whether the customer churned that month
    - Current plan and plan price for each month
- In `dim_customers`, we should add:
    - Flag to indicate if the customer has a subscription
    - Current subscription plan
    - Count of different subscription plans
    - Subscription start date

With these changes, we’ll be able to:
- Segment between subscription and non-subscription users
- Track subscription rate and churn rate (and segment by different properties)
- Identify customer segments Beth should focus on
- Measure subscription retention rate