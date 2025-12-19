-- 목적: 고객 수 기준 상위 주(STATE) TOP 5 조회
-- 입력 테이블: orders, customers
-- 핵심 정의: 고객 = customer_unique_id 기준, 기준 status = 'delivered'

WITH state_customers AS (
    SELECT
        c.customer_state,
        COUNT(DISTINCT c.customer_unique_id) AS customer_count,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)
SELECT
    customer_state,
    customer_count,
    order_count,
    ROUND(customer_count * 100.0 / SUM(customer_count) OVER (), 2) AS customer_pct
FROM state_customers
ORDER BY customer_count DESC
LIMIT 5;
