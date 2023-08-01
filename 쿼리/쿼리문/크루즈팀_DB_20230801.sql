--2023-08-01

-- 재구매 = 만료일이 아니라, 주문일 기준으로, 2회차 이상 구매한 경우. 즉 all_cust_type = '재구매'인 경우.


-- 주차별 재구매 건수 및 매출
-- 전체 매출 대비 재구매 매출 비중 확인 필요


-- 1. 주차별 전체 건수, 전체 매출 쿼리 실행하여 붙여넣고 (B2C, B2B 포함)
-- 2. 주차별 재구매 건수, 재구매 매출 쿼리 실행하여 붙여넣고
-- 3. 주차별 매출 비중을 구글 시트로 계산


-- (고객 : 전체, 상품 : 전체, 스토어 : 전체, 수량 : 전체)
SELECT yyww, SUM(prd_amount_mod) AS "주문매출", SUM(order_cnt) AS "주문건수"
FROM "order_batch"
WHERE phytoway = 'y' 
GROUP BY yyww
Order BY yyww desc


-- (고객 : 재구매, 상품 : 전체, 스토어 : 전체, 수량 : 전체)
SELECT yyww, SUM(prd_amount_mod) AS "주문매출", SUM(order_cnt) AS "주문건수"
FROM "order_batch"
WHERE phytoway = 'y' AND order_id <> '' AND all_cust_type = '재구매'
GROUP BY yyww
Order BY yyww desc




-- (고객 : 전체, 상품 : 상품별, 스토어 : 전체, 수량 : 전체)
SELECT yyww, nick, SUM(prd_amount_mod) AS "주문매출", SUM(order_cnt) AS "주문건수"
FROM "order_batch"
WHERE phytoway = 'y' 
GROUP BY yyww, nick
Order BY yyww DESC, nick


-- (고객 : 재구매, 상품 : 상품별, 스토어 : 전체, 수량 : 전체)
SELECT yyww, nick, SUM(prd_amount_mod) AS "주문매출", SUM(order_cnt) AS "주문건수"
FROM "order_batch"
WHERE phytoway = 'y' AND order_id <> '' AND all_cust_type = '재구매'
GROUP BY yyww, nick
Order BY yyww DESC, nick



