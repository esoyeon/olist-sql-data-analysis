-- 목적: 지역별(주) AOV 분석
-- 입력 테이블: orders, order_items, customers
-- 핵심 정의: GMV = SUM(price + freight_value), AOV = 주문별 GMV 평균, 기준 status = 'delivered'

WITH order_gmv AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.price + oi.freight_value) AS order_gmv
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id, o.customer_id
),
state_orders AS (
    SELECT
        c.customer_state,
        og.order_id,
        og.order_gmv
    FROM order_gmv og
    INNER JOIN customers c ON og.customer_id = c.customer_id
)
SELECT
    customer_state,
    COUNT(*) AS order_count,
    ROUND(SUM(order_gmv), 2) AS total_gmv,
    ROUND(AVG(order_gmv), 2) AS aov
FROM state_orders
GROUP BY customer_state
ORDER BY total_gmv DESC;
