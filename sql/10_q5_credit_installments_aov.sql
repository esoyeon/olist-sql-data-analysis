-- 목적: 신용카드 평균 할부 횟수 및 결제 타입별 AOV 분석
-- 입력 테이블: orders, order_items, order_payments
-- 핵심 정의: GMV = SUM(price + freight_value), AOV = 주문별 GMV 평균, 기준 status = 'delivered'
-- 주의: 결제 타입은 주문의 주요 결제 타입(payment_sequential = 1) 기준

WITH order_gmv AS (
    SELECT
        o.order_id,
        SUM(oi.price + oi.freight_value) AS order_gmv
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
),
order_payment_main AS (
    SELECT
        o.order_id,
        op.payment_type,
        op.payment_installments
    FROM orders o
    INNER JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
      AND op.payment_sequential = 1
),
combined AS (
    SELECT
        opm.payment_type,
        opm.payment_installments,
        og.order_gmv
    FROM order_gmv og
    INNER JOIN order_payment_main opm ON og.order_id = opm.order_id
)
SELECT
    payment_type,
    COUNT(*) AS order_count,
    ROUND(AVG(order_gmv), 2) AS aov,
    ROUND(
        CASE 
            WHEN payment_type = 'credit_card' THEN AVG(payment_installments)
            ELSE NULL 
        END, 
        2
    ) AS avg_installments
FROM combined
GROUP BY payment_type
ORDER BY order_count DESC;
