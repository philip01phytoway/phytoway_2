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
SELECT yymm, yyww, order_date, store, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y'
GROUP BY yymm, yyww, order_date, store
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
---------------------------------

-- 광고

---------------------------------



-- 광고 데이터 수집 여부는 admin과 sum으로 대조해서 검증을 하자.
-- 동시에 데이터 정확성도 검증하는 것.
-- 9. 광고 비용, 노출, 클릭 (어드민과 대조)
SELECT 	yymm, channel, account, 
			SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "ad_batch"
WHERE yymmdd IS NOT NULL
GROUP BY yymm, channel, account
Order BY yymm DESC, channel, account


-- 10. 네이버 광고 매핑 누락 확인
WITH naver_mapping AS (
		SELECT DISTINCT id, "B", "D", reg_date
		FROM "AD_Naver" AS a
		LEFT JOIN "ad_mapping3" AS m ON (a."B" = m.campaign AND a."D" = m.adgroup)
		WHERE m.campaign IS NULL OR m.adgroup IS NULL -- AND reg_date >= '2023-03-01'
		Order BY reg_date DESC
		--LIMIT 100
)

SELECT DISTINCT id, "B", "D"
FROM "naver_mapping"


select * from "AD_Naver"


-- 11. 네이버 광고 매핑 중복 확인
-- 혹은 매핑 전 데이터와 매핑 후 데이터의 행 개수를 대조하기.
SELECT campaign, adgroup, COUNT(*)
FROM "ad_mapping3" 
WHERE channel_no = 1
GROUP BY campaign, adgroup
HAVING COUNT(*) > 1


-- 12. 네이버 광고 월별 키워드별 cpc, roas 파악
SELECT yymm, keyword, SUM(cost) AS cost, SUM(click_cnt) AS click_cnt, SUM(cost) / SUM(click_cnt) AS cpc, SUM(order_price) AS order_price, LEFT((SUM(order_price)::float / SUM(cost)::FLOAT)::TEXT, 4) AS roas
FROM "ad_batch"
WHERE channel = '네이버' AND cost > 0 --(cost > 0 OR click_cnt > 0
GROUP BY yymm, keyword
Order BY yymm DESC, cost DESC
-- 내가 평균의 함정에 빠진건가? cpc가 어느 구간에선 높을 수가 있나?
-- 키워드가 -인건 뭐지? : 쇼검
-- 제품별 효율도 봐야겠네.


----------------

-- 콘텐츠

-----------------

SELECT * FROM "content_batch"




-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------



SELECT *
FROM "ad_batch"
WHERE channel = '네이버' AND cost = 0 AND imp_cnt > 0



-- 쿼리문 추출과 함께 기초적인 기술통계를 하면 좋겠다.
-- 단지 표만 봐서는 뭐가 어떤지를 모르니까.

-- 매출 현황
-- 일자별


-- 전주 동요일 대비

-- 최근 8주간 동요일 대비



-- 이런 분석조차도 미리 준비된 것들을 실행시키기만 하면 되게끔 만들어야 한다.

-- 월별 sum.
-- 월 목표도 있으니까.

-- 일자, 브랜드별
SELECT yymm, yyww, order_date, brand, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date, brand
Order BY order_date DESC, price desc
LIMIT 1000

-- 기타 제품이 1000만원 넘게 팔렸으므로 특이한 일이니까 확인해보면
-- 로켓배송에서 매출이 나왔다.
SELECT *
FROM "order_batch"
WHERE order_date = '2023-05-15' AND nick = '기타'
Order BY prd_amount_mod DESC

-- 기타 제품을 제외한 매출을 보면
SELECT yymm, yyww, order_date, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y'
GROUP BY yymm, yyww, order_date
Order BY order_date DESC
LIMIT 1000
-- interval 30 days로 지난달과 비교해볼 수 있겠다.


-- 일자, 상품별
SELECT yymm, yyww, order_date, brand, nick, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date, brand, nick
Order BY order_date DESC, price desc
LIMIT 1000

-- 5월 13일에 brand = null인게 있네.
-- 쿠팡 제트배송 이었네.
SELECT *
FROM "order_batch"
WHERE brand IS NULL

SELECT *
FROM "coupang_sales"
WHERE reg_date = '2023-05-13'


-- 일자, 스토어별
SELECT yymm, yyww, order_date, store, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date, store
Order BY order_date DESC, price desc
LIMIT 1000


-- 평균과 변동.
-- 30일 이동평균 매출도 보고, 월화수목 평균 vs 주말 평균, 그리고 표준편차 등.
-- 변동도 구해보고,

-- 매출의 분포도 봐야겠다. 정규분포를 띄고 있을까?
-- 어쩌면 내가 통계분석을 수행하면 데이터에 대한 이해도가 높아질 수 있다.

-- CAGR로 연복리 성장율도 구해보고.

-- 기초적인 통계분석을 진행해보자.
-- 데이터를 혼자 가지고 놀아보자.


-- 신규고객수, 신규매출, 재구매고객수, 재구매매출

-- 명, 건, 개, 액


-- 매핑 누락, 중복 확인

-- 데이터 누락, 중복 확인



-- 네이버 광고


-- 매출 분석을 다각도로 시행한 논문이나 책이 있을 것이다.
-- 그런 책들을 여러권 조사해보면, 내가 매출을 어떻게 파악, 분석해야 하는지 감이 잡힐 것이다.
-- 아, 그리고 마소캠퍼스에서도 몇가지 기법이 나오지.


-- 시중의 여러가지 대시보드 툴이 있을 것이고
-- 그 툴들이 공통적으로 사용하는 지표들을 조사해서 추릴 수 있을 거다.

-- WBR마스터 시트도 매출분석이 상세하게 되어있는 표이다.

-- 비율도 보고 차이도 본다.

-- 매출에는 시간에 따른 변화가 꼭 물려있구나. 매출은 일자가 있을 수 밖에 없으니까.




-- 주문 매핑은 상품과 스토어이다.








-- 광고 매핑 중복 확인




-- 쿠팡 매핑 중복 확인
SELECT product2_id
FROM "ad_mapping3"
WHERE channel_no = 5
GROUP BY product2_id
HAVING COUNT(*) > 1
