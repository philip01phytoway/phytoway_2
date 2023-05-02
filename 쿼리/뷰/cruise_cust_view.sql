-- cruise_cust_view
-- 써큐시안 첫구매 후 판토모나 교차구매 고객

SELECT MAX(order_date) AS "누적기준일", '써큐시안' as brand, count(distinct KEY) AS "누적고객수"
FROM "order_batch" 
WHERE all_cust_type = '신규' AND nick = '써큐시안'

UNION ALL 

SELECT  order_date AS "누적기준일", brand, cnt
FROM 	(
			SELECT MAX(order_date) AS order_date, '판토모나' AS brand, COUNT(DISTINCT KEY) AS cnt
			FROM "order_batch"
			WHERE order_id <> '' AND phytoway = 'y' 
			AND KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND brand = '판토모나'
			
			UNION ALL 
			
			SELECT MAX(order_date) AS order_date, '판토모나하이퍼포머' AS nick, COUNT(DISTINCT KEY) AS cnt
			FROM "order_batch"
			WHERE order_id <> '' AND phytoway = 'y' 
			AND KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND nick = '판토모나하이퍼포머'
			
			UNION ALL 
			
			SELECT MAX(order_date) AS order_date, '판토모나맨' AS nick, COUNT(DISTINCT o.KEY) AS cnt
			FROM "order_batch" AS o
			LEFT JOIN (
				SELECT DISTINCT KEY
				FROM "order_batch"
				WHERE nick = '판토모나하이퍼포머'
			) AS p ON (o.key = p.key)
			WHERE order_id <> '' AND phytoway = 'y' 
			AND p.key IS NULL
			AND o.KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND nick = '판토모나맨'
			
			UNION ALL 
			
			SELECT MAX(order_date) AS order_date, '판토모나레이디' AS nick, COUNT(DISTINCT o.KEY) AS cnt
			FROM "order_batch" AS o
			LEFT JOIN (
				SELECT DISTINCT KEY
				FROM "order_batch"
				WHERE nick = '판토모나하이퍼포머' OR nick = '판토모나맨'
			) AS p ON (o.key = p.key)
			WHERE order_id <> '' AND phytoway = 'y' 
			AND p.key IS NULL
			AND o.KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND nick = '판토모나레이디' 
		) AS t
