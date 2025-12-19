-- 목적: 2회 이상 구매 고객 비중(재구매율) 산출
-- 입력 테이블: orders, customers
-- 핵심 정의: 고객 = customer_unique_id 기준, 기준 status = 'delivered'

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
customer_segments AS (
    SELECT
        CASE 
            WHEN order_count = 1 THEN 'single_purchase'
            ELSE 'repeat_purchase'
        END AS customer_type,
        COUNT(*) AS customer_count
    FROM customer_orders
    GROUP BY 
        CASE 
            WHEN order_count = 1 THEN 'single_purchase'
            ELSE 'repeat_purchase'
        END
)
SELECT
    customer_type,
    customer_count,
    ROUND(customer_count * 100.0 / SUM(customer_count) OVER (), 2) AS pct_of_total
FROM customer_segments
ORDER BY customer_type DESC;
