
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






-- B2B
SELECT yymm, yyww, order_date, store, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE order_id = '' AND yyww = '2023-20'
GROUP BY yymm, yyww, order_date, store
--Order BY order_date DESC




-- B2B
SELECT SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE order_id = '' AND yyww = '2023-20' AND store <> '쿠팡_로켓배송'

--Order BY order_date DESC



SELECT *
FROM "order_batch"
WHERE store = '스마트스토어_풀필먼트' AND order_date_time BETWEEN '2023-05-17 10:00:00'  AND '2023-05-18 10:00:00'
AND nick IN ('써큐시안', '판토모나맨', '판토모나레이디') AND 






SELECT *
FROM "order_batch"
WHERE store = '온유약국'



'마켓컬리'


SELECT *
FROM "EZ_Order"
WHERE shop_id = 10286

[{"qty": "150", "name": "판토모나 비오틴 하이퍼포머, 1개", "brand": "", "barcode": "PRMD00135", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "528070", "order_cs": "0", "prd_amount": "4169550", "product_id": "00135", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "4169550"}]


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


SELECT dead_date, COUNT(DISTINCT key) AS 재구매잠재고객수
FROM "order_batch"
WHERE dead_date >='2022-01'
GROUP BY dead_date


SELECT dead_date, count(distinct key) as 재구매고객수
FROM "order_batch"
where dead_date >='2022-01'
group by dead_date




-- 만료고객수
-- 만료일자 기간 수정하여 사용
SELECT left(dead_date, 7) AS dead_month, COUNT(DISTINCT KEY)
FROM "order_batch"
WHERE dead_date <> ''
GROUP BY left(dead_date, 7)
Order BY left(dead_date, 7) desc




-- 재구매고객수
-- 만료일자 기간 수정하여 사용
SELECT  *-- SUM(order_cnt), count(distinct key)
FROM "order_batch"
WHERE dead_date BETWEEN '2023-03-08' AND '2023-03-14' AND (next_order_date BETWEEN order_date AND dead_date)
Order BY KEY, order_cnt


SELECT *
FROM "order_batch"
WHERE KEY = '강미나morn****'


SELECT *
FROM "order_batch"
WHERE order_id = '2023043016797671'


SELECT *
FROM "EZ_Order"
WHERE order_id = '2023043016797671'


SELECT *
FROM "order_batch"
WHERE order_id = '2023021122201071'


store LIKE '%스마트스토어%' AND decide_date <> ''

SELECT * FROM "ad_mapping3"


SELECT *
FROM "ad_batch"
WHERE channel IS NULL --= '네이버'
ORDER BY yymmdd ASC
LIMIT 1000


SELECT * 
FROM "AD_Naver" 
Order BY "A"
LIMIT 10000


Order BY yymmdd LIMIT 10000


256

-- 재구매건수
-- 만료일자 기간 수정하여 사용
SELECT SUM(order_cnt) AS reorder_cnt
FROM "order_batch"
WHERE dead_date BETWEEN '2023-03-08' AND '2023-03-14' AND (next_order_date BETWEEN order_date AND dead_date)



SELECT *
FROM "order_batch"
WHERE KEY = '강윤희blue****'




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





SELECT *--, rank() over(partition BY KEY Order BY order_date_time) AS rank
FROM "order_batch"
WHERE yymm = '2023-04' AND all_cust_type = '신규'
Order BY KEY




SELECT yymm, SUM(order_cnt)
FROM "order_batch"
WHERE all_cust_type = '신규' AND order_cnt < 0
GROUP BY yymm
Order BY yymm desc

KEY = '김영철17137'

GROUP BY yyww
ORDER BY yyww DESC





SELECT yyww, all_cust_type, SUM(order_cnt) AS order_cnt
FROM "order_batch"
WHERE all_cust_type <> ''
GROUP BY yyww, all_cust_type
Order BY yyww desc




SELECT *
FROM "stock_log" AS s
LEFT JOIN "bundle" AS b ON (s.product_id = b.ez_code)
LEFT JOIN "product" AS p ON (b.product_no = p.no)
WHERE p.nick = '판토모나하이퍼포머'
Order BY crdate desc


SELECT *
FROM "stock_log"



SELECT *
FROM "bundle"



5062 / 5100


SELECT * --SUM(order_cnt), COUNT(DISTINCT KEY)
FROM "order_batch"
WHERE all_cust_type = '신규'-- AND yymm = '2023-04'
AND order_cnt < 0


SELECT * --SUM(order_cnt), COUNT(DISTINCT KEY)
FROM "order_batch"
WHERE all_cust_type = '재구매'-- AND yymm = '2023-04'
AND order_cnt < 0



SELECT *
FROM 	(
			SELECT 	*, 
						rank() over(partition BY KEY, order_status Order BY order_date_time) AS rank
			FROM "order_batch"
			WHERE KEY = '고재준kojj****'
		) AS t
WHERE order_status = '취소' AND all_cust_type = '재구매' AND rank = 1



SELECT *
FROM "order_batch"
WHERE order_id = '2022062740088761'

SELECT *
FROM "naver_order_product"
WHERE "orderId" = '2022062740088761'



SELECT *
FROM 	(
			SELECT 	*, 
						rank() over(partition BY KEY, order_status Order BY order_date_time) AS rank
			FROM "order_batch"
			
		) AS t
WHERE order_status IN ('취소', '반품') AND all_cust_type = '재구매' AND rank = 1




SELECT *
FROM 	(
			SELECT 	*, 
						rank() over(partition BY KEY, order_status Order BY order_date_time) AS rank
			FROM "order_batch"
			
		) AS t
WHERE order_status IN ('취소', '반품') AND all_cust_type = '신규' AND rank > 1



SELECT *
FROM "cost_marketing"


SELECT *
FROM "cost_product"




SELECT *
FROM "order_batch"
WHERE all_cust_type <> ''












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

