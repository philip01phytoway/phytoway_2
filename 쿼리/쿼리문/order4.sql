

-- yymmdd, product, gross, order_cnt, out_qty


-- 타겟 쿼리에서는 총 매출이 필요하고, group by를 
-- yymmdd, product, gross, order_cnt, out_qty


SELECT  y.yymm, y.yyww, y.yymmdd, product, shop_name, SUM(gross) AS gross, SUM(order_cnt) AS order_cnt, SUM(out_qty) AS out_qty
FROM 	(
			SELECT 
						o3.yymmdd, o3.product_name as product,																					
						s.name AS shop_name,																				
						SUM(o3.prd_amount_mod) as gross, sum(order_cnt) as order_cnt, sum(out_qty) as out_qty	
			FROM 	(
						SELECT	o2.seq, o2."order_cs_status",
									SUBSTRING(
													CASE WHEN o2."order_cs_status" = 0 THEN o2.order_date 
													ELSE																		
														CASE WHEN o2.cancel_date = '' THEN o2.change_date 
														ELSE o2.cancel_date END 
													END, 1, 10) as yymmdd,													
									o2.nick AS product_name, o2.product_qty, o2.order_qty,
																										
									CASE WHEN o2."order_cs_status" = 0 THEN o2.prd_amount_mod
									ELSE o2.prd_amount_mod * -1 
									END AS prd_amount_mod,
																										
									CASE WHEN o2."order_cs_status" = 0 AND o2.prd_amount_mod > 0 THEN 1 
									ELSE -1 
									END AS order_cnt,
																										
									CASE WHEN o2."order_cs_status" = 0 THEN o2.product_qty * o2.order_qty 
									ELSE (o2.product_qty * o2.order_qty ) * -1 
									END AS out_qty,
									o2.shop_id, o2."options", o2.term, order_date, order_name	
						
						FROM (
									SELECT *, p.qty AS order_qty, b.qty AS product_qty,
												CASE WHEN o.shop_name = '자사몰' AND p.prd_amount = 0 THEN b.price
												ELSE p.prd_amount
												END AS prd_amount_mod,
												o.order_cs AS "order_cs_status"			
									FROM	"EZ_Order" as o,																		
											jsonb_to_recordset(o.order_products) as p(																	
												name character varying(255),																
												product_id character varying(255),																
												qty integer, prd_amount integer,																
												order_cs integer,																
												cancel_date character varying(255),																
												change_date character varying(255)																
											)
									LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
									LEFT JOIN "product" as pp on (b.product_no = pp.no)																			
									WHERE	order_date > '2021-09-01' AND order_date < '2023-12-31' 
											AND order_id NOT IN (SELECT order_num FROM "Non_Order")	
											 AND pp.term > 0 AND o.order_name <> '' 
								) AS o2
					) AS o3
			LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
			WHERE 
					(
						(
							s.deal_type = 'B2C' AND "options" NOT LIKE '%메디%'
						)
					OR 
						(
							o3."options" LIKE '%메디%' AND order_date < '2022-08-23'
						)
					)
					AND s.no <> 45	--AND o3.prd_amount_mod < 500000 --AND o.prd_amount > 0
			
			GROUP BY o3.yymmdd, o3.product_name, s."name"
			
			UNION ALL
			
			-- 네이버 풀필먼트 매출
			SELECT 	LEFT("paymentDate", 10) AS "order_date", 
						p.nick, '스마트스토어' AS "shop", SUM("totalPaymentAmount"), COUNT(*) AS order_cnt, SUM("quantity" * o.option_qty) AS "out_qty"		
			FROM 		"naver_order_product" AS n
			LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
			LEFT JOIN "product" AS p ON (o."product_no" = p."no")
			WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE' AND "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED')
						--AND "totalPaymentAmount" < 500000
			GROUP BY LEFT("paymentDate", 10), p.nick	
			
			UNION ALL 
			
			-- 플레이오토 매출
			SELECT o.order_date AS yymmdd, p.nick AS product,																					
					CASE o.shop_name WHEN '스토어팜(파이토웨이)' THEN '스마트스토어' ELSE o.shop_name end as shop_name,																				
					sum(order_price) as gross, count(*) as order_cnt, sum(o.order_qty*b.qty) as out_qty																				
			FROM	"PA_Order2" as o 
			left join "Bundle" as b on (o.order_code = b.order_code)																					
			left join "product" as p on (b.product_id = p.no)																																									
			group by o.order_date, p.nick, o.shop_name	
			
			UNION ALL 
					
			--b2b 매출
			SELECT order_date, p.nick, s.name AS store,  SUM(gross) AS gross, COUNT(*) AS order_cnt, SUM(qty) AS out_qty
			FROM "b2b_gross" AS b
			LEFT JOIN "store" AS s ON (b.store_no = s.no)
			LEFT JOIN "product" AS p ON (b.product_no = p.no)
			GROUP BY order_date, p.nick, s.name
			
			UNION ALL 	
			
			SELECT order_date, nick, store, sum(amount) AS gross, COUNT(*) AS order_cnt, SUM(t.out_qty) AS out_qty
			FROM 	(
						SELECT 	"substring"((o.order_date)::text, 1, 10) AS order_date,
									CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
									WHEN o."options" LIKE '%온유%' THEN '온유약국'
									ELSE s.name
									END AS store,
									o.nick,
									o.amount, o.out_qty
						FROM 	(
									SELECT *, p.qty AS order_qty, b.qty AS product_qty, o.qty AS out_qty
									FROM "EZ_Order" AS o,
										(
											LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
											LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
											LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
										)
								) AS o
						LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
						WHERE 
								(
										(
											o.shop_id IN (10087, 10286, 10387) 
										)
									OR
										(
											o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
										)
									OR 
										(
											o."options" LIKE '%온유%'
										)
								) 
								AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									
					) AS t
			LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)
			GROUP BY order_date, store, nick
			
		) AS t
LEFT JOIN "YMD2" AS y ON (t.yymmdd = y.yymmdd)
GROUP BY y.yymm, y.yyww, y.yymmdd, product, shop_name		







-------------------------------------------------------------
-- order4


-- 이지어드민
-- 취소 및 반품 반영
-- 취소 및 교환을 where 절로 제거를 하느냐, order_cs_status에 따라 -값을 주느냐.
--> order_cs_status에 따라 -값을 준다. 신규 고객 매출에서 -가 나는 것도 가능하다.

-- 신규 고객이 취소했다가 다시 사면 신규 고객인가 재구매 고객인가?
--> 재구매고객으로 봄.


SELECT 	KEY, order_date, order_date_time, order_name, cust_id, order_tel, order_id, recv_name, recv_tel, recv_zip, recv_address,
			brand, product_name, product_qty, order_qty, order_cnt, out_qty, price, term, s.name AS store, 
			CASE WHEN price >= 500000 THEN '리셀러'
			ELSE 'B2C' 
			END AS order_type,
			'' AS decide_date
FROM 	(
			SELECT	(o2.order_name || REPLACE(o2.recv_zip, '-', '')) AS key, 
			
						order_date AS order_date_time,
						SUBSTRING(
										CASE WHEN o2."order_cs_status" = 0 THEN o2.order_date 
										ELSE																		
											CASE WHEN o2.cancel_date = '' THEN o2.change_date 
											ELSE o2.cancel_date END 
										END, 1, 10) as order_date,	
						o2.order_name, o2.cust_id,	
						CASE
	                 WHEN ((("substring"((o2.order_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o2.order_mobile)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.order_mobile)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.order_mobile)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.order_tel)::text, 1, 3) = '010'::text) OR ("substring"((o2.order_tel)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.order_tel)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.order_tel)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.recv_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o2.recv_mobile)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.recv_mobile)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.recv_mobile)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.recv_tel)::text, 1, 3) = '010'::text) OR ("substring"((o2.recv_tel)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.recv_tel)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.recv_tel)::text, '-'::text, ''::text)
	                 ELSE '000'
            		END AS order_tel,			
						o2.order_id, 	
						
						REPLACE((o2.recv_name)::text, ' '::text, ''::text) AS recv_name,					
						CASE
			            WHEN (("substring"((o2.recv_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o2.recv_mobile)::text, 1, 3) = '050'::text)) THEN REPLACE((o2.recv_mobile)::text, '-'::text, ''::text)
			            ELSE
			            CASE
			                WHEN (("substring"((o2.recv_tel)::text, 1, 3) = '010'::text) OR ("substring"((o2.recv_tel)::text, 1, 3) = '050'::text)) THEN REPLACE((o2.recv_tel)::text, '-'::text, ''::text)
			                ELSE
			                CASE
			                    WHEN (("substring"((o2.order_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o2.order_mobile)::text, 1, 3) = '050'::text)) THEN REPLACE((o2.order_mobile)::text, '-'::text, ''::text)
			                    ELSE
			                    CASE
			                        WHEN (("substring"((o2.order_tel)::text, 1, 3) = '010'::text) OR ("substring"((o2.order_tel)::text, 1, 3) = '050'::text)) THEN REPLACE((o2.order_tel)::text, '-'::text, ''::text)
			                        ELSE REPLACE((o2.recv_mobile)::text, '-'::text, ''::text)
			                    END
			                END
			            END
			        END AS recv_tel,
			        REPLACE(o2.recv_zip, '-', '') AS recv_zip,
			        o2.recv_address,
						
					  o2.brand,	o2.nick AS product_name, o2.product_qty, o2.order_qty,
																							
						CASE WHEN o2."order_cs_status" = 0 THEN o2.prd_amount_mod
						ELSE o2.prd_amount_mod * -1 
						END AS price,
																							
						CASE WHEN o2."order_cs_status" = 0 AND o2.prd_amount_mod > 0 THEN 1 
						ELSE -1 
						END AS order_cnt,
																							
						CASE WHEN o2."order_cs_status" = 0 THEN o2.product_qty * o2.order_qty 
						ELSE (o2.product_qty * o2.order_qty ) * -1 
						END AS out_qty,
						o2.term, o2."options", o2.shop_id
			
			FROM (
						SELECT *, p.qty AS order_qty, b.qty AS product_qty,
									CASE WHEN o.shop_name = '자사몰' AND p.prd_amount = 0 THEN b.price
									ELSE p.prd_amount
									END AS prd_amount_mod,
									o.order_cs AS "order_cs_status"			
						FROM	"EZ_Order" as o,																		
								jsonb_to_recordset(o.order_products) as p(																	
									name character varying(255),																
									product_id character varying(255),																
									qty integer, prd_amount integer,																
									order_cs integer,																
									cancel_date character varying(255),																
									change_date character varying(255)																
								)
						LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
						LEFT JOIN "product" as pp on (b.product_no = pp.no)																			
						WHERE	order_date > '2021-09-01' AND order_date < '2023-12-31' 
								AND order_id NOT IN (SELECT order_num FROM "Non_Order")	
								 AND pp.term > 0 AND o.order_name <> '' 
					) AS o2
		) AS o3
LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
WHERE 
		(
			(
				s.deal_type = 'B2C' AND "options" NOT LIKE '%메디%'
			)
		OR 
			(
				o3."options" LIKE '%메디%' AND order_date < '2022-08-23'
			)
		)
		AND s.no <> 45

			
UNION ALL  
-- 풀필먼트
-- 취소 및 반품 반영


SELECT 	"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "key", 
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') THEN LEFT("paymentDate", 10) 
			WHEN "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') THEN LEFT("claimRequestDate", 10) 
			END AS "order_date", 
			LEFT("paymentDate", 10) || ' ' || SUBSTRING("paymentDate", 12, 8) AS "order_date_time", "ordererName", "ordererId", "ordererTel", "orderId",		
			("shippingAddress" ->> 'name')::text AS "recv_name", REPLACE(("shippingAddress" ->> 'tel1')::text, '-', '') AS "recv_tel", ("shippingAddress" ->> 'zipCode')::TEXT AS recv_zip, ("shippingAddress" ->> 'baseAddress')::TEXT AS recv_address, 
			p.brand, p.nick AS product_name, o.option_qty AS "product_qty", "quantity" AS order_qty, 
			
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') THEN 1
			WHEN "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') THEN 0
			END AS "order_cnt", 
			
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') THEN "quantity" * o.option_qty
			WHEN "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') THEN 0
			END AS "out_qty", 
			
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') THEN "totalPaymentAmount"
			WHEN "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') THEN 0
			END AS "price",
			
			p.term, '스마트스토어' AS store, 
			
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') AND "totalPaymentAmount" >= 500000 THEN '리셀러'
			ELSE 'B2C'
			END AS order_type,
			
			"decisionDate"
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")
WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE'


UNION ALL 

-- B2B 매출
--1
SELECT 	'' AS KEY, order_date, '' AS order_date_time, '' AS order_name, '' AS cust_id, '' AS order_tel, '' AS order_id,
			'' AS recv_name, '' AS recv_tel, '' AS recv_zip, '' AS recv_address,
			p.brand, p.nick AS product_name, 1 AS product_qty, 1 AS order_qty, 
			
			CASE WHEN gross < 0 THEN -1
			ELSE 1 
			END AS order_cnt, 
			
			CASE WHEN gross < 0 THEN LEAST(qty, -qty)
			ELSE qty
			END AS out_qty,
			
			gross AS price, 
			0 AS term, s.name AS store, 'B2B' AS order_type, '' AS decide_date
FROM "b2b_gross" AS b
LEFT JOIN "store" AS s ON (b.store_no = s.no)
LEFT JOIN "product" AS p ON (b.product_no = p.no)


UNION ALL 
--2


SELECT 	'' AS KEY, "substring"((o.order_date)::text, 1, 10) AS order_date,'' AS order_date_time, '' AS order_name, '' AS cust_id, '' AS order_tel, '' AS order_id,
			'' AS recv_name, '' AS recv_tel, '' AS recv_zip, '' AS recv_address, 
			o.brand, o.nick AS product_name, 1 AS product_qty, 1 AS order_qty, 1 AS order_cnt, o.out_qty,
			o.amount AS price, 0 AS term, 
			
			CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
			WHEN o."options" LIKE '%온유%' THEN '온유약국'
			ELSE s.name
			END AS store,
			
			'B2B' AS order_type, '' AS decide_date
FROM 	(
			SELECT *, o.qty AS out_qty
			FROM "EZ_Order" AS o,
				(
					LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
					LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
					LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
				)
		) AS o
LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
WHERE 
		(
				(
					o.shop_id IN (10087, 10286, 10387) 
				)
			OR
				(
					o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
				)
			OR 
				(
					o."options" LIKE '%온유%'
				)
		) AND 
		o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' 
		AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									


-- PA_Order
UNION ALL 


SELECT 	order_name || order_zip AS KEY, order_date, order_date || ' 00:00:00' AS order_date_time, order_name, '' AS cust_id, order_tel, '' AS order_id, 
			order_name AS recv_name, order_tel AS recv_tel, order_zip AS recv_zip, '' AS recv_address, 
			p.brand, p.nick AS product_name, b.qty AS product_qty, order_qty, 
			
			CASE WHEN order_qty > 0 THEN 1
			ELSE -1
			END AS order_cnt,
			
			b.qty * order_qty AS out_qty, order_price AS price, p.term, 
			
			CASE o.shop_name WHEN '스토어팜(파이토웨이)' THEN '스마트스토어' 
			ELSE o.shop_name END AS store,
			
			CASE WHEN order_price >= 500000 THEN '리셀러'
			ELSE 'B2C' 
			END AS order_type,
			
			'' AS decide_date

FROM	"PA_Order2" as o 
left join "Bundle" as b on (o.order_code = b.order_code)																					
left join "product" as p on (b.product_id = p.no)																																									

			
--------------------------------------


			
-- 풀필먼트의 경우에는 취소 및 반품 시 행이 새로 추가되는게 아니므로
-- 주문 내역은 남되, 매출 및 주문건수는 0으로 처리를 하는게 맞겠다.
-- 취소했다가 또 구매한 경우는 재구매 고객으로 보고.	


--데이터 스튜디오 > 타겟에 들어갈 매출
SELECT 	order_date, product_name, SUM(price) AS price, SUM(order_cnt) AS order_cnt, SUM(out_qty) AS out_qty
FROM 	(
			SELECT 	order_date, 
					
						CASE WHEN brand IN ('루테콤', '트리플', '페미론큐', '싸이토팜', '콘디맥스') THEN '자사'
						ELSE brand 
						END AS product_name,	
						
						price, order_cnt, out_qty
			FROM "order4"
		) AS o
WHERE order_date >= '2020-01-01'
GROUP BY order_date, product_name
Order BY order_date DESC

-- yymmdd product gross order_cnt out_qty


-- 데이터스튜디오 타겟 쿼리 
SELECT	t.yymmdd, t.product, o.price, o.order_cnt, o.out_qty, k.query_sum, t.gross_target, t.gross_prev, t.calling_target, t.calling_prev, t.conv_target, t.conv_prev,
		t.gross_forecast, t.calling_forecast
FROM
		(
			select 	y.yymm, y.yyww, t.yymmdd, product, gross_target, gross_prev, calling_target, calling_prev, conv_target, conv_prev,
					f.gross2 as gross_forecast, f.calling2 as calling_forecast
			from "Target" as t left join "YMD2" as y on (t.yymmdd = y.yymmdd) left join (
			select * from fn_gross_forecast(30)) as f on (t.yymmdd = f.yymmdd2)
		) as t left join
		(

			SELECT 	order_date, product_name, SUM(price) AS price, SUM(order_cnt) AS order_cnt, SUM(out_qty) AS out_qty
			FROM 	(
						SELECT 	order_date, 
								
									CASE WHEN brand IN ('루테콤', '트리플', '페미론큐', '싸이토팜', '콘디맥스') THEN '자사'
									ELSE brand 
									END AS product_name,	
									
									price, order_cnt, out_qty
						FROM "order4"
					) AS o
			WHERE order_date >= '2020-01-01'
			GROUP BY order_date, product_name
			Order BY order_date DESC

		) as o on (t.yymmdd = o.order_date and t.product = o.product_name) left join
		(
			SELECT	q.query_date as yymmdd,
					case when p.nick is null then '파이토웨이' else p.nick end as product,
					sum(q.mobile_cnt) as query_sum
			FROM	"Query_Log2" as q left join "Keyword2" as k on (q.keyword = k.keyword)
					left join "Product" as p on (k.product_id = p.id)
			GROUP BY q.query_date, product
		) as k on (t.yymmdd = k.yymmdd and t.product = k.product)
ORDER BY t.yymmdd DESC






--데이터 스튜디오 > 매출
SELECT 	yymm, yyww, yymmdd, product_name, store,
			SUM(price) AS price, SUM(order_cnt) AS order_cnt, SUM(out_qty) AS out_qty
FROM "order4" AS o
LEFT JOIN "YMD2" AS y ON (o.order_date = y.yymmdd)
WHERE yymmdd >= '2020-01-01'
GROUP BY yymm, yyww, yymmdd, product_name, store
Order BY yymmdd DESC






SELECT	y.yymm, y.yyww, o.yymmdd, o.product, o.shop_name,
		sum(o.gross) as gross, sum(o.order_cnt) as order_cnt, sum(o.out_qty) as out_qty
FROM
		
		(
			SELECT	o.yymmdd, o.product_name as product,
					case o.shop_name when '스토어팜(파이토웨이)' then '스마트스토어' ELSE o.shop_name end as shop_name,
					sum(o.prd_amount) as gross, sum(order_cnt) as order_cnt, sum(out_qty) as out_qty
			FROM
					(
						SELECT	o.seq, substring(case when p.order_cs = 0 then o.order_date else
												 case when p.cancel_date = '' then p.change_date else p.cancel_date end end, 1, 10) as yymmdd,
								o.shop_name,
								pp.nick as product_name, product_name as product_name2, b.qty as product_qty, p.qty as order_qty,
								case when p.order_cs = 0 then p.prd_amount else p.prd_amount * -1 end as prd_amount,
								case when p.order_cs = 0 and p.prd_amount > 0 then 1 else -1 end as order_cnt,
								case when p.order_cs = 0 then b.qty * p.qty else (b.qty * p.qty) * -1 end as out_qty
						FROM	"EZ_Order" as o,
								jsonb_to_recordset(o.order_products) as p(
									name character varying(255),
									product_id character varying(255),
									qty integer, prd_amount integer,
									order_cs integer,
									cancel_date character varying(255),
									change_date character varying(255)
								)
								left join "Bundle" as b on (p.product_id = b.order_code)
								left join "Product" as pp on (b.product_id = pp.id)
						WHERE	order_date > '2021-09-01' and order_date < '2023-12-31' AND order_id not in (
							select order_num from "Non_Order")
						AND shop_name = '쿠팡'
					) as o
			GROUP BY o.yymmdd, o.product_name, o.shop_name
			
			UNION
			
			select 	o.order_date as yymmdd, p.nick as product,
					case o.shop_name when '스토어팜(파이토웨이)' then '스마트스토어' ELSE o.shop_name end as shop_name,
					sum(order_price) as gross, count(*) as order_cnt, sum(o.order_qty*b.qty) as out_qty
			from 	"PA_Order2" as o left join "Bundle" as b on (o.order_code = b.order_code)
					left join "Product" as p on (b.product_id = p.id)
			--where o.order_date >= '2021-01-01'
			group by o.order_date, p.nick, o.shop_name
		) as o left join
		(
			SELECT	yymmdd, yymm, yyww
			FROM	"YMD2"
		) as y on (o.yymmdd = y.yymmdd)
GROUP BY y.yymm, y.yyww, o.yymmdd, o.product, o.shop_name		
ORDER BY o.yymmdd DESC


SELECT *
FROM	"EZ_Order" as o,
		jsonb_to_recordset(o.order_products) as p(
			name character varying(255),
			product_id character varying(255),
			qty integer, prd_amount integer,
			order_cs integer,
			cancel_date character varying(255),
			change_date character varying(255)
		)
WHERE length(p.product_id) > 5

SELECT *
FROM "Bundle"
WHERE LENGTH(order_code) = 5
AND order_code NOT IN (SELECT ez_code FROM "bundle")







SELECT	t.yymmdd, t.product, o.gross, o.order_cnt, o.out_qty, k.query_sum, t.gross_target, t.gross_prev, t.calling_target, t.calling_prev, t.conv_target, t.conv_prev,
		t.gross_forecast, t.calling_forecast
FROM
		(
			select 	y.yymm, y.yyww, t.yymmdd, product, gross_target, gross_prev, calling_target, calling_prev, conv_target, conv_prev,
					f.gross2 as gross_forecast, f.calling2 as calling_forecast
			from "Target" as t left join "YMD2" as y on (t.yymmdd = y.yymmdd) left join (
			select * from fn_gross_forecast(30)) as f on (t.yymmdd = f.yymmdd2)
		) as t left join
		(
			SELECT	o.order_date as yymmdd, o.product_name as product, sum(o.prd_amount) as gross, sum(order_cnt) as order_cnt, sum(out_qty) as out_qty
			FROM
					(
						SELECT	o.seq, substring(case when p.order_cs = 0 then o.order_date else p.cancel_date end, 1, 10) as order_date,
								o.shop_name,
								CASE WHEN pp.nick IN ('루테콤', '트리플마그네슘', '페미론큐', '싸이토팜') THEN '자사'
						 			 WHEN pp.nick IN ('판토모나맨', '판토모나레이디', '판토모나') then '판토모나' else pp.nick END AS product_name,
								b.qty as product_qty, p.qty as order_qty,
								case when p.order_cs = 0 then p.prd_amount else p.prd_amount * -1 end as prd_amount,
								case when p.order_cs = 0 then 1 else -1 end as order_cnt,
								case when p.order_cs = 0 then b.qty * p.qty else (b.qty * p.qty) * -1 end as out_qty
						FROM	"EZ_Order" as o,
								jsonb_to_recordset(o.order_products) as p(
									name character varying(255),
									product_id character varying(255),
									qty integer, prd_amount integer,
									order_cs integer,
									cancel_date  character varying(255)
								)
								left join "Bundle" as b on (p.product_id = b.order_code)
								left join "Product" as pp on (b.product_id = pp.id)
						WHERE	order_date > '2021-09-01' and order_date < '2023-12-31' AND order_id not in (
							select order_num from "Non_Order")
					) as o
			GROUP BY o.order_date, o.product_name
		) as o on (t.yymmdd = o.yymmdd and t.product = o.product) left join
		(
			SELECT	q.query_date as yymmdd,
					case when p.nick is null then '파이토웨이' else p.nick end as product,
					sum(q.mobile_cnt) as query_sum
			FROM	"Query_Log2" as q left join "Keyword2" as k on (q.keyword = k.keyword)
					left join "Product" as p on (k.product_id = p.id)
			GROUP BY q.query_date, product
		) as k on (t.yymmdd = k.yymmdd and t.product = k.product)
ORDER BY t.yymmdd DESC










SELECT	t.yymmdd, t.product, o.price, o.order_cnt, o.out_qty, k.query_sum, t.gross_target, t.gross_prev, t.calling_target, t.calling_prev, t.conv_target, t.conv_prev,
		t.gross_forecast, t.calling_forecast
FROM
		(
			select 	y.yymm, y.yyww, t.yymmdd, product, gross_target, gross_prev, calling_target, calling_prev, conv_target, conv_prev,
					f.gross2 as gross_forecast, f.calling2 as calling_forecast
			from "Target" as t left join "YMD2" as y on (t.yymmdd = y.yymmdd) left join (
			select * from fn_gross_forecast(30)) as f on (t.yymmdd = f.yymmdd2)
		) as t left join
		(

			SELECT 	order_date, product_name, SUM(price) AS price, SUM(order_cnt) AS order_cnt, SUM(out_qty) AS out_qty
			FROM 	(
						SELECT 	order_date, 
								
									CASE WHEN brand IN ('루테콤', '트리플', '페미론큐', '싸이토팜', '콘디맥스') THEN '자사'
									ELSE brand 
									END AS product_name,	
									
									price, order_cnt, out_qty
						FROM "order4"
					) AS o
			WHERE order_date >= '2020-01-01'
			GROUP BY order_date, product_name
			Order BY order_date DESC

		) as o on (t.yymmdd = o.order_date and t.product = o.product_name) left join
		(
			SELECT	q.query_date as yymmdd,
					case when p.nick is null then '파이토웨이' else p.nick end as product,
					sum(q.mobile_cnt) as query_sum
			FROM	"Query_Log2" as q left join "Keyword2" as k on (q.keyword = k.keyword)
					left join "Product" as p on (k.product_id = p.id)
			GROUP BY q.query_date, product
		) as k on (t.yymmdd = k.yymmdd and t.product = k.product)
ORDER BY t.yymmdd DESC

