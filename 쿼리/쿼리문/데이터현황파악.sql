-- 데이터 현황파악


-- 쿼리문 추출과 함께 기초적인 기술통계를 하면 좋겠다.
-- 단지 표만 봐서는 뭐가 어떤지를 모르니까.

-- 매출 현황
-- 일자별
SELECT yymm, yyww, order_date, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date
Order BY order_date DESC
LIMIT 1000


-- 월별 sum.
-- 월 목표도 있으니까.

-- 일자, 브랜드별
SELECT yymm, yyww, order_date, brand, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date, brand
Order BY order_date DESC, price desc
LIMIT 1000


-- 일자, 상품별

-- 일자, 스토어별

-- 신규고객수, 신규매출, 재구매고객수, 재구매매출




-- 네이버 광고

