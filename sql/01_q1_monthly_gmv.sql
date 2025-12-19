-- 목적: 월별 GMV 추이 및 MoM(전월 대비) 성장률 산출
-- 입력 테이블: orders, order_items
-- 핵심 정의: GMV = SUM(price + freight_value), 기준 status = 'delivered'

WITH monthly_gmv AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS year_month,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.price + oi.freight_value) AS gmv
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
)
SELECT
    year_month,
    order_count,
    ROUND(gmv, 2) AS gmv,
    ROUND(
        (gmv - LAG(gmv) OVER (ORDER BY year_month)) 
        / LAG(gmv) OVER (ORDER BY year_month) * 100, 
        2
    ) AS mom_growth_pct
FROM monthly_gmv
ORDER BY year_month;
