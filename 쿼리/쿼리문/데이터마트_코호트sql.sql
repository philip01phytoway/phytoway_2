


-- 코호트 첫구매 재구매 (전체)
WITH first_purchase AS (
  	SELECT 	key, MIN(order_date) AS cohort_day
  	FROM 	customer_zip2
	where	order_date between '2021-10-01' and '2022-12-31'
  	GROUP BY key
)
SELECT '전체' as product2, to_char(cohort_group, 'YYYY-MM') as cohort_group, cohort_index, COUNT(DISTINCT key) AS customer_count
FROM (
  		SELECT 	m.*, f.cohort_day,
				(DATE_PART('year', order_date::date) - DATE_PART('year', cohort_day::date)) * 12 + (DATE_PART('month', order_date::date) - DATE_PART('month', cohort_day::date)) AS cohort_index,
				DATE_TRUNC('month', cohort_day::date) AS cohort_group
  		FROM 	customer_zip2 m 
		LEFT JOIN first_purchase f ON m.key = f.key
		where	order_date between '2021-10-01' and '2022-12-31'
) as t
GROUP BY cohort_group, cohort_index



-- 코호트 첫구매 재구매 (상품별)
WITH first_purchase AS (
  	SELECT 	key, product, MIN(order_date) AS cohort_day
  	FROM 	customer_zip2
	where	order_date between '2021-10-01' and '2022-12-31'
  	GROUP BY key, product
)

SELECT product, to_char(cohort_group, 'YYYY-MM') as cohort_group, cohort_index, COUNT(DISTINCT key) AS customer_count
FROM (
  		SELECT 	m.*, f.cohort_day,
					(DATE_PART('year', order_date::date) - DATE_PART('year', cohort_day::date)) * 12 +
					(DATE_PART('month', order_date::date) - DATE_PART('month', cohort_day::date)) AS cohort_index,
					DATE_TRUNC('month', cohort_day::date) AS cohort_group
  		FROM 	customer_zip2 m 
		LEFT JOIN first_purchase f ON m.key = f.key and m.product = f.product
		where	order_date between '2021-10-01' and '2022-12-31'
) as t
GROUP BY product, cohort_group, cohort_index


-- 코호트 첫구매 재구매 (상품+구성별)
WITH first_purchase AS (
  	SELECT 	key, product || '_' || (product_qty * order_qty)::varchar(50) as product, MIN(order_date) AS cohort_day
  	FROM 	customer_zip2
	where	order_date between '2021-10-01' and '2022-12-31'
  	GROUP BY key, product || '_' || (product_qty * order_qty)::varchar(50)
)
SELECT 	product2, to_char(cohort_group, 'YYYY-MM') as cohort_group, cohort_index, COUNT(DISTINCT key) AS customer_count
FROM (
  		SELECT 	m.*, f.product as product2, f.cohort_day,
				(DATE_PART('year', order_date::date) - DATE_PART('year', cohort_day::date)) * 12 +
					(DATE_PART('month', order_date::date) - DATE_PART('month', cohort_day::date)) AS cohort_index,
				DATE_TRUNC('month', cohort_day::date) AS cohort_group
  		FROM 	customer_zip2 m 
		LEFT JOIN first_purchase f ON m.key = f.key and m.product || '_' || (m.product_qty * m.order_qty)::varchar(50) = f.product
		where	order_date between '2021-10-01' and '2022-12-31'
) as t
GROUP BY product2, cohort_group, cohort_index




-- 제이미님 요청 : 판토모나레이디 첫구매고객
SELECT *
FROM 	(
			select	KEY, product, shop, tel, order_date,														
						rank() over(partition BY KEY, Product, shop order by key ASC, order_date asc) as rank,
						first_value(order_date) over(partition BY KEY, Product, shop order by key ASC, order_date asc) as first_date												
			from "customer_zip3"		
		) AS t
WHERE first_date >= '2022-10-01' AND first_date <= '2022-12-31'
and Product = '판토모나레이디' AND (shop = '스마트스토어' OR shop = '쿠팡')
Order BY KEY, rank








-- 월 코호트
-- 선택박스 : 상품, 수량
-- first_date, fist_product, first_qty
-- 수량은 1, 3, 6, 기타, 전체
-- 상품은 상품명, 브랜드명, 전체
-- 수량 1, 3, 기타, 전체로 통일 (ver2)

--(전체, 전체)
SELECT cohort_group, cohort_index, '전체' AS Product, '전체' AS qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *,
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, 
									first_value(order_date) over(partition BY KEY Order BY seq) AS first_date
						FROM 	customer_zip3
					) AS t1
		) AS t2
GROUP BY cohort_group, cohort_index
		
UNION ALL 

-- (상품별, 전체)
SELECT cohort_group, cohort_index, Product, '전체' AS qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *,
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, Product,
									first_value(order_date) over(partition BY KEY Order BY seq) AS first_date
						FROM 	customer_zip3
					) AS t1
		) AS t2
GROUP BY cohort_group, cohort_index, product

UNION ALL 

-- (전체, 수량별)
SELECT cohort_group, cohort_index, '전체' AS Product, qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *, 
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, qty,
									first_value(order_date) over(partition BY KEY Order BY seq) AS first_date
						FROM 	(
									SELECT *,
												CASE WHEN product_qty * order_qty = 1 THEN '1'
												WHEN product_qty * order_qty = 3 THEN '3'
												--WHEN product_qty * order_qty = 6 THEN '6'
												ELSE '기타'
												END AS qty
									FROM 	customer_zip3			
								) AS t1
					) AS t2
		) AS t3
GROUP BY cohort_group, cohort_index, qty

UNION ALL 

-- (상품별, 수량별)
SELECT cohort_group, cohort_index, Product, qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *, 
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, Product, qty,
									first_value(order_date) over(partition BY KEY Order BY seq) AS first_date
						FROM 	(
									SELECT *,
												CASE WHEN product_qty * order_qty = 1 THEN '1'
												WHEN product_qty * order_qty = 3 THEN '3'
												--WHEN product_qty * order_qty = 6 THEN '6'
												ELSE '기타'
												END AS qty
									FROM 	customer_zip3			
								) AS t1
					) AS t2
		) AS t3
GROUP BY cohort_group, cohort_index, Product, qty

UNION ALL 

-- (브랜드별, 전체)
SELECT cohort_group, cohort_index, brand, '전체' AS qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *,
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, brand,
									first_value(order_date) over(partition BY KEY Order BY seq) AS first_date
						FROM 	customer_zip3
					) AS t1
		) AS t2
GROUP BY cohort_group, cohort_index, brand
HAVING brand = '판토모나' OR brand = '페미론큐'

UNION ALL 	

-- (브랜드별, 수량별)
SELECT cohort_group, cohort_index, brand, qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *, 
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, brand, qty,
									first_value(order_date) over(partition BY KEY Order BY seq) AS first_date
						FROM 	(
									SELECT *,
												CASE WHEN product_qty * order_qty = 1 THEN '1'
												WHEN product_qty * order_qty = 3 THEN '3'
												--WHEN product_qty * order_qty = 6 THEN '6'
												ELSE '기타'
												END AS qty
									FROM 	customer_zip3			
								) AS t1
					) AS t2
		) AS t3
GROUP BY cohort_group, cohort_index, brand, qty
HAVING brand = '판토모나' OR brand = '페미론큐'






-- 상품 코호트
-- 선택박스 : 기간, 스토어
-- 스토어는 스토어명, 전체
-- 신규구매는 제외해야 함


-- (전체, 전체)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_product, Product, '전체' AS 재구매월, '전체' as store, COUNT(DISTINCT key)
FROM 	(
			SELECT 	*,
						first_value(product) over(partition BY KEY Order BY seq) AS first_product,
						rank() over (partition BY KEY Order BY seq) AS rank
			FROM "reorder_zip"
		) AS t
WHERE rank > 1
GROUP BY first_product, Product




-- (기간별, 전체)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_product, Product, order_month, '전체' as store, COUNT(DISTINCT key)
FROM 	(
			SELECT 	*,
						first_value(product) over(partition BY KEY Order BY seq) AS first_product,
						rank() over (partition BY KEY Order BY seq) AS rank,
						SUBSTRING(order_date, 1, 7) AS order_month 
			FROM "reorder_zip"
		) AS t
WHERE rank > 1
GROUP BY first_product, Product, order_month


-- (전체, 스토어별)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_product, Product, '전체' AS 재구매월, shop as store, COUNT(DISTINCT key)
FROM 	(
			SELECT 	*,
						first_value(product) over(partition BY KEY Order BY seq) AS first_product,
						rank() over (partition BY KEY Order BY seq) AS rank
			FROM "reorder_zip"
		) AS t
WHERE rank > 1
GROUP BY first_product, Product, shop




-- (기간별, 스토어별)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_product, Product, order_month, shop as store, COUNT(DISTINCT key)
FROM 	(
			SELECT 	*,
						first_value(product) over(partition BY KEY Order BY seq) AS first_product,
						rank() over (partition BY KEY Order BY seq) AS rank,
						SUBSTRING(order_date, 1, 7) AS order_month 
			FROM "reorder_zip"
		) AS t
WHERE rank > 1
GROUP BY first_product, Product, order_month, shop








-- 스토어별 코호트
-- 선택박스 : 기간, 상품
-- 스토어는 스토어명, 전체
-- 신규구매는 제외해야 함
		
-- (전체, 전체)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, '전체' as Product, '전체' AS 재구매월, COUNT(DISTINCT key)
FROM 	(
			SELECT 	*,
						first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
						rank() over (partition BY KEY Order BY seq) AS rank
			FROM "reorder_zip"
		) AS t
WHERE rank > 1
GROUP BY first_shop, shop



-- (기간별, 전체)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, '전체' as Product, order_month AS 재구매월, COUNT(DISTINCT key)
FROM 	(
			SELECT 	*,
						first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
						rank() over (partition BY KEY Order BY seq) AS rank,
						SUBSTRING(order_date, 1, 7) AS order_month 
			FROM "reorder_zip"
		) AS t
WHERE rank > 1
GROUP BY first_shop, shop, order_month



-- (전체, 상품별)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, Product, '전체' AS 재구매월, COUNT(DISTINCT key)
FROM 	(
			SELECT 	*,
						first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
						rank() over (partition BY KEY Order BY seq) AS rank
			FROM "reorder_zip"
		) AS t
WHERE rank > 1
GROUP BY first_shop, shop, product



-- (기간별, 상품별)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, Product, order_month AS 재구매월, COUNT(DISTINCT key)
FROM 	(
			SELECT 	*,
						first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
						rank() over (partition BY KEY Order BY seq) AS rank,
						SUBSTRING(order_date, 1, 7) AS order_month 
			FROM "reorder_zip"
		) AS t
WHERE rank > 1
GROUP BY first_shop, shop, Product, order_month





-- 첫구매 시점 추가

-- 대시보드에 첫구매 시점 선택박스를 추가했을 때,
-- 그게 가리키는 의미가 무엇인지를 우선 정의해야 함.

-- 이 기간에 첫구매한 사람들이
-- 이 기간에 재구매한 횟수는 얼마나 되는가.

-- 첫구매월과
-- 재구매월이 있으면 되겠구나.
-- 이 기간에 첫구매한 사람들이 이 기간에 재구매를 얼마나 했는지.

-- 문제는 첫구매수도 필요하다는 건데?
-- 첫구매 중에는 재구매가 없어야 하고, 재구매 중에는 첫구매가 없어야 하네.


-- 수량도 전체가 있어야 함
-- 그럼 수량 전체 대시보드와 수량별 대시보드가 따로 있어야 하나?
-- 그게 좋겠지. 순차적으로 확인할 수 있도록 탭으로 구분.

------
상품 코호트 ver2 : 첫구매 포함, 수량 전체
------

-- (첫구매월&재구매월 : 전체, 스토어 : 전체, 수량 : 전체)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)
SELECT first_product, Product, '전체' as first_month, '전체' as order_month, '전체' AS store, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(product) over(partition BY KEY Order BY seq) AS first_product,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_product, Product, reorder_status


-- (첫구매월&재구매월 : 기간별, 스토어 : 전체, 수량 : 전체)
WITH reorder_zip AS (
SELECT 	*
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_product, Product, first_month, order_month, '전체' as store, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(product) over(partition BY KEY Order BY seq) AS first_product,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_product, Product, first_month, order_month, reorder_status



-- (첫구매월&재구매월 : 전체, 스토어 : 스토어별, 수량 : 전체)
WITH reorder_zip AS (
SELECT *
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)
SELECT first_product, Product, '전체' as first_month, '전체' as order_month, shop as store, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(product) over(partition BY KEY Order BY seq) AS first_product,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_product, Product, shop, reorder_status



-- (첫구매월&재구매월 : 기간별, 스토어 : 스토어별, 수량 : 전체)
WITH reorder_zip AS (
SELECT 	*
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_product, Product, first_month, order_month, shop as store, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(product) over(partition BY KEY Order BY seq) AS first_product,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_product, Product, first_month, order_month, reorder_status, shop





---
상품_수량 코호트 : 첫구매 포함, 수량별
---

-- (첫구매월&재구매월 : 전체, 스토어 : 전체, 수랑 : 수량별)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_prd_qty, prd_qty, '전체' as first_month, '전체' as order_month, '전체' as store, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(prd_qty) over(partition BY KEY Order BY seq) AS first_prd_qty,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_prd_qty, prd_qty, reorder_status


-- (첫구매월&재구매월 : 기간별, 스토어 : 전체, 수랑 : 수량별)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_prd_qty, prd_qty, first_month, order_month, '전체' as store, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(prd_qty) over(partition BY KEY Order BY seq) AS first_prd_qty,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_prd_qty, prd_qty, first_month, order_month, reorder_status



-- (첫구매월&재구매월 : 전체, 스토어 : 스토어별, 수랑 : 수량별)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_prd_qty, prd_qty, '전체' as first_month, '전체' as order_month, shop as store, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(prd_qty) over(partition BY KEY Order BY seq) AS first_prd_qty,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_prd_qty, prd_qty, shop, reorder_status



-- (첫구매월&재구매월 : 기간별, 스토어 : 스토어별, 수랑 : 수량별)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_prd_qty, prd_qty, first_month, order_month, shop as store, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(prd_qty) over(partition BY KEY Order BY seq) AS first_prd_qty,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_prd_qty, prd_qty, first_month, order_month, shop, reorder_status



---
스토어 코호트 ver2 : 첫구매 시점, 상품_수량 추가
---

수량 : 전체도 있음




-- (첫구매월&재구매월 : 전체, 상품 : 전체)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, '전체' as first_month, '전체' as order_month, '전체' as prd_qty, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_shop, shop, reorder_status




-- (첫구매월&재구매월 : 기간별, 상품 : 전체)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, first_month, order_month, '전체' as prd_qty, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_shop, shop, first_month, order_month, reorder_status

		

-- (첫구매월&재구매월 : 전체, 상품 : 상품별)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, '전체' as first_month, '전체' as order_month, Product, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_shop, shop, product, reorder_status



-- (첫구매월&재구매월 : 기간별, 상품 : 상품별)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, first_month, order_month, Product, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_shop, shop, first_month, order_month, product, reorder_status




-- (첫구매월&재구매월 : 전체, 상품 : 상품_수량별)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, '전체' as first_month, '전체' as order_month, prd_qty, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_shop, shop, prd_qty, reorder_status




-- (첫구매월&재구매월 : 기간별, 상품 : 상품_수량별)
WITH reorder_zip AS (
SELECT 	*,
			CASE WHEN product_qty * order_qty = 1 THEN Product || '_' || (product_qty * order_qty)
			WHEN product_qty * order_qty = 3 THEN Product || '_' || (product_qty * order_qty)
			ELSE  Product || '_기타'
			END AS prd_qty
FROM customer_zip3
WHERE KEY IN 
	(
		SELECT distinct key
		FROM customer_zip3
		GROUP BY KEY
		HAVING COUNT(*) > 1 
	)
)

SELECT first_shop, shop, first_month, order_month, prd_qty, reorder_status, COUNT(DISTINCT KEY)
FROM 	(
			SELECT 	*,
						CASE WHEN rank = 1 THEN 0
						WHEN rank > 1 THEN 1
						END AS reorder_status 
			FROM 	(
						SELECT 	*,
									first_value(shop) over(partition BY KEY Order BY seq) AS first_shop,
									rank() over (partition BY KEY Order BY seq) AS rank,
									SUBSTRING (first_value(order_date) over(partition BY KEY Order BY seq), 1, 7) AS first_month,
									SUBSTRING(order_date, 1, 7) AS order_month 
						FROM "reorder_zip"
					) AS t1
		) AS t2
GROUP BY first_shop, shop, first_month, order_month, prd_qty, reorder_status




