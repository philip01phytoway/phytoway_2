-- 데이터 현황파악


---------------------------------

-- 배치 테이블 업데이트

---------------------------------

-- order_batch
TRUNCATE TABLE "order_batch"

INSERT INTO "order_batch" (yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type, inflow_path, dead_date, onnuri_code, onnuri_name, onnuri_type, trans_date, prev_dead_date, next_dead_date, prev_order_date, next_order_date)
SELECT yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type, inflow_path, dead_date, onnuri_code, onnuri_name, onnuri_type, trans_date, prev_dead_date, next_dead_date, prev_order_date, next_order_date FROM "order5"


-- ad_batch
TRUNCATE TABLE "ad_batch"

INSERT INTO "ad_batch" (yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, cost, imp_cnt, click_cnt, order_cnt, order_price, order_cnt_14, order_price_14, option_id, cost_payback)
SELECT yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, cost, imp_cnt, click_cnt, order_cnt, order_price, order_cnt_14, order_price_14, option_id, cost_payback FROM "ad_view7"


-- 저장 함수 실행
select f_ad_batch_2_3()


-- content_batch
TRUNCATE TABLE "content_batch"

INSERT INTO "content_batch" (yymm, yyww, yymmdd, channel, brand, nick, page_type, id, keyword, owned_keyword_type, cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price)
SELECT yymm, yyww, yymmdd, channel, brand, nick, page_type, id, keyword, owned_keyword_type, cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price FROM "content_view3"



-- 중복삽입 검증
select COUNT(*) from "order_batch"

select COUNT(*) from "ad_batch"

select COUNT(*) from "content_batch"


---------------------------------

-- 프로세스 개선 : 데이터 검증

---------------------------------

-- 수집 여부 확인
-- 매핑 누락, 중복 확인
-- 값 맞는지 대조
-- 주요 데이터 파악



---- 주문

-- 1. 이지어드민 주문수집 여부 확인
SELECT order_date, *
FROM "EZ_Order"
Order BY order_date desc
LIMIT 1000


-- 2. 네이버 주문수집 여부 확인
SELECT 	"paymentDate", *
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")
WHERE 	"paymentDate" IS NOT NULL
ORDER BY "paymentDate" DESC
LIMIT 1000


-- 3. 쿠팡 주문수집 여부 확인
SELECT "orderedAt", *
FROM "coupang_order"
WHERE "orderedAt" IS NOT NULL
Order BY "orderedAt" DESC
LIMIT 1000


-- 4. 이지어드민 매핑 누락 확인 (스토어)
-- B2B_제트배송은 판매가 아니라 재고이동이다.
SELECT DISTINCT shop_name, shop_id
FROM	"EZ_Order" as o
LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
WHERE s.ez_store_code IS NULL


-- 5. 이지어드민 매핑 누락 확인 (번들)
SELECT DISTINCT p.name, p.product_id
FROM	"EZ_Order" as o,																		
		jsonb_to_recordset(o.order_products) as p(																	
			name character varying(255),																
			product_id character varying(255)
		)
LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
LEFT JOIN "product" as pp on (b.product_no = pp.no)
WHERE b.ez_code IS NULL 
-- p.name IS null



-- 6. 이지어드민 매핑 누락 확인 (상품)
SELECT DISTINCT p.name
FROM	"EZ_Order" as o,																		
		jsonb_to_recordset(o.order_products) as p(																	
			name character varying(255),																
			product_id character varying(255)
		)
LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
LEFT JOIN "product" as pp on (b.product_no = pp.no)
WHERE pp.no IS NULL 



-- 5. 이지어드민 매핑 중복 확인 (상품, 스토어)



-- 5. 네이버 매핑 누락 확인
SELECT  DISTINCT "optionCode", "productName", "productOption"
FROM "naver_order_product" AS o
LEFT JOIN "naver_option" AS op ON (o."optionCode" = op."option_code")
WHERE op."option_code" IS NULL 
--AND o."deliveryAttributeType" = 'ARRIVAL_GUARANTEE'

-- 써큐시안 추가구성 상품 (선물박스 + 쇼핑백) 일단은 무시. 나중에 값 커지면 그때 수정
SELECT * FROM "naver_order_product" WHERE "optionCode" = '2317196683'


-- 6. 네이버 매핑 중복 확인
select "option_code", count(*)
from "naver_option" as n
group by "option_code"
having count(*) > 1




-- 7. 쿠팡 매핑 누락 확인
SELECT DISTINCT p."vendorItemName", p."vendorItemId", op."option"
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(	
			"vendorItemName" CHARACTER varying(255),																									
			"vendorItemId" CHARACTER varying(255)											
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
WHERE op."option" IS NULL 

-- 쿠팡 올데이 매핑 위하여 coupang_option_combined 필요함.
-- 혹은 설계의 변경이 필요함.

-- 8. 쿠팡 매핑 중복 확인
SELECT c."option", count(*)
from "coupang_option" AS c
group BY c."option"
having count(*) > 1


-- 9. 쿠팡 제트배송 매핑 누락 확인
SELECT distinct option_id, option_name
FROM "coupang_sales" AS s
LEFT JOIN "coupang_option" AS op ON (s.option_id = op."option")
WHERE sales_type = '로켓그로스' and op."option" is null


select * from "order_batch" where store = '쿠팡_제트배송' and nick = '페미론큐글루타치온'

select * from "coupang_sales" where "option_id" in ('86226494116', '86226494125')



---- 광고


-- 1-1. 네이버 검색광고 매핑 누락 확인
WITH naver_mapping AS (
		SELECT DISTINCT id, "B", "D", reg_date
		FROM "AD_Naver" AS a
		LEFT JOIN "ad_mapping3" AS m ON (a."B" = m.campaign AND a."D" = m.adgroup)
		WHERE m.campaign IS NULL OR m.adgroup IS NULL
		Order BY reg_date DESC
		--LIMIT 100
)

SELECT DISTINCT id, "B", "D"
FROM "naver_mapping"


-- 1-2. 네이버 검색광고 매핑 중복 확인
SELECT campaign, adgroup, COUNT(*)
FROM "ad_mapping3" 
WHERE channel_no = 1
GROUP BY campaign, adgroup
HAVING COUNT(*) > 1



-- 2-1. 쿠팡 상품광고 매핑 누락 확인
SELECT DISTINCT ad_account, c.product2, c.product2_id 
FROM "AD_Coupang" AS c 
LEFT JOIN "ad_mapping3" AS m ON (c.product2_id = m.product2_id) 
WHERE m.product2_id IS NULL



-- 2-2. 쿠팡 브랜드광고 매핑 누락 확인
SELECT DISTINCT C.product2, C.product2_id
FROM "AD_CoupangBrand" AS c
LEFT JOIN "ad_mapping3" AS m ON (c.product2_id = m.product2_id)
WHERE m.product2_id IS NULL AND C.product2_id <> '0'



-- 2-3. 쿠팡 광고 매핑 중복 확인
SELECT *
FROM "ad_mapping3"
WHERE product2_id IN (

SELECT product2_id
FROM "ad_mapping3"
WHERE channel_no = 5
GROUP BY product2_id
HAVING COUNT(*) > 1

)

Order BY product2_id


-- 3-1. 구글 광고 매핑 누락 확인
SELECT *
FROM "ad_google3" AS g
LEFT JOIN "ad_mapping3" AS m ON (g.adgroup_id = m.adgroup_id)
WHERE m.adgroup_id IS NULL 


-- 3-2. 구글 광고 매핑 중복 확인

SELECT *
FROM "ad_mapping3"
WHERE adgroup_id IN (

SELECT adgroup_id
FROM "ad_mapping3"
WHERE channel_no = 2
GROUP BY adgroup_id
HAVING COUNT(*) > 1

)

Order BY adgroup_id


-- 4-1. 메타 매핑 누락 확인
SELECT DISTINCT campaign, adgroup, ad
FROM (
			SELECT 	yymm, yyww, yymmdd, c.name AS channel, s.name AS store, p.nick, ad.campaign, ad.adgroup, ad.ad,
						SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click
			FROM "ad_meta" AS ad
			LEFT JOIN "ad_mapping3" AS m ON (ad.campaign = m.campaign AND ad.adgroup = m.adgroup AND ad.ad = m.ad)
			LEFT JOIN "YMD2" AS y ON (ad.reg_date = y.yymmdd)
			LEFT JOIN "product" AS p ON (m.product_no = p.no)
			LEFT JOIN "store" AS s ON (m.store_no = s.no)
			LEFT JOIN "channel" AS c ON (m.channel_no = c.no)
			WHERE adcost > 0
			GROUP BY yymm, yyww, yymmdd, c.name, s.name, p.nick, ad.campaign, ad.adgroup, ad.ad
			HAVING p.nick IS null
			Order BY yymm DESC, yyww desc, yymmdd desc, c.name, s.name, p.nick, ad.campaign, ad.adgroup, ad.ad
) AS t



-- 4-2. 메타 광고 매핑 중복 확인

SELECT campaign, adgroup, ad
FROM "ad_mapping3"
WHERE channel_no = 4
GROUP BY campaign, adgroup, ad
HAVING COUNT(*) > 1


-- 주요 데이터 현황 파악


--  1. 일별 매출 합계
SELECT yymm, yyww, order_date, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y'
GROUP BY yymm, yyww, order_date
Order BY order_date DESC, price desc
LIMIT 1000


-- 2. 주별 매출 합계
SELECT yyww, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yyww
Order BY yyww DESC
LIMIT 1000


-- 주 시작일 종료일 참고
SELECT yyww, MIN(yymmdd) AS start_date, MAX(yymmdd) AS end_date
FROM "YMD2"
GROUP BY yyww
Order BY yyww desc


-- 3. 월별 매출 합계
SELECT yymm, SUM(prd_amount_mod) AS price
FROM "order_batch"
--WHERE phytoway = 'y'
GROUP BY yymm
Order BY yymm DESC
LIMIT 1000


-- 4. 일별 주문건수, 고객수, 출고수량, 주문매출 합계
SELECT yymm, yyww, order_date, SUM(order_cnt) AS order_cnt, COUNT(DISTINCT KEY) AS key_cnt, SUM(out_qty) AS out_qty, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date
Order BY order_date DESC
LIMIT 1000


-- 5. 월별 신규주문건수, 재구매주문건수, 신규고객수, 재구매고객수, 신규매출, 재구매매출 합계
SELECT 	yyww, 

			SUM(CASE 
					WHEN all_cust_type = '신규' THEN order_cnt
					ELSE 0
				END) AS "신규주문건수",
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN order_cnt
					ELSE 0
				END) AS "재구매주문건수",
			
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '신규' THEN key
				END) AS "신규고객수",
				
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '재구매' THEN key
				END) AS "재구매고객수",
			
			SUM(CASE 
					WHEN all_cust_type = '신규' THEN prd_amount_mod
					ELSE 0
				END) AS "신규매출",
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN prd_amount_mod
					ELSE 0
				END) AS "재구매매출"
				
FROM "order5"
WHERE phytoway = 'y'
GROUP BY yyww
ORDER BY yyww DESC


-- 6. 일별 신규주문건수, 재구매주문건수, 신규고객수, 재구매고객수, 신규매출, 재구매매출 합계
SELECT 	order_date,

			SUM(CASE 
					WHEN all_cust_type = '신규' THEN order_cnt
					ELSE 0
				END) AS "신규주문건수",
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN order_cnt
					ELSE 0
				END) AS "재구매주문건수",
			
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '신규' THEN key
				END) AS "신규고객수",
				
			COUNT(DISTINCT 
				CASE 
					WHEN all_cust_type = '재구매' THEN key
				END) AS "재구매고객수",
			
			SUM(CASE 
					WHEN all_cust_type = '신규' THEN prd_amount_mod
					ELSE 0
				END) AS "신규매출",
			
			SUM(CASE 
					WHEN all_cust_type = '재구매' THEN prd_amount_mod
					ELSE 0
				END) AS "재구매매출"
				
FROM "order_batch"
WHERE order_date >= '2023-05-01'
GROUP BY order_date
ORDER BY order_date DESC






--제품별 누적고객수
SELECT brand, COUNT(DISTINCT KEY) AS cust_cnt
FROM "order_batch"
GROUP BY brand
Order BY cust_cnt desc




-- 월별 누적고객수



-- 7. 브랜드별 월매출
SELECT yymm, brand, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, brand
Order BY yymm DESC, price DESC



-- 8. 제품별 월매출
SELECT yymm, nick, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, nick
Order BY yymm DESC, price DESC


-- 9. 스토어별 월매출
SELECT yymm, store, SUM(prd_amount_mod)
FROM "order_batch" 
GROUP BY yymm, store
Order BY yymm desc





