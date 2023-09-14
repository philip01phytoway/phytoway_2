

SELECT order_date, store, brand, nick,
			
			COUNT(DISTINCT KEY) AS cust_cnt,
			
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '신규' THEN key
				END) AS new_cust_cnt,
				
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '재구매' THEN key
				END) AS re_cust_cnt,
			
			SUM(prd_amount_mod) AS price,
			
			SUM(CASE 
					WHEN all_cust_type = '신규' THEN prd_amount_mod
					ELSE 0
				END) new_price,
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN prd_amount_mod
					ELSE 0
				END) AS re_price
				
FROM "order_batch"
WHERE phytoway = 'y' AND store NOT IN ('스마트스토어', '스마트스토어_풀필먼트', '쿠팡', '쿠팡2', '쿠팡_로켓배송', '쿠팡_제트배송', '자사몰')
AND order_date between '2023-09-01' AND '2023-09-07'
GROUP BY order_date, store, brand, nick
Order BY order_date DESC, store








-- 기타 채널 매출 쿼리
SELECT order_date, store, brand, nick,
			
			COUNT(DISTINCT KEY) AS cust_cnt,
			
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '신규' THEN key
				END) AS new_cust_cnt,
				
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '재구매' THEN key
				END) AS re_cust_cnt,
			
			SUM(prd_amount_mod) AS price,
			
			SUM(CASE 
					WHEN all_cust_type = '신규' THEN prd_amount_mod
					ELSE 0
				END) new_price,
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN prd_amount_mod
					ELSE 0
				END) AS re_price
				
FROM "order_batch"
WHERE phytoway = 'y' AND store NOT IN ('스마트스토어', '스마트스토어2', '스마트스토어3', '스마트스토어_풀필먼트', '쿠팡', '쿠팡2', '쿠팡_로켓배송', '쿠팡_제트배송', '자사몰',
'11번가_슈팅배송', '메디크로스랩', '온유약국', '마켓컬리')
AND yymm >= '2023-01' AND prd_amount_mod < 500000
GROUP BY order_date, store, brand, nick
Order BY order_date DESC, store



-- B2B 매출 쿼리
SELECT order_date, store, brand, nick, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y' AND store IN ('11번가_슈팅배송', '메디크로스랩', '온유약국', '마켓컬리')
AND yymm >= '2023-01'
GROUP BY order_date, store, brand, nick
Order BY order_date DESC



-- 리셀러 매출 쿼리
SELECT order_date, store, brand, nick, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y' AND store NOT IN ('스마트스토어', '스마트스토어2', '스마트스토어3', '스마트스토어_풀필먼트', '쿠팡', '쿠팡2', '쿠팡_로켓배송', '쿠팡_제트배송', '자사몰',
'11번가_슈팅배송', '메디크로스랩', '온유약국', '마켓컬리')
AND yymm >= '2023-01' AND prd_amount_mod >= 500000
GROUP BY order_date, store, brand, nick
Order BY order_date DESC




-- 월별, 주별 매출 실적 - b2c
SELECT yymm, yyww, store,
			
			SUM(order_cnt) AS order_cnt,
			
			SUM(CASE 
					WHEN all_cust_type = '신규' THEN order_cnt
					ELSE 0
				END) AS "new_order_cnt",
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN order_cnt
					ELSE 0
				END) AS "re_order_cnt",
			
			SUM(prd_amount_mod) AS price,
			
			SUM(CASE 
					WHEN all_cust_type = '신규' THEN prd_amount_mod
					ELSE 0
				END) new_price,
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN prd_amount_mod
					ELSE 0
				END) AS re_price
				
FROM "order_batch"
WHERE phytoway = 'y' AND store NOT IN ('스마트스토어', '스마트스토어2', '스마트스토어3', '스마트스토어_풀필먼트', '쿠팡', '쿠팡2', '쿠팡_로켓배송', '쿠팡_제트배송', '자사몰',
'11번가_슈팅배송', '메디크로스랩', '온유약국', '마켓컬리')
AND yymm >= '2022-01' --AND prd_amount_mod < 500000
GROUP BY yymm, yyww, store
Order BY yyww DESC, store





-- 월별, 주별 매출 실적 - b2b
SELECT yymm, yyww, store, SUM(order_cnt) AS order_cnt, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y' AND store IN ('11번가_슈팅배송', '메디크로스랩', '온유약국', '마켓컬리')
AND yymm >= '2022-01'
GROUP BY yymm, yyww, store
Order BY yymm, yyww DESC



SELECT store, SUM(prd_amount_mod)
FROM "order_batch"
WHERE yymm = '2023-09' AND phytoway = 'y' AND store NOT IN ('스마트스토어', '스마트스토어2', '스마트스토어3', '스마트스토어_풀필먼트', '쿠팡', '쿠팡2', '쿠팡_로켓배송', '쿠팡_제트배송', '자사몰')
GROUP BY store



