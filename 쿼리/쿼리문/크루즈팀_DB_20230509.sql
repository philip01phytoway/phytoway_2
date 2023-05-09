-- 크루즈팀_DB_20230509


-- order_batch 수정사항 : prev_dead_date, next_dead_date, prev_order_date, next_order_date 컬럼 추가.
-- 기타 제품 제외한 파이토웨이 제품만 적용하였음.


-- 이탈 : 해당일이 만료일이고 다음주문이 없거나 만료일보다 큰경우 이탈
-- 이탈율 = (이탈건수 / 만료건수) x 100
-- 재구매 : 해당일이 만료일이고 다음주문이 주문일과 만료일 사이에 있는 경우 재구매
-- 재구매율 = (재구매건수 / 만료건수) x 100
-- 평균구매금액 = 구매매출 / 구매건수
-- ltv = (평균구매금액 / 이탈율) - 평균고객유지비용
-- 현재 평균고객유지비용 = 0 으로 계산.


-- 샘플 쿼리

-- 만료건수
-- 만료일자 기간 수정하여 사용
SELECT SUM(order_cnt) AS dead_cnt
FROM "order_batch"
WHERE dead_date BETWEEN '2023-03-08' AND '2023-03-14'


-- 이탈건수
-- 만료일자 기간 수정하여 사용
SELECT SUM(order_cnt) AS chunk_cnt
FROM "order_batch"
WHERE dead_date BETWEEN '2023-03-08' AND '2023-03-14' AND (next_order_date IS NULL OR next_order_date > dead_date)


-- 재구매건수
-- 만료일자 기간 수정하여 사용
SELECT SUM(order_cnt) AS reorder_cnt
FROM "order_batch"
WHERE dead_date BETWEEN '2023-03-08' AND '2023-03-14' AND (next_order_date BETWEEN order_date AND dead_date)


-- 구매매출, 구매건수, 평균구매금액
-- 주문일자 기간 수정하여 사용
SELECT SUM(prd_amount_mod) AS order_price, SUM(order_cnt) AS order_cnt, SUM(prd_amount_mod) / SUM(order_cnt) AS "avg_order_price"
FROM "order_batch"
WHERE order_date BETWEEN '2023-03-08' AND '2023-03-14'


