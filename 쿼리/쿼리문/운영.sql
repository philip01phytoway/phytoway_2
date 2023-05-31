-- 2023-05-25 코호트 요청
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
						WHERE order_id <> '' AND phytoway = 'y' AND store IN ('스마트스토어', '스마트스토어_풀필먼트')
					) AS t1
		) AS t2
GROUP BY cohort_group, cohort_index, nick



SELECT * 
FROM "Naver_Search_Channel"
WHERE "D" LIKE '%판토모나%' OR "D" LIKE '%써큐시안%'


SELECT *
FROM "ad_mapping3"


SELECT *
FROM "naver_option"
WHERE option_code = '31861468601'



SELECT *
FROM "product"
Order BY NO




select *
from "EZ_Order"
where seq = 502705



