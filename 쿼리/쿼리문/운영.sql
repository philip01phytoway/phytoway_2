
-- 쿠팡 매핑 중복 확인
SELECT product2_id
FROM "ad_mapping3"
WHERE channel_no = 5
GROUP BY product2_id
HAVING COUNT(*) > 1


SELECT *
FROM "AD_Coupang"
WHERE product2_id = '85917629844'


SELECT *
FROM "product"



SELECT *
FROM "ad_batch"
WHERE option_id IN ('85917629844', '70553656357')


SELECT *
<<<<<<< HEAD
FROM "content_batch"
WHERE id = '3491'
=======
FROM "warehouse"
















SELECT *
FROM 	"order_batch"
WHERE trans_date = '2023-05-04' AND store = '쿠팡' AND nick = '판토모나하이퍼포머'


SELECT *
FROM 	"order_batch"
WHERE trans_date = '2023-05-05' AND store = '쿠팡' AND nick = '판토모나하이퍼포머'




SELECT store, out_qty --SUM(out_qty)
FROM 	"order_batch"
WHERE trans_date = '2023-05-08' AND nick = '판토모나하이퍼포머' AND order_status <> '취소'
AND store NOT IN ('스마트스토어_풀필먼트', '쿠팡_제트배송')


SELECT * FROM "store"

AND store = '쿠팡'


SELECT * 
FROM "EZ_Order"
WHERE shop_name = '추가발송'




SELECT *
FROM	"EZ_Order" as o
--WHERE o."options" LIKE '%온유%'

LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
WHERE s.ez_store_code IS NULL



SELECT SUM(out_qty)
FROM 	"order_batch"
WHERE trans_date = '2023-05-09' AND store = '쿠팡' AND nick = '판토모나하이퍼포머' AND order_status <> '취소'



출고에는
재고이동, 증정, 판매가 있음.





SELECT *
FROM (
			SELECT *
			FROM "EZ_Order" AS o,																		
								jsonb_to_recordset(o.order_products) AS p(																	
									name CHARACTER VARYING(255),																
									product_id CHARACTER VARYING(255),																
									qty INTEGER, 
									prd_amount INTEGER,	
									prd_supply_price INTEGER,															
									order_cs INTEGER,																
									cancel_date CHARACTER VARYING(255),																
									change_date CHARACTER VARYING(255)																
								)
						LEFT JOIN "bundle" AS b ON (p.product_id = b.ez_code)																	
						LEFT JOIN "product" AS pp ON (b.product_no = pp.no)	
			) AS t
WHERE shop_name = '추가발송'
AND recv_name NOT LIKE '%전현빈%'







>>>>>>> c0fdf1b5179f64b41ca4aae5fc8c77e3bca6f86a





-- 써큐시안 선물세트 분리

SELECT *
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED', 'EXCHANGED', 'CANCELED', 'RETURNED')
AND ("productName" LIKE '%선물%' OR "productOption"	LIKE '%선물%') AND "productName" NOT LIKE '%차가%'
AND n."orderId" NOT IN (SELECT order_num FROM "Non_Order")




SELECT *
FROM "EZ_Order"
WHERE product_name LIKE '%선물%' OR "options" LIKE '%선물%' AND product_name NOT LIKE '%MSM%' AND product_name NOT LIKE '%제중원%'



SELECT *			
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
		) AS o3
LEFT JOIN "store" AS s ON (o3.shop_id = s.ez_store_code)
WHERE product_name LIKE '%선물%' OR "options" LIKE '%선물%' AND product_name NOT LIKE '%MSM%' AND product_name NOT LIKE '%제중원%'

