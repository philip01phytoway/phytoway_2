


-- 마케팅 비용은 컨텐츠와 기타로 나뉨.
-- 각각 보고서를 만들면 됨.

-- 컨텐츠부터.


-- 유튜브는 매핑 다시 해야 함
-- id가 아니라 키워드로 매핑해야 해서.


SELECT order_date, store, SUM(prd_amount_mod)
FROM "order_batch"
GROUP BY order_date, store
Order BY order_date desc


SELECT *
FROM "naver_order_product"


SELECT order_date, inflow_path, COUNT(DISTINCT order_id)
FROM "order_batch"
WHERE store = '스마트스토어_풀필먼트'
GROUP BY order_date, inflow_path
Order BY order_date desc




옵션별 이지어드민 상품코드를 Bundle 테이블 매핑 후 Bundle 테이블에 Product 테이블을 매핑하고 있기 때문에
옵션별로 상품코드를 따지 않고 상품 하나로 통합한다면?
물론 그래도 상품 알 수 있고, 주문서에 있는 qty로 수량도 알 수 있긴 한데.
그럼 order3 만들어야 함.
그럼 qty에 product_qty랑 order_qty 다 반영이 되는 거지?
1개 짜리를 3개 시키면 qty = 3으로 나오는거지?


--
store 연결해서 b2b는 제외하고
order3 만들고
Customer_Zip4 만들자.


-- customer_zip4
-- 상품코드 반영
-- b2b 제외
-- 자사몰 네이버페이 반영  


가설 : 
B2B를 제외하면서
메디에서 사고 스스, 쿠팡에서 재구매한 고객들을
B2C 신규고객으로 측정했기 때문에 신규 매출이 늘었을 것이다.

그럼, 2022년에 메디에서 첫구매했고 2023년에 스스, 쿠팡에서 재구매한 고객들이 얼마나 되는지 알아보자.

데이터분석가가 일하는 방법은 이미 circula 공식으로 나와있지 않나?
그것도 책의 첫 장에 나오는 건데.
그냥 그걸 따라서 일하는게 일 잘하는거 아닐까?
중요한 내용이 책의 첫 장에 나올 확률이 높겠지.
 


사은품이 나가면 2행으로 찍힌다.
prd_amount도 중복으로 찍힌다.
그럼 사은품은 제거하는게 맞고.

근데 자사몰 사은품 말고
스스 사은품은 어떻게 찍히지?

그거랑 한 주문에 2개 상품 주문시 어떻게 찍히지?

사은품이 order_products에 포함되지 않는 것도 있군.

사은품으로 2개 찍히는 경우도 약통이라면 필터링이 됨.
실제 제품이라도 사은품인 경우 term은 찍히는데 prd_amount는 0으로 찍힘.

이제 문제는 교차구매가 어떻게 찍히냐는 것.

교차동시구매의 경우 주문번호는 같은데 각 행으로 찍힘
사은품의 경우 주문번호는 같고 각 행으로 찍히는데 가격은 0으로 찍힘.

목요일 출고부터 상품코드 1개입로 나가고,
어차피 product_qty = 1이니까 쿼리문 안바꿔도 되겠다.

매칭을 출고 수량에 맞게 해야 함.


같은 주문번호 안에서 여러개의 옵션을 주문했을 경우
주문번호는 같을지라도 관리번호는 옵션별로 다르게 찍힌다.
즉, 판토모나 남성용 여성용을 같은 주문번호에서 구매했을 시 이지어드민에 다른 관리번호로 찍힌다.
그런데 옵션 안에 판토모나 남성용과 여성용이 같은 묶음이라면?
그런 경우가 있나?
그런 경우일 때는 어떻게 찍히나?

[{"qty": "1", "name": "판토모나 비오틴 플러스 맥스 남성용, 4개 + 페미론큐 엘라스틴 콜라겐, 1개", "brand": "", "barcode": "PRMD00175", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "395960", "order_cs": "0", "prd_amount": "159000", "product_id": "00175", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "150049"}, {"qty": "1", "name": "페미론큐 엘라스틴 콜라겐, 1개", "brand": "", "barcode": "00063", "is_gift": "1", "link_id": "", "options": "", "prd_seq": "396229", "order_cs": "0", "prd_amount": "0", "product_id": "00063", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "0"}]
만약 사은품으로 나갔을 경우 prd_amount가 0이므로 걸러지고, 각 행으로 
만약 결합상품인 경우 00184, 00182


사은품 약통은 각 상품별로 order_products에 찍히지만 
판토모나 결합상품 (00182, 00184)일 땐 상품별로 안찍히네?
이건 이지어드민 설정에서 기인하는 것 같고,
이거 정확히 알아놔야 대처할 수 있을 거 같은데.



SELECT yymm, channel, store, brand, nick, owned_keyword,ad_type,campaign_type,adgroup, SUM(cost)AS cost, SUM(imp_cnt)AS 노출수, SUM(click_cnt) AS 클릭수, SUM(order_cnt) AS 전환수, SUM(order_price) AS 전환매출
FROM "ad_batch"
WHERE brand NOT IN ('기타','자사') AND channel='구글'
GROUP BY yymm, channel, store, brand, nick, owned_keyword,ad_type,campaign_type,adgroup
ORDER BY yymm DESC

select *,
	CASE WHEN (Channel = '메타' OR Channel = '구글') AND yymmdd <= '2023-02-09' THEN cost * 1.1
ELSE cost
END AS cost_markup
FROM "ad_batch"

SELECT * FROM "ad_batch" WHERE channel = '구글'


SELECT yymm, channel, SUM(cost)AS cost
FROM "ad_batch"
WHERE brand = '판토모나'
GROUP BY yymm, channel
ORDER BY yymm DESC

SELECT * 
FROM "ad_batch"
WHERE channel = '구글'


SELECT *
FROM "ad_google3"

SELECT DISTINCT adgroup_id
FROM "ad_mapping3"
WHERE channel_no = 2


SELECT *
FROM "ad_google3" AS g
LEFT JOIN "ad_mapping3" AS m ON (g.adgroup_id = m.adgroup_id)
WHERE g.campaign = '실적 최대화_파이토웨이 셋팅'


SELECT *
FROM "order_batch"
LIMIT 100000		

SELECT *
FROM "ad_batch"
WHERE channel = '네이버' AND yymmdd = '2023-04-01' AND keyword = '비오틴효능'


SELECT *
FROM "AD_Naver"
WHERE reg_date = '2023-04-01' AND "F" = '비오틴효능'

LIMIT 100
	
	
SELECT p.nick AS nick, expiration_date, SUM(received_qty) AS received_qty
FROM "product_received" AS r
LEFT JOIN "product" AS p ON (r.product_no = p.no)
GROUP BY p.nick, expiration_date



SELECT yymm, yyww, order_date, brand, nick, SUM(out_qty) AS out_qty
FROM "order_batch"
GROUP BY yymm, yyww, order_date, brand, nick
Order BY order_date DESC, brand DESC
LIMIT 1000




SELECT I.상품코드, I.유통기한, SUM(I.입고수량 - COALESCE(O.누적출고수량, 0)) AS 재고수량
FROM 입고테이블 I
LEFT JOIN (
    SELECT T1.상품코드, T1.유통기한, T1.입고일, SUM(T2.출고수량) AS 누적출고수량
    FROM 입고테이블 T1
    LEFT JOIN 출고테이블 T2
    ON T1.상품코드 = T2.상품코드 AND T1.유통기한 = T2.유통기한 AND T1.입고일 >= T2.출고일
    GROUP BY T1.상품코드, T1.유통기한, T1.입고일
) AS O
ON I.상품코드 = O.상품코드 AND I.유통기한 = O.유통기한 AND I.입고일 = O.입고일
GROUP BY I.상품코드, I.유통기한




SELECT * FROM "ad_mapping3"


SELECT * 
FROM "Query_Log2" AS q
LEFT JOIN "Keyword2" k ON (q.keyword = k.keyword)
WHERE k.keyword IS NULL 




SELECT job_date, "sending_warehouse", "receiving_warehouse", "job_mod", "type", nick, SUM(recv_qty) AS recv_qty
FROM 	(         
			SELECT 	
						CASE 
							WHEN job = '입고' AND "type" = '정상' THEN '제조사'
							WHEN job = '배송' AND "type" = '정상' THEN '코린트'
							WHEN job = '출고' AND "type" = '정상' THEN '코린트'
							WHEN job = '반품입고' AND "type" = '정상' THEN ez_store_name
							WHEN job = '반품입고' AND "type" = '불량' THEN ez_store_name
						END AS "sending_warehouse", 
						
						CASE 
							WHEN job = '입고' AND "type" = '정상' THEN '코린트' 
							WHEN job = '배송' AND "type" = '정상' THEN ez_store_name
							WHEN job = '출고' AND "type" = '정상' THEN '네이버풀필먼트'
							WHEN job = '반품입고' AND "type" = '정상' THEN '코린트'
							WHEN job = '반품입고' AND "type" = '불량' THEN '코린트'
						END AS "receiving_warehouse", 
						
						CASE 
							WHEN job = '입고' AND "type" = '정상' THEN '입고'
							WHEN job = '배송' AND "type" = '정상' AND ez_store_name <> 'B2B_제트배송' THEN '출고'
							WHEN job = '출고' AND "type" = '정상' THEN '재고이동'
							WHEN job = '배송' AND "type" = '정상' AND ez_store_name = 'B2B_제트배송' THEN '재고이동'
							WHEN job = '반품입고' AND "type" = '정상' THEN '반품'
							WHEN job = '반품입고' AND "type" = '불량' THEN '반품'
						END AS "job_mod", 
						
						"type", LEFT(job_date, 10) AS job_date, p.nick, s.qty * b.qty AS recv_qty, 
						
						CASE 
							WHEN job = '입고' AND "type" = '정상' THEN LEFT((job_date::DATE + INTERVAL '1 year')::TEXT, 10)
						END AS "exp_date"
						
			FROM "stock_ez" AS s
			LEFT JOIN "bundle" AS b ON (s.ez_product_code = b.ez_code)
			LEFT JOIN "product" AS p ON (b.product_no = p.no)
		) AS t
GROUP BY job_date, "sending_warehouse", "receiving_warehouse", "job_mod", "type", nick



SELECT SUM(qty)
FROM "stock_ez"
WHERE job = '입고'



SELECT DISTINCT campaign, adgroup
FROM "ad_batch"
WHERE channel IS NULL AND campaign LIKE '%판토모나%'


SELECT *
FROM "ad_batch"
WHERE campaign = 'S_판토모나'




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


-- 재고현황


-- 1. 입고 테이블 생성

SELECT "no", brand, nick
FROM "product"

-- 2. 재고이동 테이블 생성



SELECT * 
FROM "order_batch" 
WHERE onnuri_type = '판매분매입'


SELECT *
FROM "stock_recv"

SELECT *
FROM "stock_trans"


SELECT *
FROM "warehouse"










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
				WHEN store IN ('스마트스토어_풀필먼트', '쿠팡_제트배송') THEN store
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
GROUP BY trans_date, onnuri_code, onnuri_name, store

) AS t1
GROUP BY reg_date, "warehouse", onnuri_code, onnuri_name, "stock_type"


) AS t2


) t3
--WHERE "warehouse" = '코린트' AND onnuri_name = '판토모나 비오틴 하이퍼포머'
Order BY reg_date DESC 






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



AND product_name NOT LIKE '%두피%' 
AND product_name NOT LIKE '%약통%' 
AND product_name NOT LIKE '%구슬%'
AND order_id IN (SELECT order_num FROM "Non_Order")



SELECT *
FROM "E"


SELECT collect_date, shop_id, shop_name, product_name, "options", qty
FROM "EZ_Order"
WHERE recv_address LIKE '%온유약국%'



"options" LIKE '%온유%'

shop_id = 10096

order_id = '15140_9'




SELECT *
FROM "order_batch"
WHERE order_date = '2023-05-02' AND nick = '판토모나하이퍼포머'













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

