-- 임시데이터분석팀 WBR 보고서



-- 19주차 WBR 보고서

-- B2B
SELECT yymm, yyww, order_date, 'B2B' AS "store_type", SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE order_id = '' AND yyww >= '2023-10'
GROUP BY yymm, yyww, order_date
Order BY order_date ASC

UNION ALL

-- 리셀러
SELECT yymm, yyww, order_date, '리셀러' AS "store_type", SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE order_id <> '' AND phytoway = 'y' AND prd_amount_mod > 500000 AND yyww >= '2023-10'
GROUP BY yymm, yyww, order_date
--Order BY order_date DESC

UNION ALL

-- 신규, 재구매
SELECT yymm, yyww, order_date, all_cust_type, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE order_id <> '' AND phytoway = 'y' AND prd_amount_mod <= 500000 AND yyww >= '2023-10'
GROUP BY yymm, yyww, order_date, all_cust_type
--Order BY order_date DESC

UNION ALL

-- 유지, 복귀
SELECT 	yymm, yyww, order_date, cust_type, SUM(prd_amount_mod) AS price
FROM 	(
			SELECT 	*,
						CASE 
							WHEN order_date BETWEEN prev_order_date AND prev_dead_date THEN '유지'
							WHEN order_date > prev_dead_date THEN '복귀'
						END AS cust_type
			FROM "order_batch"
			WHERE all_cust_type = '재구매'
		) AS t
WHERE order_id <> '' AND phytoway = 'y' AND prd_amount_mod <= 500000 AND cust_type IS NOT NULL AND yyww >= '2023-10'
GROUP BY yymm, yyww, order_date, cust_type
--Order BY order_date DESC







-------------------------------------------------------
데이터분석팀 wbr 매출 예측 쿼리
-------------------------------------------------------

-- B2B
SELECT y.yymm, y.yyww, y.yymmdd, 'B2B' AS "store_type", price
FROM "YMD2" AS y
LEFT JOIN (
				SELECT yymm, yyww, order_date, SUM(prd_amount_mod) AS price
				FROM "order_batch"
				WHERE order_id = '' AND phytoway = 'y' AND order_date < '2023-05-24'
				GROUP BY yymm, yyww, order_date
			) AS o ON (y.yymmdd = o.order_date)
WHERE y.yyww > '2023-12'
Order BY y.yymmdd asc


-- 리셀러
SELECT y.yymm, y.yyww, y.yymmdd, '리셀러' AS "store_type", price
FROM "YMD2" AS y
LEFT JOIN (
				SELECT yymm, yyww, order_date, SUM(prd_amount_mod) AS price
				FROM "order_batch"
				WHERE order_id <> '' AND phytoway = 'y' AND prd_amount_mod > 500000 AND order_date < '2023-05-24'
				GROUP BY yymm, yyww, order_date
			) AS o ON (y.yymmdd = o.order_date)
WHERE y.yyww > '2023-12'
Order BY y.yymmdd ASC