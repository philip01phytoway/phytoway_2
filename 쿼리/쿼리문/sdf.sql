-- 이지어드민
-- 취소 및 반품 반영
-- 네이버, 쿠팡 제외

-- 정상 주문
SELECT 	KEY, order_id, '주문' as order_status, 

			order_date, order_date_time, order_name, cust_id, order_tel,  recv_name, recv_tel, recv_zip, recv_address,
			s.name AS store, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price,  term, '' AS decide_date

FROM 	(
			SELECT	
						(o2.order_name || REPLACE(o2.recv_zip, '-', '')) AS key, 
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
SELECT 	KEY, order_id, 

			CASE 
				WHEN order_status BETWEEN 1 AND 2 THEN '취소'
			 	WHEN order_status BETWEEN 3 AND 4 THEN '반품'
			 	WHEN order_status BETWEEN 5 AND 8 THEN '교환'
			END AS order_status,

			cs_date, cs_date_time, order_name, cust_id, order_tel,  recv_name, recv_tel, recv_zip, recv_address,
			s.name AS store, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price,  term, '' AS decide_date

FROM 	(
			SELECT	
						(o2.order_name || REPLACE(o2.recv_zip, '-', '')) AS key, 
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
		AND s.no NOT IN (45, 13, 12)
													
													
													
													





SELECT *
FROM "EZ_Order"
WHERE order_id = '2209161531338493'


'20220415-0000097'


'2022051529851291'

[{"qty": "1", "name": "싸이토팜 관절 식물성 엠에스엠 MSM 100, 1개", "brand": "", "barcode": "PRMD00157", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "506158", "order_cs": "0", "prd_amount": "54330", "product_id": "00157", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "49391"}]









-- 정상주문

SELECT 	"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "key", 
			"orderId", '주문' as order_status, 
			
			LEFT("paymentDate", 10) AS "order_date",
			LEFT("paymentDate", 10) || ' ' || SUBSTRING("paymentDate", 12, 8) AS "order_date_time",
			
			"ordererName", "ordererId", "ordererTel", 	 
			("shippingAddress" ->> 'name')::text AS "recv_name", REPLACE(("shippingAddress" ->> 'tel1')::text, '-', '') AS "recv_tel", ("shippingAddress" ->> 'zipCode')::TEXT AS recv_zip, ("shippingAddress" ->> 'baseAddress')::TEXT AS recv_address, 
			
			CASE 
				WHEN "deliveryAttributeType" = 'ARRIVAL_GUARANTEE' THEN '스마트스토어_풀필먼트'
				ELSE '스마트스토어'
			END AS store,
			
			p.brand, p.nick, o.option_qty AS "product_qty", "quantity" AS order_qty, "quantity" * o.option_qty AS "out_qty", 
			CASE 
         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN 1 
         	ELSE 0 
       	END AS order_cnt,
			
			"totalPaymentAmount", "expectedSettlementAmount",
			
			p.term, "decisionDate"
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED', 'EXCHANGED', 'CANCELED', 'RETURNED')	


UNION ALL 


-- cs 주문

SELECT 	"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "key", 
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
			
			p.brand, p.nick, o.option_qty AS "product_qty", "quantity" AS order_qty, "quantity" * o.option_qty -1 AS "out_qty", 
			CASE 
         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN -1 
         	ELSE 0 
       	END AS order_cnt,
			
			"totalPaymentAmount" * -1 AS "totalPaymentAmount", "expectedSettlementAmount" * -1 AS "expectedSettlementAmount",
			
			p.term, "decisionDate"
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED')	


	

-- 1. 주문건
SELECT 	("orderer" ->> 'name') || ("receiver" ->> 'postCode') AS KEY,
			"orderId"::text, '주문' as order_status, 
			
			LEFT("paidAt", 10) AS order_date,
			REPLACE("paidAt", 'T', ' ') AS "order_date_time",
			
			("orderer" ->> 'name') AS "ordererName",
			("orderer" ->> 'email') AS "ordererEmail",
			("orderer" ->> 'safeNumber') AS "ordererTel",
		 	 
			("receiver" ->> 'name') AS "receiverName",
			("receiver" ->> 'safeNumber') AS "receiverTel", -- 이건 case when 처리 필요한지?
			("receiver" ->> 'postCode') AS "receiverZip",
			("receiver" ->> 'addr1') AS "receiverAddress",
			
			'쿠팡' AS store,
			pp.brand, pp.nick, op.qty AS "product_qty", p."shippingCount" AS "order_qty", op.qty * p."shippingCount" AS "out_qty",
			CASE 
         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN 1 
         	ELSE 0 
       	END AS order_cnt,
			
			p."orderPrice" - p."discountPrice" AS "realPrice", 0 AS "expectedSettlementAmount", 
			
			pp.term, "confirmDate"
			
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
--WHERE "cancelCount" = 0			



-- 2. 교집합 cs건
SELECT *
FROM 	(
			SELECT 	("orderer" ->> 'name') || ("receiver" ->> 'postCode') AS KEY,
						"orderId", '주문' as order_status, 
						
						LEFT("paidAt", 10) AS order_date,
						REPLACE("paidAt", 'T', ' ') AS "order_date_time",
						
						("orderer" ->> 'name') AS "ordererName",
						("orderer" ->> 'email') AS "ordererEmail",
						("orderer" ->> 'safeNumber') AS "ordererTel",
					 	 
						("receiver" ->> 'name') AS "receiverName",
						("receiver" ->> 'safeNumber') AS "receiverTel", -- 이건 case when 처리 필요한지?
						("receiver" ->> 'postCode') AS "receiverZip",
						("receiver" ->> 'addr1') AS "receiverAddress",
						
						'쿠팡' AS store,
						pp.brand, pp.nick, op.qty AS "product_qty", p."shippingCount" AS "order_qty", op.qty * p."shippingCount" AS "out_qty",
						CASE 
			         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN 1 
			         	ELSE 0 
			       	END AS order_cnt,
						
						p."orderPrice" - p."discountPrice" AS "realPrice", 0 AS "expectedSettlementAmount", 
						
						pp.term, "confirmDate"
						
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
		) AS o2
LEFT JOIN "coupang_return_cancel" AS r ON (o2."orderId" = r."orderId")			
WHERE r."orderId" IS NOT NULL AND "receiptType" = 'RETURN'		


-- 3. 여집합 cs건
SELECT * --o."orderId" AS "coupang_order", r."orderId" AS "coupang_return_cancel"
FROM "coupang_return_cancel" AS r
LEFT JOIN "coupang_order" AS o ON (r."orderId" = o."orderId")
WHERE o."orderId" IS NULL AND "receiptType" = 'RETURN' AND "receiptStatus" = 'RETURNS_COMPLETED'

				
				
SELECT *
FROM "coupang_return_cancel" 			
WHERE "receiptType" = 'RETURN'									