-- 목적: 재구매 고객 vs 단일 구매 고객의 AOV 차이 분석
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
customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT og.order_id) AS order_count
    FROM order_gmv og
    INNER JOIN customers c ON og.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),
order_with_type AS (
    SELECT
        og.order_id,
        og.order_gmv,
        CASE 
            WHEN co.order_count = 1 THEN 'single_purchase'
            ELSE 'repeat_purchase'
        END AS customer_type
    FROM order_gmv og
    INNER JOIN customers c ON og.customer_id = c.customer_id
    INNER JOIN customer_orders co ON c.customer_unique_id = co.customer_unique_id
)
SELECT
    customer_type,
    COUNT(*) AS order_count,
    ROUND(AVG(order_gmv), 2) AS aov,
    ROUND(SUM(order_gmv), 2) AS total_gmv
FROM order_with_type
GROUP BY customer_type
ORDER BY customer_type DESC;
