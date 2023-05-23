-- 크루즈팀 2023-05-23



-- NEW 지표 작업

-- 1차 작업본이기 때문에 데이터 검증 필요


WITH cruise_cust_view3 AS (
	SELECT 	*,
				MAX(cross_order_rank) over(partition BY order_id) AS cross_order_rank2,
				MAX(cross_store_cust_type) over(partition BY order_id) AS cross_store_cust_type2,
				MAX(cross_order_rank) over(partition BY order_tel) AS max_cross_order_rank
	FROM 	(
	
				SELECT 	*, 
				 			dense_rank() over(partition BY order_tel Order BY order_date_time) AS cross_order_rank,
				 			
							CASE 
								WHEN dense_rank() over(partition BY order_tel, store_mod Order BY order_date_time) = 1 THEN '신규'
								ELSE '재구매'
							END AS cross_store_cust_type
								
				FROM (
							SELECT 	*,
										CASE 
											WHEN store = '스마트스토어_풀필먼트' THEN '스마트스토어'
											ELSE store
										END AS store_mod  
							FROM "order_batch"
						) AS t
				WHERE order_status = '주문' AND order_tel <> '' AND order_tel IS NOT NULL AND order_tel NOT LIKE '050%' 
				AND order_tel NOT LIKE '%00000000%' AND order_tel NOT LIKE '%********%'
				AND order_id <> '' AND phytoway = 'y'
				
				UNION ALL 
				
				SELECT 	*, 
				 			null AS cross_order_rank, NULL AS cross_store_cust_type
				FROM (
							SELECT 	*,
										CASE 
											WHEN store = '스마트스토어_풀필먼트' THEN '스마트스토어'
											ELSE store
										END AS store_mod  
							FROM "order_batch"
						) AS t
				WHERE order_status IN ('취소', '반품') AND order_tel <> '' AND order_tel IS NOT NULL AND order_tel NOT LIKE '050%' 
				AND order_tel NOT LIKE '%00000000%' AND order_tel NOT LIKE '%********%'
				AND order_id <> '' AND phytoway = 'y'
				
			) AS t
)



-- 자사몰 잠재고객수

SELECT yyww, SUM(order_cnt) AS order_cnt
FROM "cruise_cust_view3"
WHERE store_mod = '자사몰' AND cross_store_cust_type = '신규' AND all_cust_type = '신규' AND max_cross_order_rank = 1
GROUP BY yyww
Order BY yyww DESC 



-- 네이버 잠재고객수
SELECT yyww, SUM(order_cnt) AS order_cnt
FROM "cruise_cust_view3"
WHERE store_mod = '스마트스토어' AND cross_store_cust_type = '신규' AND max_cross_order_rank = 1
GROUP BY yyww
Order BY yyww DESC 


-- 쿠팡 잠재고객수
SELECT yyww, SUM(order_cnt) AS order_cnt
FROM "cruise_cust_view3"
WHERE store_mod = '쿠팡' AND cross_store_cust_type = '신규' AND max_cross_order_rank = 1
GROUP BY yyww
Order BY yyww DESC 


-- 자사몰 재구매수
SELECT yyww, SUM(order_cnt) AS order_cnt
FROM "cruise_cust_view3"
WHERE max_cross_order_rank = 2 AND store_mod = '자사몰'
GROUP BY yyww
Order BY yyww DESC 


-- 네이버 재구매수
SELECT yyww, SUM(order_cnt) AS order_cnt
FROM "cruise_cust_view3"
WHERE max_cross_order_rank = 2 AND store_mod = '스마트스토어'
GROUP BY yyww
Order BY yyww DESC 

-- 쿠팡 재구매수
SELECT yyww, SUM(order_cnt) AS order_cnt
FROM "cruise_cust_view3"
WHERE max_cross_order_rank = 2 AND store_mod = '쿠팡'
GROUP BY yyww
Order BY yyww DESC 


			
			
