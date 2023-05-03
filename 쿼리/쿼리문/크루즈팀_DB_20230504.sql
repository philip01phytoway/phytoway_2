-- 크루즈팀_DB_20230504


-- order_batch 수정사항 : dead_date 컬럼 추가.
-- 만료일 : 주문일에 (옵션수량 * 주문수량 * 복용일 * 1.2)(최대 365일) 더한 일자.



-- 판토모나 db
-- 활동구간 일자 수정하여 사용
SELECT * 
FROM "order_batch" 
WHERE brand = '판토모나' AND dead_date BETWEEN '2022-03-17' AND '2023-06-10'  
Order BY order_date ASC


-- 만료고객 db
-- 만료구간 일자 수정하여 사용
SELECT * 
FROM "order_batch" 
WHERE dead_date BETWEEN '2023-04-12' AND '2023-05-10' 
Order BY order_date ASC


-- 추후 전달 쿼리 : ltv, 평균구매금액 등