-- 목적: 요일별 GMV 및 주문수 패턴 분석
-- 입력 테이블: orders, order_items
-- 핵심 정의: GMV = SUM(price + freight_value), 기준 status = 'delivered'
-- 참고: strftime('%w')는 0=일요일, 1=월요일 ... 6=토요일

WITH dow_stats AS (
    SELECT
        CAST(strftime('%w', o.order_purchase_timestamp) AS INTEGER) AS dow_num,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.price + oi.freight_value) AS gmv
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY strftime('%w', o.order_purchase_timestamp)
)
SELECT
    dow_num,
    CASE dow_num
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,
    order_count,
    ROUND(gmv, 2) AS gmv,
    ROUND(gmv / order_count, 2) AS avg_order_value
FROM dow_stats
ORDER BY dow_num;
