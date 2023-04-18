-- CAC DB 공유 - 2023-04-18

-- 주문 : order_batch
-- 광고 : ad_batch
-- 컨텐츠 : content_batch
-- 비용 : content_batch
-- 키워드 : keyword_view


-- keyword_view는 배치 테이블 없이 사용.

-- 광고 매핑 필요할 경우 아래 시트에 기입
-- https://docs.google.com/spreadsheets/d/1aIwDh6vhEpzVXOp5oWnGaUFNEIetm7AmkUvnD4HLSOQ/edit#gid=0



---- 샘플 쿼리 ---- 

-- 주문
--phytoway 컬럼 추가되었음

--스토어명 확인하는 방법
SELECT DISTINCT store
FROM "order_batch"


-- 신규고객수, 신규매출
SELECT yymm, yyww, order_date, store, nick, count(DISTINCT order_id) AS "신규고객수", SUM(prd_amount_mod) AS "신규매출"
FROM "order_batch"
WHERE brand_cust_type = '신규' AND prd_amount_mod < 500000 -- and store in (b2c 스토어)
GROUP BY yymm, yyww, order_date, store, nick
Order BY order_date DESC, store

SELECT *
FROM "order_batch"
WHERE order_date = '2023-04-18' AND store = '롯데온'

SELECT *
FROM "EZ_Order" WHERE order_id = '2023041814622635'


-- 광고

SELECT *
FROM "ad_batch"


-- 1. 네이버
SELECT 	yymm, yyww, yymmdd, Channel, store, brand, nick, campaign, adgroup, Keyword, 
			SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "ad_batch"
WHERE Channel = '네이버'
GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, campaign, adgroup, keyword
Order BY yymmdd desc


-- 2. 쿠팡
SELECT yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, Keyword,
		SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "ad_batch"
WHERE Channel = '쿠팡'
GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, keyword
Order BY yymmdd DESC


-- 3. 구글
SELECT yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, keyword,
		SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "ad_batch"
WHERE Channel = '구글'
GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, keyword


-- 4. 메타
SELECT yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, keyword,
		SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "ad_batch"
WHERE Channel = '메타'
GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, keyword



-- 콘텐츠

-- 1. 컨텐츠 통합 시트 > 컨텐츠id별 탭
-- 날짜 오늘로 수정
SELECT *
FROM "content_batch"
WHERE (yymmdd between '2022-10-01' AND '2023-04-17') AND page_type IN ('블로그', '지식인', '카페', '유튜브') AND Channel IN ('네이버', '구글')
Order BY yymmdd DESC, Channel, brand, nick, page_type, id DESC, Keyword, owned_keyword_type


-- 2. 컨텐츠 통합 시트 > 자상호여부별 탭
SELECT 	yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type, --Keyword, id,
			SUM(cost1) AS cost1, sum(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
FROM "content_batch"
WHERE (yymmdd between '2022-10-01' AND '2023-04-12') AND page_type IN ('블로그', '지식인', '카페', '유튜브') AND Channel IN ('네이버', '구글')
GROUP BY yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type--, Keyword, id
Order BY yymm desc, yyww desc, yymmdd DESC, Channel, brand, nick, page_type, owned_keyword_type--, keyword



-- 기타 비용 (마케팅 비용에서 컨텐츠 비용이 아닌 것)
SELECT 	yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type, --Keyword, id,
			SUM(cost1) AS cost1, sum(cost2) AS cost2
FROM "content_batch"
WHERE yymmdd >= '2022-10-01' AND page_type IN ('광고', '소재제작', '리뷰', '사은품')
GROUP BY yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type--, Keyword, id
Order BY yymm desc, yyww desc, yymmdd DESC, Channel, brand, nick, page_type, owned_keyword_type--, keyword


-- 키워드
SELECT yymm, yyww, yymmdd, brand, product, SUM(tot_cnt) AS calling
FROM "keyword_view"
GROUP BY yymm, yyww, yymmdd, brand, product
Order BY yymmdd DESC


SELECT * FROM "keyword_view"