-- 목적: 카테고리별 AOV 및 배송비 비중(Freight Ratio) 분석
-- 입력 테이블: orders, order_items, products
-- 핵심 정의: GMV = SUM(price + freight_value), Freight Ratio = freight / gmv, 기준 status = 'delivered'
-- 참고: AOV는 (주문 × 카테고리) 조합 단위로 계산됨. 동일 주문 내 여러 카테고리 상품이 있을 경우 각각 별도 집계.

WITH order_category AS (
    SELECT
        o.order_id,
        COALESCE(p.product_category_name, 'unknown') AS category,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight,
        SUM(oi.price + oi.freight_value) AS order_gmv
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id, COALESCE(p.product_category_name, 'unknown')
),
category_stats AS (
    SELECT
        category,
        COUNT(*) AS order_count,
        SUM(order_gmv) AS total_gmv,
        SUM(total_freight) AS total_freight,
        AVG(order_gmv) AS aov
    FROM order_category
    GROUP BY category
)
SELECT
    category,
    order_count,
    ROUND(total_gmv, 2) AS total_gmv,
    ROUND(aov, 2) AS aov,
    ROUND(total_freight, 2) AS total_freight,
    ROUND(total_freight * 100.0 / total_gmv, 2) AS freight_ratio_pct
FROM category_stats
ORDER BY total_gmv DESC
LIMIT 10;
