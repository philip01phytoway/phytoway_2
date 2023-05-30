-- 재고현황
-- SCM 프로젝트



-- 판매현황
SELECT 	yymm, yyww, order_date, onnuri_code, onnuri_name,
			CASE 
				WHEN store IN ('스마트스토어_풀필먼트', '쿠팡_제트배송') THEN store
				ELSE '코린트'
			END AS "warehouse", 
			SUM(out_qty) AS out_qty, SUM(prd_amount_mod) AS selling_price, SUM(prd_amount_mod) / 2 AS "purchase_price", store_type
FROM 	(
			SELECT 	*, 
						CASE 
							WHEN order_id = '' THEN 'B2B'
							WHEN order_id <> '' THEN 'B2C'
						END AS store_type
			FROM "order_batch" 
			WHERE onnuri_type = '판매분매입'
		) AS t
WHERE yymm >= '2023-01'
GROUP BY yymm, yyww, order_date, onnuri_code, onnuri_name, store_type, store
Order BY order_date desc



-- 재고현황 1차 버전

SELECT 	reg_date, "warehouse", onnuri_code, onnuri_name, stock_type,
			lag(stock_qty, 1) over(partition BY "warehouse", onnuri_name, stock_type Order BY reg_date ASC) AS base_qty,
			flow_qty, stock_qty, avg_sales_qty, 
			
			CASE 
				WHEN avg_sales_qty <> 0 OR avg_sales_qty IS NULL THEN (stock_qty / avg_sales_qty * -1)::integer
				ELSE NULL
			END AS shortage_period

FROM 	(


SELECT 	*,
			SUM(flow_qty) over(partition BY "warehouse", onnuri_name Order BY reg_date ASC) AS stock_qty,
			AVG(CASE WHEN stock_type = '판매' THEN flow_qty ELSE NULL END) OVER (PARTITION BY "warehouse", onnuri_name, stock_type ORDER BY reg_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)::integer AS avg_sales_qty


FROM 	(


SELECT reg_date, "warehouse", onnuri_code, onnuri_name, "stock_type", SUM(recv_qty) AS flow_qty			 
FROM 	(


-- 1. 입고
SELECT s.reg_date, p.onnuri_code, p.onnuri_name, w.name AS "warehouse", s.recv_qty, '입고' AS "stock_type"
FROM "stock_recv" AS s
LEFT JOIN "warehouse" AS w ON (s.warehouse_no = w."no")
LEFT JOIN "product" AS p ON (s.product_no = p.no)
WHERE p.onnuri_type = '판매분매입'

UNION ALL 


-- 2. 재고이동
-- 2-1. 코린트 재고이동(출고)
SELECT s.reg_date, p.onnuri_code, p.onnuri_name, w.name AS "warehouse", s.trans_qty * -1 AS trans_qty, '재고이동' AS "stock_type"
FROM "stock_trans" AS s
LEFT JOIN "warehouse" AS w ON (s.from_warehouse_no = w."no")
LEFT JOIN "product" AS p ON (s.product_no = p.no)
WHERE s.from_warehouse_no = 1 AND p.onnuri_type = '판매분매입'


UNION ALL 


-- 2-2. 스마트스토어_풀필먼트 재고이동(입고)
SELECT s.reg_date, p.onnuri_code, p.onnuri_name, w.name AS "warehouse", s.trans_qty, '재고이동' AS "stock_type"
FROM "stock_trans" AS s
LEFT JOIN "warehouse" AS w ON (s.to_warehouse_no = w."no")
LEFT JOIN "product" AS p ON (s.product_no = p.no)
WHERE s.to_warehouse_no = 2 AND p.onnuri_type = '판매분매입'


UNION ALL 


-- 2-3. 쿠팡_제트배송 재고이동(입고)
SELECT s.reg_date, p.onnuri_code, p.onnuri_name, w.name AS "warehouse", s.trans_qty, '재고이동' AS "stock_type"
FROM "stock_trans" AS s
LEFT JOIN "warehouse" AS w ON (s.to_warehouse_no = w."no")
LEFT JOIN "product" AS p ON (s.product_no = p.no)
WHERE s.to_warehouse_no = 3 AND p.onnuri_type = '판매분매입'


UNION ALL 


-- 3. 출고
SELECT 	trans_date, onnuri_code, onnuri_name,
			CASE 
				WHEN store = '스마트스토어_풀필먼트' AND order_status = '주문' THEN '스마트스토어_풀필먼트'
				WHEN store = '스마트스토어_풀필먼트' AND order_status = '반품' THEN '코린트'
				WHEN store = '쿠팡_제트배송' THEN '쿠팡_제트배송'
				ELSE '코린트'
			END AS "warehouse", 
			SUM(out_qty) * -1 AS out_qty, '판매' AS "stock_type"
FROM 	(
			SELECT 	*, 
						CASE 
							WHEN order_id = '' THEN 'B2B'
							WHEN order_id <> '' THEN 'B2C'
						END AS store_type
			FROM "order_batch" 
			WHERE onnuri_type = '판매분매입' AND order_date >= '2023-05-01' 
			AND trans_date <> '' AND trans_date IS NOT NULL AND order_status <> '취소'
		) AS t
GROUP BY trans_date, onnuri_code, onnuri_name, store, order_status

UNION ALL 


-- 4. 추가발송
SELECT 	
			trans_date, onnuri_code, onnuri_name,
			'코린트' AS "warehouse", 
			SUM(out_qty) * -1 AS out_qty, '판매' AS "stock_type"
FROM 	(
			SELECT	

						left(order_date, 10) AS order_date, o2.recv_name, 
						
						o2.shop_id, 
						
						o2.brand, o2.nick, o2.product_qty, o2.order_qty, o2.product_qty * o2.order_qty AS out_qty,
		
						o2.prd_amount_mod,
						
						o2.onnuri_code, o2.onnuri_name, o2.onnuri_type, 
						left(trans_date_pos, 10) AS trans_date

			FROM (
						SELECT *, p.qty AS order_qty, b.qty AS product_qty,
									CASE WHEN o.shop_name = '자사몰' AND p.prd_amount = 0 THEN b.price
									ELSE p.prd_amount
									END AS prd_amount_mod,
									p.order_cs AS order_status
								
						FROM	"EZ_Order" as o,																		
								jsonb_to_recordset(o.order_products) as p(																	
									name character varying(255),																
									product_id character varying(255),																
									qty integer, 
									prd_amount integer,	
									prd_supply_price integer,															
									order_cs integer,																
									cancel_date character varying(255),																
									change_date character varying(255)																
								)
						LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
						LEFT JOIN "product" as pp on (b.product_no = pp.no)																		
						WHERE	order_id NOT IN (SELECT order_num FROM "Non_Order")	
								 AND pp.term > 0 AND o.order_name <> '' --AND p.order_cs = 0
					) AS o2
		) AS o3
LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
WHERE s.no = 47 AND onnuri_type = '판매분매입' AND recv_name NOT LIKE '%전현빈%'
AND trans_date <> '' AND trans_date IS NOT NULL AND trans_date >= '2023-05-02'
GROUP BY trans_date, onnuri_code, onnuri_name


) AS t1
GROUP BY reg_date, "warehouse", onnuri_code, onnuri_name, "stock_type"


) AS t2


) t3
--WHERE "warehouse" = '코린트' AND onnuri_name = '판토모나 비오틴 하이퍼포머'
Order BY reg_date DESC 




-- 추가발송건
SELECT 	
			trans_date, onnuri_code, onnuri_name,
			'코린트' AS "warehouse", 
			SUM(out_qty) * -1 AS out_qty, '증정' AS "stock_type"
FROM 	(
			SELECT	

						left(order_date, 10) AS order_date, o2.recv_name, 
						
						o2.shop_id, 
						
						o2.brand, o2.nick, o2.product_qty, o2.order_qty, o2.product_qty * o2.order_qty AS out_qty,
		
						o2.prd_amount_mod,
						
						o2.onnuri_code, o2.onnuri_name, o2.onnuri_type, 
						left(trans_date_pos, 10) AS trans_date

			FROM (
						SELECT *, p.qty AS order_qty, b.qty AS product_qty,
									CASE WHEN o.shop_name = '자사몰' AND p.prd_amount = 0 THEN b.price
									ELSE p.prd_amount
									END AS prd_amount_mod,
									p.order_cs AS order_status
								
						FROM	"EZ_Order" as o,																		
								jsonb_to_recordset(o.order_products) as p(																	
									name character varying(255),																
									product_id character varying(255),																
									qty integer, 
									prd_amount integer,	
									prd_supply_price integer,															
									order_cs integer,																
									cancel_date character varying(255),																
									change_date character varying(255)																
								)
						LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
						LEFT JOIN "product" as pp on (b.product_no = pp.no)																		
						WHERE	order_id NOT IN (SELECT order_num FROM "Non_Order")	
								 AND pp.term > 0 AND o.order_name <> '' --AND p.order_cs = 0
					) AS o2
		) AS o3
LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
WHERE s.no = 47 AND onnuri_type = '판매분매입' AND recv_name NOT LIKE '%전현빈%'
AND trans_date <> '' AND trans_date IS NOT NULL
GROUP BY trans_date, onnuri_code, onnuri_name





--------------------------------------------------------------------

-- 재고현황 2차

--------------------------------------------------------------------
SELECT 	base_date, "warehouse", onnuri_code, onnuri_name, stock_type,
			lag(stock_qty, 1) over(partition BY "warehouse", onnuri_name, stock_type Order BY base_date ASC) AS base_qty,
			flow_qty, stock_qty, avg_out_qty, 
			CASE 
				WHEN avg_out_qty <> 0 OR avg_out_qty IS not NULL THEN (stock_qty / avg_out_qty * -1)::integer
				ELSE NULL
			END AS shortage_period
FROM 	(


		SELECT 	*,
					SUM(flow_qty) over(partition BY "warehouse", onnuri_name Order BY base_date ASC) AS stock_qty,
					AVG(CASE WHEN stock_type = '출고' THEN flow_qty ELSE NULL END) OVER (PARTITION BY "warehouse", onnuri_name, stock_type ORDER BY base_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)::integer AS avg_out_qty
		FROM 	(


				SELECT base_date, "warehouse", onnuri_code, onnuri_name, "stock_type", SUM(qty) AS flow_qty		
				FROM (


						-- 코린트 기준 재고 (2023-05-22)
						SELECT base_date, w.name AS warehouse, s.qty, p.onnuri_code, p.onnuri_name, '기준재고' AS "stock_type"
						FROM "stock_base" AS s
						LEFT JOIN "warehouse" AS w ON (s.warehouse_no = w.no)
						LEFT JOIN "product" AS p ON (s.product_no = p.no)

						UNION ALL 

						-- 코린트 입고
						SELECT LEFT(crdate, 10) AS in_date, '코린트' as warehouse, s.qty * b.qty AS in_qty, p.onnuri_code, p.onnuri_name, '입고' AS "stock_type"
						FROM "stock_log" AS s
						LEFT JOIN "bundle" AS b ON (s.product_id = b.ez_code)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						WHERE job = 'in' AND crdate > '2023-05-25'



						UNION ALL 

						-- 코린트 --> 풀필먼트, 제트배송 재고이동 | 코린트에서 출고한 관점
						-- 판매처
						SELECT trans_date, '코린트' AS warehouse,
									out_qty * -1 AS out_qty, o3.onnuri_code, o3.onnuri_name, '재고이동' AS stock_type
						FROM (
									SELECT	
												left(order_date, 10) AS order_date, o2.shop_id, o2.nick,
												o2.product_qty * o2.order_qty AS out_qty,
												o2.onnuri_code, o2.onnuri_name, o2.onnuri_type, 
												left(trans_date_pos, 10) AS trans_date

									FROM (
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM	"EZ_Order" as o,																		
														jsonb_to_recordset(o.order_products) as p(																	
															name character varying(255),																
															product_id character varying(255),																
															qty integer																
														)
												LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
												LEFT JOIN "product" as pp on (b.product_no = pp.no)																		
												WHERE	order_id NOT IN (SELECT order_num FROM "Non_Order")	
														 AND pp.term > 0 
											) AS o2
								) AS o3
						LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
						WHERE s.no IN (48, 49) AND onnuri_type = '판매분매입' AND trans_date > '2023-05-25'



						UNION ALL 



						-- 코린트 --> 풀필먼트, 제트배송 재고이동 | 풀필먼트, 제트배송에 입고한 관점
						-- 판매처
						SELECT trans_date, 
									CASE 
										WHEN s.no = 48 THEN '쿠팡_제트배송'
										WHEN s.no = 49 THEN '스마트스토어_풀필먼트'
									END AS warehouse,
									out_qty, o3.onnuri_code, o3.onnuri_name, '재고이동' AS stock_type
						FROM (
									SELECT	
												left(order_date, 10) AS order_date, o2.shop_id, o2.nick,
												o2.product_qty * o2.order_qty AS out_qty,
												o2.onnuri_code, o2.onnuri_name, o2.onnuri_type, 
												left(trans_date_pos, 10) AS trans_date

									FROM (
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM	"EZ_Order" as o,																		
														jsonb_to_recordset(o.order_products) as p(																	
															name character varying(255),																
															product_id character varying(255),																
															qty integer																
														)
												LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
												LEFT JOIN "product" as pp on (b.product_no = pp.no)																		
												WHERE	order_id NOT IN (SELECT order_num FROM "Non_Order")	
														 AND pp.term > 0 
											) AS o2
								) AS o3
						LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
						WHERE s.no IN (48, 49) AND onnuri_type = '판매분매입' AND trans_date > '2023-05-25'



						UNION ALL 


						-- 코린트 조정
						SELECT LEFT(crdate, 10) AS out_date, '코린트' AS warehouse, s.qty * b.qty AS arrange_qty, p.onnuri_code, p.onnuri_name, '조정' AS stock_type
						FROM "stock_log" AS s
						LEFT JOIN "bundle" AS b ON (s.product_id = b.ez_code)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						WHERE job = 'arrange' AND crdate > '2023-05-25'



						UNION ALL 

						-- 코린트 반품입고
						SELECT LEFT(crdate, 10) AS out_date, '코린트' AS warehouse, s.qty * b.qty AS arrange_qty, p.onnuri_code, p.onnuri_name, '반품입고' AS stock_type
						FROM "stock_log" AS s
						LEFT JOIN "bundle" AS b ON (s.product_id = b.ez_code)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						WHERE job = 'retin' AND crdate > '2023-05-25'


						UNION ALL 


						-- 창고별 출고 (반품 제외하고 주문만)
						SELECT 	trans_date, "warehouse", SUM(out_qty) AS out_qty, onnuri_code, onnuri_name, '출고' AS "stock_type"
						FROM (
						SELECT 	trans_date, 
									CASE 
										WHEN store = '스마트스토어_풀필먼트' THEN '스마트스토어_풀필먼트'
										WHEN store = '쿠팡_제트배송' THEN '쿠팡_제트배송'
										ELSE '코린트'
									END AS "warehouse", 
									SUM(out_qty) * -1 AS out_qty, onnuri_code, onnuri_name
						FROM 	(
									SELECT 	*
									FROM "order_batch" 
									WHERE onnuri_type = '판매분매입' AND trans_date > '2023-05-25' 
									AND trans_date <> '' AND trans_date IS NOT NULL AND order_status <> '취소' AND order_status <> '반품'
								) AS t
						GROUP BY trans_date, onnuri_code, onnuri_name, store
						) AS t
						GROUP BY trans_date, "warehouse", onnuri_code, onnuri_name


						UNION ALL 


						-- 코린트 추가발송
						SELECT 	trans_date, "warehouse", SUM(out_qty) AS out_qty, onnuri_code, onnuri_name, '출고' AS "stock_type"
						FROM (
						SELECT 	
									trans_date, '코린트' AS "warehouse", SUM(out_qty) * -1 AS out_qty, 
									onnuri_code, onnuri_name
						FROM 	(
									SELECT	
												left(order_date, 10) AS order_date, o2.recv_name,
												o2.shop_id, 
												o2.nick, o2.product_qty * o2.order_qty AS out_qty,
												o2.onnuri_code, o2.onnuri_name, o2.onnuri_type, 
												left(trans_date_pos, 10) AS trans_date
									FROM (
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM	"EZ_Order" as o,																		
														jsonb_to_recordset(o.order_products) as p(																	
															name character varying(255),																
															product_id character varying(255),																
															qty integer															
														)
												LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
												LEFT JOIN "product" as pp on (b.product_no = pp.no)																		
												WHERE	order_id NOT IN (SELECT order_num FROM "Non_Order")	
														 AND pp.term > 0
											) AS o2
								) AS o3
						LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
						WHERE s.no = 47 AND onnuri_type = '판매분매입' AND recv_name NOT LIKE '%전현빈%'
						AND trans_date <> '' AND trans_date IS NOT NULL AND trans_date > '2023-05-25' 
						GROUP BY trans_date, onnuri_code, onnuri_name
						) AS t
						GROUP BY trans_date, "warehouse", onnuri_code, onnuri_name

					) AS t1
				WHERE "warehouse" IN ('코린트', '스마트스토어_풀필먼트') and base_date < '2023-05-30'  
				group by base_date, "warehouse", onnuri_code, onnuri_name, "stock_type"

			) AS t2

	) as t3
order by base_date desc, warehouse, onnuri_name, stock_type










-- 루테콤 5월 23일 3개 더 출고 (이지어드민과 대조)
select *
from "order_batch"
where trans_date = '2023-05-23' and nick = '루테콤'

select *
from "coupang_order"
where "orderId" = 11000180629810

select *
from (
			select left(trans_date, 10) as trans_date, left(trans_date_pos, 10) as trans_date_pos, left(trans_date, 10) < left(trans_date_pos, 10) as cond
			from "EZ_Order"
			where order_date > '2022-01-01'
	) as t
where cond = true

select *
from "naver_order_product"
limit 10000

select *
from "EZ_Order"
where order_cs in (0, 1) and trans_date <> '' and trans_date_pos = ''
order by trans_date


-- 싸이토팜 5월 23일 3개 더 출고 (이지어드민과 대조)
select order_id
from "order_batch"
where trans_date = '2023-05-23' and nick = '싸이토팜' and store = '쿠팡'

select *
from "EZ_Order"
where order_id in (
	select order_id
	from "order_batch"
	where trans_date = '2023-05-23' and nick = '싸이토팜' and store = '쿠팡')

-- 써큐시안 수량 다른 것
select *
from "order_batch"
where order_id in (
	select order_id
	from "EZ_Order"
	where shop_name = '자사몰' and product_name like '%선물%'
	order by order_date
)
order by out_qty

select store, sum(out_qty)
from "order_batch"
where trans_date = '2023-05-24' and nick = '써큐시안'
group by store

select order_id
from "EZ_Order"
where order_id in (
	select order_id
	from "order_batch"
	where trans_date = '2023-05-24' and nick = '써큐시안' and store = '자사몰'
	order by order_id
)
order by order_id

select *
from "EZ_Order"
where order_id = '20230523-0000136'

select *
from "order_batch"
where order_id = '20230523-0000136'


-- 쿠팡 제트배송
select *
from "order_batch"
where store = '쿠팡_제트배송'
order by order_date


select *
from "coupang_sales"


-- 풀필먼트 수량 다른 것
SELECT 	trans_date, "warehouse", SUM(out_qty) AS out_qty, onnuri_code, onnuri_name, '출고' AS "stock_type"
FROM (
SELECT 	trans_date, 
			CASE 
				WHEN store = '스마트스토어_풀필먼트' THEN '스마트스토어_풀필먼트'
				WHEN store = '쿠팡_제트배송' THEN '쿠팡_제트배송'
				ELSE '코린트'
			END AS "warehouse", 
			SUM(out_qty) * -1 AS out_qty, onnuri_code, onnuri_name
FROM 	(
			SELECT 	*
			FROM "order_batch" 
			WHERE onnuri_type = '판매분매입' AND trans_date > '2023-05-25' 
			AND trans_date <> '' AND trans_date IS NOT NULL AND order_status <> '취소' AND order_status <> '반품'
		) AS t
GROUP BY trans_date, onnuri_code, onnuri_name, store
) AS t
where warehouse = '스마트스토어_풀필먼트' and onnuri_name = '판토모나 비오틴 하이퍼포머'
GROUP BY trans_date, "warehouse", onnuri_code, onnuri_name

select sum(out_qty)
from (
		select *, max(order_status) over(partition by order_id) as order_status_mod
		from "order_batch"
		where store = '스마트스토어_풀필먼트' and nick = '판토모나하이퍼포머' and trans_date = '2023-05-26' AND order_status <> '취소' AND order_status <> '반품'
	) as t
where order_status_mod = '주문'


select order_id, out_qty
from "order_batch"
where store = '스마트스토어_풀필먼트' and nick = '판토모나하이퍼포머' and trans_date = '2023-05-26' AND order_status <> '취소' AND order_status <> '반품'

select *
from "order_batch"
where order_id in (
'2023052535140821',
'2023052536075921'
)

select *
from "naver_order_product"
where "orderId" in (
'2023052535140821',
'2023052536075921'
)


select *
from "order_batch"
where order_id in (
'2023052648051991',
'2023052638694851')

select *
from "naver_order_product"
where "orderId" in (
'2023052648051991',
'2023052638694851')


select *
from naver_option
where option_code = '31861468601'




-- 창고별 출고 (반품 제외하고 주문만)
SELECT 	trans_date, "warehouse", SUM(out_qty) AS out_qty, onnuri_code, onnuri_name, '출고' AS "stock_type"
FROM (
SELECT 	trans_date, 
			CASE 
				WHEN store = '스마트스토어_풀필먼트' THEN '스마트스토어_풀필먼트'
				WHEN store = '쿠팡_제트배송' THEN '쿠팡_제트배송'
				ELSE '코린트'
			END AS "warehouse", 
			SUM(out_qty) * -1 AS out_qty, onnuri_code, onnuri_name
FROM 	(
			SELECT 	*
			FROM "order_batch" 
			WHERE onnuri_type = '판매분매입' AND trans_date > '2023-04-22' 
			AND trans_date <> '' AND trans_date IS NOT NULL AND order_status <> '취소' AND order_status <> '반품' AND nick = '판토모나하이퍼포머'
			--AND nick = '판토모나하이퍼포머'
		) AS t
GROUP BY trans_date, onnuri_code, onnuri_name, store
) AS t
WHERE warehouse = '스마트스토어_풀필먼트' 
GROUP BY trans_date, "warehouse", onnuri_code, onnuri_name



SELECT order_id
FROM "order_batch" 
WHERE trans_date = '2023-05-24' AND nick = '판토모나하이퍼포머' AND store = '스마트스토어_풀필먼트' AND order_status <> '취소' AND order_status <> '반품'

WHERE order_id = '2023052368517361'

SELECT *
FROM "order_batch" 
WHERE order_id = '2023052115565621'



