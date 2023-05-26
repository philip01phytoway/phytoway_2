-- 2023-05-25 코호트 요청
-- (상품, 수량)
-- 월 코호트

-- (전체, 전체)
SELECT cohort_group, cohort_index, '전체' as nick, '전체' AS qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *,
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, nick,
									first_value(order_date) over(partition BY KEY Order BY order_date_time) AS first_date
						FROM 	order_batch
						WHERE order_id <> '' AND store IN ('스마트스토어', '스마트스토어_풀필먼트') and phytoway = 'y'
					) AS t1
		) AS t2
GROUP BY cohort_group, cohort_index

union all

-- (상품별, 전체)
SELECT cohort_group, cohort_index, nick, '전체' AS qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *,
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, nick,
									first_value(order_date) over(partition BY KEY, nick Order BY order_date_time) AS first_date
						FROM 	order_batch
						WHERE order_id <> '' AND store IN ('스마트스토어', '스마트스토어_풀필먼트') and phytoway = 'y'
					) AS t1
		) AS t2
GROUP BY cohort_group, cohort_index, nick

union all 

-- (브랜드, 전체)
SELECT cohort_group, cohort_index, brand, '전체' AS qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *,
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, brand,
									first_value(order_date) over(partition BY KEY, brand Order BY order_date_time) AS first_date
						FROM 	order_batch
						WHERE order_id <> '' AND store IN ('스마트스토어', '스마트스토어_풀필먼트') and brand in ('판토모나', '페미론큐') and phytoway = 'y'
					) AS t1
		) AS t2
GROUP BY cohort_group, cohort_index, brand
