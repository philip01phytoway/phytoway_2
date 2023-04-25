-- 대시보드



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
			WHERE pp.term > 0
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