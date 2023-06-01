-- 1. 이지어드민

-- 주문
SELECT 	
			seq, 
			CASE 
				WHEN order_tel LIKE '050%' THEN order_name || recv_zip
				ELSE order_name || order_tel 
			END AS KEY,		
			order_id, '주문' as order_status, 

			order_date, order_date_time, order_name, cust_id, order_tel,  recv_name, recv_tel, recv_zip, recv_address,
			s.name AS store, 
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price,  term, '' AS decide_date, '' AS inflow_path, '' AS account,
			onnuri_code, onnuri_name, onnuri_type, left(trans_date, 10) AS invoice_date, left(trans_date_pos, 10) AS trans_date

FROM 	(
			SELECT		
						seq, o2.order_id,
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
						
						o2.term, o2."options",
						
						o2.onnuri_code, o2.onnuri_name, o2.onnuri_type, trans_date, trans_date_pos
			
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
						WHERE order_id NOT IN (SELECT order_num FROM "Non_Order")	
							  AND pp.term > 0 --AND p.order_cs in (0, 3, 4)
							  and o.trans_date_pos <> ''
					) AS o2
		) AS o3
LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
WHERE s.no NOT IN (45, 25)
		

		
union all 


-- 취소 및 반품
SELECT 	
			seq,
			CASE 
				WHEN order_tel LIKE '050%' THEN order_name || recv_zip
				ELSE order_name || order_tel 
			END AS KEY,	
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
			brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price,  term, '' AS decide_date, '' AS inflow_path, '' AS account,
			onnuri_code, onnuri_name, onnuri_type, left(trans_date, 10) as invoice_date, cs_date AS trans_date

FROM 	(
			SELECT	
						seq, o2.order_id,
						
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
						
						o2.term, o2."options",
						
						o2.onnuri_code, o2.onnuri_name, o2.onnuri_type, trans_date, trans_date_pos
			
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
						WHERE order_id NOT IN (SELECT order_num FROM "Non_Order")	
							  AND pp.term > 0 AND p.order_cs <> 0
							  and o.trans_date_pos <> ''
					) AS o2
		) AS o3
LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
WHERE s.no NOT IN (45, 25)
		

union all 

-- 2.
-- 네이버
-- 정상주문
SELECT 	
			0 as seq,
			"ordererName" || "ordererId" AS "key", 
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
			
			p.term, "decisionDate", n."inflowPath" AS inflow_path, '' AS account,
			
			onnuri_code, onnuri_name, onnuri_type, '' as invoice_date, LEFT("sendDate", 10) AS trans_date
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED', 'EXCHANGED', 'CANCELED', 'RETURNED')	
AND n."orderId" NOT IN (SELECT order_num FROM "Non_Order")
AND "deliveryAttributeType" = 'ARRIVAL_GUARANTEE'

UNION ALL 

-- 네이버
-- 정상주문 & 결합상품
SELECT 	
			0 as seq,
			"ordererName" || "ordererId" AS "key", 
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
			
			0 as "totalPaymentAmount", 0 as "expectedSettlementAmount",
			
			p.term, "decisionDate", n."inflowPath" AS inflow_path, '' AS account,
			
			onnuri_code, onnuri_name, onnuri_type, '' as invoice_date, LEFT("sendDate", 10) AS trans_date
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option_combined" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED', 'EXCHANGED', 'CANCELED', 'RETURNED') and o."option_code" is not null
AND n."orderId" NOT IN (SELECT order_num FROM "Non_Order")	
AND "deliveryAttributeType" = 'ARRIVAL_GUARANTEE'
	
union all 	
	
-- 네이버
-- cs 주문

SELECT 	
			0 as seq,
			"ordererName" || "ordererId" AS "key", 
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
			p.brand, p.nick, o.option_qty AS "product_qty", "quantity" AS order_qty, "quantity" * o.option_qty * -1 AS "out_qty", 
			CASE 
         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN -1 
         	ELSE 0 
       	END AS order_cnt,
			
			"totalPaymentAmount" * -1 AS "totalPaymentAmount", "expectedSettlementAmount" * -1 AS "expectedSettlementAmount",
			
			p.term, "decisionDate", n."inflowPath" AS inflow_path, '' AS account,
			
			onnuri_code, onnuri_name, onnuri_type, '' as invoice_date,
			
			CASE 
				WHEN "productOrderStatus" = 'EXCHANGED' THEN LEFT("claimRequestDate", 10)
				WHEN "productOrderStatus" = 'CANCELED' THEN LEFT("cancelCompletedDate", 10)
				WHEN "productOrderStatus" = 'RETURNED' THEN LEFT("returnCompletedDate", 10)
			END AS trans_date
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED')	
AND n."orderId" NOT IN (SELECT order_num FROM "Non_Order")
AND "deliveryAttributeType" = 'ARRIVAL_GUARANTEE'

union all 
	
-- 네이버
-- cs 주문 & 결합상품
SELECT 	
			0 as seq,
			"ordererName" || "ordererId" AS "key", 
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
			p.brand, p.nick, o.option_qty AS "product_qty", "quantity" AS order_qty, "quantity" * o.option_qty * -1 AS "out_qty", 
			CASE 
         	WHEN ROW_NUMBER() OVER (PARTITION BY "orderId" ORDER BY "orderId") = 1 THEN -1 
         	ELSE 0 
       	END AS order_cnt,
			
			"totalPaymentAmount" * -1 AS "totalPaymentAmount", "expectedSettlementAmount" * -1 AS "expectedSettlementAmount",
			
			p.term, "decisionDate", n."inflowPath" AS inflow_path, '' AS account,
			
			onnuri_code, onnuri_name, onnuri_type, '' as invoice_date,
			
			CASE 
				WHEN "productOrderStatus" = 'EXCHANGED' THEN LEFT("claimRequestDate", 10)
				WHEN "productOrderStatus" = 'CANCELED' THEN LEFT("cancelCompletedDate", 10)
				WHEN "productOrderStatus" = 'RETURNED' THEN LEFT("returnCompletedDate", 10)
			END AS trans_date
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option_combined" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') and o."option_code" is not null	
AND n."orderId" NOT IN (SELECT order_num FROM "Non_Order")	
AND "deliveryAttributeType" = 'ARRIVAL_GUARANTEE'

union all 


-- 3. 쿠팡 제트배송
SELECT 
			0 AS seq, '' AS KEY, '' AS order_id, '주문' AS order_status, s.reg_date AS order_date, s.reg_date || ' 00:00:00' AS order_date_time, '' AS order_name, '' AS cust_id, '' AS order_tel,
			'' AS recv_name, '' AS recv_tel, '' AS recv_zip, '' AS recv_address,
			
			'쿠팡_제트배송' AS store,
			
			CASE 
				WHEN brand = '기타' THEN 'n'
				ELSE 'y'
			END AS phytoway,
			p.brand, p.nick, op.qty AS product_qty, net_sales_cnt AS order_qty, op.qty * net_sales_cnt AS out_qty,
			net_sales_cnt AS order_cnt, 
			
			net_sales_price AS price, 0 AS price2, 
			0 AS term, '' AS decide_date, '' AS inflow_path, s.account,
			
			onnuri_code, onnuri_name, onnuri_type, '' as invoice_date, s.reg_date AS trans_date
			
FROM "coupang_sales" AS s
LEFT JOIN "coupang_option" AS op ON (s.option_id = op."option")
LEFT JOIN "product" AS p ON (op.product_no = p.no)
WHERE sales_type = '로켓그로스'
