SELECT 	
			y.yymm, y.yyww, t.order_date, order_date_time,
			key, order_id, order_status,  order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date,

			CASE 
				WHEN order_id <> '' AND phytoway = 'y' THEN
					CASE 
						WHEN ROW_NUMBER() OVER (PARTITION BY t.key ORDER BY t.order_id) = 1 THEN '신규'
						ELSE '재구매'
					END
				ELSE ''
			END AS all_cust_type,
			
			CASE 
				WHEN order_id <> '' AND phytoway = 'y' THEN
					CASE 
						WHEN ROW_NUMBER() OVER (PARTITION BY t.key, brand ORDER BY t.order_id) = 1 THEN '신규'
						ELSE '재구매'
					END
				ELSE ''
			END AS brand_cust_type,
			inflow_path
			
FROM 	(

-- 이지어드민
-- 취소 및 반품 반영
-- 네이버, 쿠팡 제외

-- 정상 주문
SELECT 	
			order_name || order_tel AS KEY,		
			order_id, '주문' as order_status, 

			order_date, order_date_time, order_name, cust_id, order_tel,  recv_name, recv_tel, recv_zip, recv_address,
			s.name AS store, 
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price,  term, '' AS decide_date, '' AS inflow_path

FROM 	(
			SELECT	
						o2.order_id,
						left(order_date, 10) AS order_date,
						order_date AS order_date_time,
						
						o2.order_name, o2.cust_id, 
						CASE
	                 WHEN ((("substring"((o2.order_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o2.order_mobile)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.order_mobile)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.order_mobile)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.order_tel)::text, 1, 3) = '010'::text) OR ("substring"((o2.order_tel)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.order_tel)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.order_tel)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.recv_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o2.recv_mobile)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.recv_mobile)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.recv_mobile)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.recv_tel)::text, 1, 3) = '010'::text) OR ("substring"((o2.recv_tel)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.recv_tel)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.recv_tel)::text, '-'::text, ''::text)
	                 ELSE '000'
            		END AS order_tel,	
						
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
			        
						o2.shop_id,
						
						o2.brand, o2.nick, o2.product_qty, o2.order_qty, o2.product_qty * o2.order_qty AS out_qty,
						CASE 
			         	WHEN ROW_NUMBER() OVER (PARTITION BY o2.order_id ORDER BY o2.order_id) = 1 THEN 1 
			         	ELSE 0 
			       	END AS order_cnt,
						 	
						o2.prd_amount_mod, o2.prd_supply_price,	
								
						order_status, 	
						
						o2.term, o2."options"
			
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
						WHERE	order_date > '2021-09-01' AND order_date < '2023-12-31' 
								AND order_id NOT IN (SELECT order_num FROM "Non_Order")	
								 AND pp.term > 0 AND o.order_name <> '' --AND p.order_cs = 0
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
		AND s.no NOT IN (45, 13, 12)


UNION ALL 


-- 취소 및 반품
SELECT 	
			order_name || order_tel AS KEY, 
			order_id, 

			CASE 
				WHEN order_status BETWEEN 1 AND 2 THEN '취소'
			 	WHEN order_status BETWEEN 3 AND 4 THEN '반품'
			 	WHEN order_status BETWEEN 5 AND 8 THEN '교환'
			END AS order_status,

			cs_date, cs_date_time, order_name, cust_id, order_tel,  recv_name, recv_tel, recv_zip, recv_address,
			s.name AS store, 
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price,  term, '' AS decide_date, '' AS inflow_path

FROM 	(
			SELECT	
						o2.order_id,
						
						CASE 
							WHEN order_status BETWEEN 1 AND 4 THEN left(cancel_date, 10)
							WHEN order_status BETWEEN 5 AND 8 THEN left(change_date, 10)
						END AS cs_date,
						
						CASE 
							WHEN order_status BETWEEN 1 AND 4 THEN cancel_date
							WHEN order_status BETWEEN 5 AND 8 THEN change_date
						END AS cs_date_time,
						
						
						o2.order_name, o2.cust_id, 
						CASE
	                 WHEN ((("substring"((o2.order_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o2.order_mobile)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.order_mobile)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.order_mobile)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.order_tel)::text, 1, 3) = '010'::text) OR ("substring"((o2.order_tel)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.order_tel)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.order_tel)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.recv_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o2.recv_mobile)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.recv_mobile)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.recv_mobile)::text, '-'::text, ''::text)
	                 WHEN ((("substring"((o2.recv_tel)::text, 1, 3) = '010'::text) OR ("substring"((o2.recv_tel)::text, 1, 3) = '050'::text)) AND (REPLACE((o2.recv_tel)::text, '-'::text, ''::text) <> '01000000000'::text)) THEN REPLACE((o2.recv_tel)::text, '-'::text, ''::text)
	                 ELSE '000'
            		END AS order_tel,	
						
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
			        
						o2.shop_id,
						
						o2.brand, o2.nick, o2.product_qty, o2.order_qty, o2.product_qty * o2.order_qty * -1 AS out_qty,
						CASE 
			         	WHEN ROW_NUMBER() OVER (PARTITION BY o2.order_id ORDER BY o2.order_id) = 1 THEN -1 
			         	ELSE 0 
			       	END AS order_cnt,
						 	
						o2.prd_amount_mod * -1 AS prd_amount_mod, o2.prd_supply_price * -1 AS prd_supply_price,	
								
						order_status, 	
						
						o2.term, o2."options"
			
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
						WHERE	order_date > '2021-09-01' AND order_date < '2023-12-31' 
								AND order_id NOT IN (SELECT order_num FROM "Non_Order")	
								 AND pp.term > 0 AND o.order_name <> '' AND p.order_cs <> 0
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
				o3."options" LIKE '%메디%' AND cs_date < '2022-08-23'
			)
		)
		AND s.no NOT IN (45, 12)

UNION ALL 

-- 네이버
-- 정상주문
SELECT 	"ordererName" || "ordererId" AS "key", 
			"orderId", '주문' as order_status, 
			
			LEFT("paymentDate", 10) AS "order_date",
			LEFT("paymentDate", 10) || ' ' || SUBSTRING("paymentDate", 12, 8) AS "order_date_time",
			
			"ordererName", "ordererId", "ordererTel", 	 
			("shippingAddress" ->> 'name')::text AS "recv_name", REPLACE(("shippingAddress" ->> 'tel1')::text, '-', '') AS "recv_tel", ("shippingAddress" ->> 'zipCode')::TEXT AS recv_zip, ("shippingAddress" ->> 'baseAddress')::TEXT AS recv_address, 
			
			CASE 
				WHEN "deliveryAttributeType" = 'ARRIVAL_GUARANTEE' THEN '스마트스토어_풀필먼트'
				ELSE '스마트스토어'
			END AS store,
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			p.brand, p.nick, o.option_qty AS "product_qty", "quantity" AS order_qty, "quantity" * o.option_qty AS "out_qty", 
			CASE 
         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN 1 
         	ELSE 0 
       	END AS order_cnt,
			
			"totalPaymentAmount", "expectedSettlementAmount",
			
			p.term, "decisionDate", n."inflowPath" AS inflow_path
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED', 'EXCHANGED', 'CANCELED', 'RETURNED')	
AND n."orderId" NOT IN (SELECT order_num FROM "Non_Order")

UNION ALL 

-- 네이버
-- cs 주문

SELECT 	"ordererName" || "ordererId" AS "key", 
			"orderId", 
			
			CASE 
				WHEN "productOrderStatus" = 'EXCHANGED' THEN '교환'
				WHEN "productOrderStatus" = 'CANCELED' THEN '취소'
				WHEN "productOrderStatus" = 'RETURNED' THEN '반품'
			END AS order_status, 
			
			CASE 
				WHEN "productOrderStatus" = 'EXCHANGED' THEN LEFT("claimRequestDate", 10)
				WHEN "productOrderStatus" = 'CANCELED' THEN LEFT("cancelCompletedDate", 10)
				WHEN "productOrderStatus" = 'RETURNED' THEN LEFT("returnCompletedDate", 10)
			END AS order_date, 
			
			CASE 
				WHEN "productOrderStatus" = 'EXCHANGED' THEN LEFT("claimRequestDate", 10) || ' ' || SUBSTRING("claimRequestDate", 12, 8)
				WHEN "productOrderStatus" = 'CANCELED' THEN LEFT("cancelCompletedDate", 10) || ' ' || SUBSTRING("cancelCompletedDate", 12, 8)
				WHEN "productOrderStatus" = 'RETURNED' THEN LEFT("returnCompletedDate", 10) || ' ' || SUBSTRING("returnCompletedDate", 12, 8)
			END AS order_date_time, 
			
			"ordererName", "ordererId", "ordererTel", 	 
			("shippingAddress" ->> 'name')::text AS "recv_name", REPLACE(("shippingAddress" ->> 'tel1')::text, '-', '') AS "recv_tel", ("shippingAddress" ->> 'zipCode')::TEXT AS recv_zip, ("shippingAddress" ->> 'baseAddress')::TEXT AS recv_address, 
			
			CASE 
				WHEN "deliveryAttributeType" = 'ARRIVAL_GUARANTEE' THEN '스마트스토어_풀필먼트'
				ELSE '스마트스토어'
			END AS store,
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			p.brand, p.nick, o.option_qty AS "product_qty", "quantity" AS order_qty, "quantity" * o.option_qty -1 AS "out_qty", 
			CASE 
         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN -1 
         	ELSE 0 
       	END AS order_cnt,
			
			"totalPaymentAmount" * -1 AS "totalPaymentAmount", "expectedSettlementAmount" * -1 AS "expectedSettlementAmount",
			
			p.term, "decisionDate", n."inflowPath" AS inflow_path
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED')	
AND n."orderId" NOT IN (SELECT order_num FROM "Non_Order")


UNION ALL 
	
-- 쿠팡
-- 주문건
SELECT 	
			CASE 
			    WHEN ("orderer" ->> 'name') IS NULL 
			        THEN ("receiver" ->> 'name')
			    ELSE ("orderer" ->> 'name')
			END 
			||
			CASE 
			    WHEN ("orderer" ->> 'email') IS NULL 
			        THEN 
			            CASE 
			                WHEN ("orderer" ->> 'safeNumber') IS NULL 
			                    THEN ("receiver" ->> 'postCode')
			                ELSE REPLACE(("orderer" ->> 'safeNumber'), '-', '')
			            END 
			    ELSE ("orderer" ->> 'email')
			END AS KEY,

			"orderId"::text, '주문' as order_status, 
			
			LEFT("paidAt", 10) AS order_date,
			REPLACE("paidAt", 'T', ' ') AS "order_date_time",
			
			CASE 
				WHEN 
					("orderer" ->> 'name') IS NULL THEN ("receiver" ->> 'name')
				ELSE ("orderer" ->> 'name')
			END AS "ordererName",
			("orderer" ->> 'email') AS "ordererEmail",
			REPLACE(("orderer" ->> 'safeNumber'), '-', '') AS "ordererTel",
		 	 
			("receiver" ->> 'name') AS "receiverName",
			REPLACE(("receiver" ->> 'safeNumber'), '-', '') AS "receiverTel", -- 이건 case when 처리 필요한지?
			("receiver" ->> 'postCode') AS "receiverZip",
			("receiver" ->> 'addr1') AS "receiverAddress",
			
			'쿠팡' AS store,
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			pp.brand, pp.nick, op.qty AS "product_qty", p."shippingCount" AS "order_qty", op.qty * p."shippingCount" AS "out_qty",
			CASE 
         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN 1 
         	ELSE 0 
       	END AS order_cnt,
			
			p."orderPrice" - p."discountPrice" AS "realPrice", 0 AS "expectedSettlementAmount", 
			
			pp.term, "confirmDate", '' AS inflow_path
			
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255),
			"shippingCount" INTEGER,
			"cancelCount" INTEGER,
			"orderPrice" INTEGER,
			"discountPrice" INTEGER,
			"confirmDate" 	CHARACTER varying(255)															
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
WHERE o."orderId"::text NOT IN (SELECT order_num FROM "Non_Order")
AND "cancelCount" = 0	


UNION ALL 


-- b2b
-- 22년1월~23년2월 정산 자료
SELECT 	'' AS KEY, '' AS order_id, '' AS order_status, order_date, order_date || ' 00:00:00' AS order_date_time, '' AS order_name, '' AS cust_id, '' AS order_tel,
			'' AS recv_name, '' AS recv_tel, '' AS recv_zip, '' AS recv_address,
			
			s.name AS store,
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			p.brand, p.nick, 1 AS product_qty, 1 AS order_qty, 
			
			CASE WHEN gross < 0 THEN LEAST(qty, -qty)
			ELSE qty
			END AS out_qty,
			
			CASE WHEN gross < 0 THEN -1
			ELSE 1 
			END AS order_cnt, 
			
			gross AS price, gross AS price2, 
			0 AS term, '' AS decide_date, '' AS inflow_path
FROM "b2b_gross" AS b
LEFT JOIN "store" AS s ON (b.store_no = s.no)
LEFT JOIN "product" AS p ON (b.product_no = p.no)
WHERE s.no <> 25


UNION ALL 

-- b2b
-- 이지어드민으로 관리되는 b2b 매출
SELECT 	'' AS KEY, '' AS order_id, '' AS order_status, "substring"((o.order_date)::text, 1, 10) AS order_date,'' AS order_date_time, '' AS order_name, '' AS cust_id, '' AS order_tel, 
			'' AS recv_name, '' AS recv_tel, '' AS recv_zip, '' AS recv_address, 
			
			CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
			WHEN o."options" LIKE '%온유%' THEN '온유약국'
			ELSE s.name
			END AS store,
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			o.brand, o.nick, 1 AS product_qty, 1 AS order_qty, o.out_qty, 1 AS order_cnt,
			o.amount AS price, o.supply_price, 0 AS term, '' AS decide_date, '' AS inflow_path
			
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


UNION ALL 

--플레이오토
SELECT 	order_name || order_tel AS KEY, '' AS order_id, '주문' as order_status, order_date, order_date || ' 00:00:00' AS order_date_time, order_name, '' AS cust_id, order_tel, 
			order_name AS recv_name, order_tel AS recv_tel, order_zip AS recv_zip, '' AS recv_address, 
			
			o.shop_name AS store,
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			p.brand, p.nick, b.qty AS product_qty, order_qty, b.qty * order_qty AS out_qty,
			
			CASE WHEN order_qty > 0 THEN 1
			ELSE -1
			END AS order_cnt,
			
			order_price AS price, order_price AS price2, p.term, '' AS decide_date, '' AS inflow_path
			
FROM	"PA_Order2" as o 
left join "Bundle" as b on (o.order_code = b.order_code)																					
left join "product" as p on (b.product_id = p.no)	
WHERE o.shop_name NOT IN ('스토어팜(파이토웨이)', '쿠팡')

) AS t
LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)




				