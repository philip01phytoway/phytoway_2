-- CAC DB 공유 - 2023-04-18


---- 배치 테이블 스케줄링 쿼리문 ----

-- order_batch
DELETE FROM "order_batch"

INSERT INTO "order_batch" (yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type)
SELECT yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type FROM "order5"


-- ad_batch
DELETE FROM "ad_batch"

INSERT INTO "ad_batch" (yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, cost, imp_cnt, click_cnt, order_cnt, order_price, adgroup_id, utm_campaign, utm_content)
SELECT yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, cost, imp_cnt, click_cnt, order_cnt, order_price, adgroup_id, utm_campaign, utm_content FROM "ad_view7"


-- content_batch
DELETE FROM "content_batch"

INSERT INTO "content_batch" (yymm, yyww, yymmdd, channel, brand, nick, page_type, id, keyword, owned_keyword_type, cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price)
SELECT yymm, yyww, yymmdd, channel, brand, nick, page_type, id, keyword, owned_keyword_type, cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price FROM "content_view3"


-- keyword_view는 배치 테이블 없이 사용.


---- 샘플 쿼리 ---- 

-- 주문
SELECT *
FROM "order_batch"
GROUP BY 


-- 광고

-- 1. 네이버
-- 1-1. 키워드별 클릭수
SELECT 	yymm, yyww, yymmdd, Channel, store, brand, nick, campaign, adgroup, Keyword, 
			SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt
FROM "ad_batch"
WHERE Channel = '네이버'
GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, campaign, adgroup, keyword
Order BY yymmdd desc


-- 1-2. 키워드별 매출
-- 단차가 맞지 않는 항목은 제외하였고 키워드로만 매핑하였음.
WITH "ad_batch_naver" AS (

		SELECT 	yymm, yyww, yymmdd, Keyword, 
					SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
		FROM "ad_batch"
		WHERE Channel = '네이버'
		GROUP BY yymm, yyww, yymmdd, Keyword
)

SELECT 	a.yymm, a.yyww, a.yymmdd, a.keyword, a.cost, a.imp_cnt, a.click_cnt, 
			CASE 
				WHEN a.order_cnt = 0 THEN n.order_cnt
				ELSE a.order_cnt
			END AS order_cnt,
			CASE 
				WHEN a.order_price = 0 THEN n.order_price
				ELSE a.order_price
			END AS order_price
FROM "ad_batch_naver" AS a
LEFT JOIN (	     
               
		SELECT yymmdd, "D", SUM("I") AS order_cnt, SUM("K") AS order_price
		FROM "Naver_Search_Channel"
		WHERE "B" LIKE '%광고%'
		GROUP BY yymmdd, "D"
		
		) AS n ON (a.yymmdd = n.yymmdd AND a.keyword = n."D")
Order BY a.yymmdd DESC, order_price


-- 2. 쿠팡
SELECT yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, Keyword,
		SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "ad_batch"
WHERE Channel = '쿠팡'
GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, keyword
Order BY yymmdd DESC


-- 3. 구글
WITH "ad_batch_google" AS (

		SELECT yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, adgroup_id,
				SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
		FROM "ad_batch"
		WHERE Channel = '구글'
		GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, adgroup_id
)

SELECT 	a.yymm, a.yyww, a.yymmdd, a.channel, a.store, a.brand, a.nick, a.account, a.campaign, a.adgroup,
			a.cost, a.imp_cnt, a.click_cnt, g.order_cnt, g.order_price
FROM "ad_batch_google" AS a
LEFT JOIN (

		SELECT reg_date, adgroup_id, SUM(order_cnt) AS order_cnt, SUM(gross) AS order_price
		FROM "ad_ga_aw"
		GROUP BY reg_date, adgroup_id
		
		) AS g ON (a.yymmdd = g.reg_date AND a.adgroup_id = g.adgroup_id)
Order BY yymmdd DESC



-- 4. 메타
WITH "ad_batch_meta" AS (

		SELECT yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, creative, utm_campaign, utm_content,
				SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
		FROM "ad_batch"
		WHERE Channel = '메타'
		GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, creative, utm_campaign, utm_content
)

SELECT 	a.yymm, a.yyww, a.yymmdd, a.channel, a.store, a.brand, a.nick, a.account, campaign, adgroup, creative,
			a.cost, a.imp_cnt, a.click_cnt, g.order_cnt, g.order_price
FROM "ad_batch_meta" AS a
LEFT JOIN (

		SELECT reg_date, utm_campaign, utm_content, SUM("order") AS order_cnt, SUM(gross) AS order_price
		FROM "ad_ga_utm"
		GROUP BY reg_date, utm_campaign, utm_content
		
		) AS g ON (a.yymmdd = g.reg_date AND a.campaign = g.utm_campaign AND a.creative = g.utm_content)
Order BY yymmdd DESC


-- 콘텐츠

-- 1. 컨텐츠 통합 시트 > 컨텐츠id별 탭
-- 날짜 오늘로 수정
SELECT *
FROM "content_view3"
WHERE (yymmdd between '2022-10-01' AND '2023-04-17') AND page_type IN ('블로그', '지식인', '카페', '유튜브') AND Channel IN ('네이버', '구글')
Order BY yymmdd DESC, Channel, brand, nick, page_type, id DESC, Keyword, owned_keyword_type


-- 2. 컨텐츠 통합 시트 > 자상호여부별 탭
SELECT 	yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type, --Keyword, id,
			SUM(cost1) AS cost1, sum(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
FROM "content_view3"
WHERE (yymmdd between '2022-10-01' AND '2023-04-12') AND page_type IN ('블로그', '지식인', '카페', '유튜브') AND Channel IN ('네이버', '구글')
GROUP BY yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type--, Keyword, id
Order BY yymm desc, yyww desc, yymmdd DESC, Channel, brand, nick, page_type, owned_keyword_type--, keyword



-- 기타 비용 (마케팅 비용에서 컨텐츠 비용이 아닌 것)
SELECT 	yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type, --Keyword, id,
			SUM(cost1) AS cost1, sum(cost2) AS cost2
FROM "content_view3"
WHERE yymmdd >= '2022-10-01' AND page_type IN ('광고', '소재제작', '리뷰', '사은품')
GROUP BY yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type--, Keyword, id
Order BY yymm desc, yyww desc, yymmdd DESC, Channel, brand, nick, page_type, owned_keyword_type--, keyword


-- 키워드
SELECT yymm, yyww, yymmdd, brand, product, SUM(tot_cnt) AS calling
FROM "keyword_view"
GROUP BY yymm, yyww, yymmdd, brand, product
Order BY yymmdd DESC

