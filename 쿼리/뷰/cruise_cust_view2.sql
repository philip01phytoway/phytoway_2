
-- 2023-05-17 버전 2 작성

-- cruise_cust_view2

SELECT order_date, brand, KEY
FROM "order_batch" 
WHERE all_cust_type = '신규' AND brand = '써큐시안'

UNION ALL 

SELECT order_date, brand, key
FROM "order_batch"
WHERE order_id <> '' AND phytoway = 'y' 
AND KEY IN (
		
	SELECT key
	FROM "order_batch" 
	WHERE all_cust_type = '신규' AND nick = '써큐시안'
)
AND brand = '판토모나'

UNION ALL 

SELECT order_date, nick, key
FROM "order_batch"
WHERE order_id <> '' AND phytoway = 'y' 
AND KEY IN (
		
	SELECT key
	FROM "order_batch" 
	WHERE all_cust_type = '신규' AND nick = '써큐시안'
)
AND nick = '판토모나하이퍼포머'

UNION ALL 

SELECT order_date, nick, o.key
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

SELECT order_date, nick, o.KEY
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




-- 지표까지 보는 전체 쿼리문.
SELECT brand, MAX(order_date) AS order_date, count(distinct KEY) AS cnt
FROM 	(

			SELECT order_date, brand, key
			FROM "order_batch" 
			WHERE all_cust_type = '신규' AND brand = '써큐시안'

			UNION ALL 

			SELECT order_date, brand, key
			FROM "order_batch"
			WHERE order_id <> '' AND phytoway = 'y' 
			AND KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND brand = '판토모나'
			
			UNION ALL 
			
			SELECT order_date, nick, key
			FROM "order_batch"
			WHERE order_id <> '' AND phytoway = 'y' 
			AND KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND nick = '판토모나하이퍼포머'

			UNION ALL 
			
			SELECT order_date, nick, o.key
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
			
			SELECT order_date, nick, o.KEY
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

--WHERE order_date <= '2023-05-01'
GROUP BY brand
