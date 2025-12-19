-- 목적: 결제 타입별 주문수 및 결제금액 비중 분석
-- 입력 테이블: orders, order_payments
-- 핵심 정의: 기준 status = 'delivered'
-- 주의: 동일 주문에 여러 결제 수단이 사용될 수 있음. 주문 단위로 주요 결제 타입을 결정.
--       여기서는 결제 순번이 1인 레코드(payment_sequential = 1)를 주요 결제 타입으로 간주.

WITH order_payment AS (
    SELECT
        o.order_id,
        op.payment_type,
        op.payment_value
    FROM orders o
    INNER JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
      AND op.payment_sequential = 1
)
SELECT
    payment_type,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS order_pct,
    ROUND(SUM(payment_value), 2) AS total_payment,
    ROUND(SUM(payment_value) * 100.0 / SUM(SUM(payment_value)) OVER (), 2) AS payment_pct
FROM order_payment
GROUP BY payment_type
ORDER BY order_count DESC;
