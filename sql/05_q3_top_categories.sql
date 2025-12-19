-- 목적: 매출 상위 카테고리 TOP 10 조회
-- 입력 테이블: orders, order_items, products
-- 핵심 정의: GMV = SUM(price + freight_value), 기준 status = 'delivered'

WITH category_gmv AS (
    SELECT
        COALESCE(p.product_category_name, 'unknown') AS category,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(*) AS item_count,
        SUM(oi.price + oi.freight_value) AS gmv
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY COALESCE(p.product_category_name, 'unknown')
)
SELECT
    category,
    order_count,
    item_count,
    ROUND(gmv, 2) AS gmv,
    ROUND(gmv * 100.0 / SUM(gmv) OVER (), 2) AS gmv_pct
FROM category_gmv
ORDER BY gmv DESC
LIMIT 10;
