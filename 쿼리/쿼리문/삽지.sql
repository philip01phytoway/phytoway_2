--- 삽지

-- 파이토웨이 계간지
SELECT	order_id, '계간지, 공통삽지' AS 삽지, order_date_time
from	"order3" AS o
where	order_date_time between '2023-04-11 14:00:00' AND '2023-04-12 09:00:00'
and	order_name || recv_zip 
IN (
		select	order_name || recv_zip
		from 	"order3"
		group by order_name || recv_zip
		having count(*) = 1
	)
AND product_name <> '기타'
Order BY order_date_time ASC, seq



-- 서큐시안 미니북
SELECT order_id, '미니책자' AS 삽지, order_date_time
from	"order3"
WHERE	(order_date_time between '2023-04-11 14:00:00' AND '2023-04-12 09:00:00' ) 
		and product_name = '써큐시안' 
		and order_name || recv_zip 
in (
		select	order_name || recv_zip
		from 	"order3"
		where	product_name = '써큐시안'
		group by order_name || recv_zip
		having count(*) = 1
	)
Order BY order_date_time ASC, seq



-- 2023-04-26 삽지 재구매율 분석


-- 실험군_1개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 60)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 1 
								AND order_date BETWEEN '2022-04-02' AND '2022-06-07'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'





-- 실험군_3개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 180)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 3
								AND order_date BETWEEN '2022-04-02' AND '2022-06-07'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'




-- 대조군1_1개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 60)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 1
								AND order_date BETWEEN '2022-02-01' AND '2022-03-31'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'



-- 대조군1_3개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 180)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 3
								AND order_date BETWEEN '2022-02-01' AND '2022-03-31'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'




-- 대조군2_1개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 60)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 1
								AND order_date BETWEEN '2022-07-01' AND '2022-08-31'		
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'




-- 대조군2_3개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 180)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 3
								AND order_date BETWEEN '2022-07-01' AND '2022-08-31'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'


