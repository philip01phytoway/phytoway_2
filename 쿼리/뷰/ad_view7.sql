-- 최대한 많은 컬럼을 살려야 한다.




-- 네이버
-- 네이버가 단차가 맞지 않아서 어렵다.



-- 캠페인명, 광고그룹명, 키워드 group by 했을 때 키워드 개수 : 12,361
-- 키워드의 unique한 개수 : 3,741
-- 여러 캠페인에 동시에 속한 키워드의 개수 : 2,169
-- 키워드가 '-'인 경우는 쇼핑-쇼핑몰 상품형인 경우네.

-- 그럼 키워드로만 매핑했을 때와 캠페인명, 광고그룹명으로 매핑했을 때 매출 차이가 클까?
-- 1. 키워드로만 매핑했을 경우
WITH ad_keyword_only AS (
	SELECT "reg_date", "F"
	FROM "AD_Naver"
	WHERE "reg_date" >= '2023-01-01'
	GROUP BY "reg_date", "F"
)
SELECT a."reg_date", a."F", SUM("K") AS price
FROM ad_keyword_only AS a
LEFT JOIN "Naver_Search_Channel" AS s ON (a.reg_date = s.yymmdd AND a."F" = s."D")
GROUP BY a."reg_date", a."F"

-- 2. 캠페인명, 광고그룹명, 키워드로 매핑했을 경우
WITH ad_keyword_only AS (
	SELECT "reg_date", "B", "D", "F"
	FROM "AD_Naver"
	WHERE "reg_date" >= '2023-01-01'
	GROUP BY "reg_date", "B", "D", "F"
)
SELECT a."reg_date", a."B", a."D", a."F", SUM("K") AS price
FROM ad_keyword_only AS a
LEFT JOIN "Naver_Search_Channel" AS s ON (a.reg_date = s.yymmdd AND a."F" = s."D")
GROUP BY a."reg_date", a."B", a."D", a."F"

--> 캠페인명, 광고그룹명으로 매핑했을 경우 값이 엄청나게 튄다.
-- 자상호 키워드가 여러 캠페인에 들어있기 때문에, 매출이 5배 증가한 것처럼 보이게 된다.


--> 그렇다면 이번 기회에 바로 잡는 것이 좋을 것 같다.
-- 다행히 매출을 지표로 삼지 않았기 때문에, 크게 무리는 없을 것 같다.

-- 광고 뷰에서는 어쩔 수 없이 left join을 해야겠고,
-- 샘플 쿼리를 줄 수 밖에.
-- 단차가 맞지 않아서 어정쩡한 형태로라도 해결해야지.

-- 1. 네이버
SELECT 	y.yymm, y.yyww, y.yymmdd, c.name AS channel, s.name AS store, p.brand, p.nick, 
			a."id" AS account, '검색광고' AS "ad_type", a."C" AS "campaign_type", a."I" AS imp_area, 
			a."B" AS "campaign", a."D" AS "adgroup", a."G" AS "creative", m.owned_keyword, a."F" AS Keyword,
			a."P" AS cost, a."L" AS imp_cnt, a."M" AS click_cnt, a."Q" AS order_cnt, a."U" AS order_price, 
			'' AS adgroup_id, '' AS utm_campaign, '' AS utm_content
FROM 		"AD_Naver" AS a
LEFT JOIN "ad_mapping3" as m ON (a."B" = m.campaign AND a."D" = m.adgroup) 
LEFT JOIN "product" as p ON (m.product_no = p.no)
LEFT JOIN "store" as s ON (m.store_no = s.no)
LEFT JOIN "channel" AS c ON (m.channel_no = c.no)
LEFT JOIN "YMD2" AS y ON (a.reg_date = y.yymmdd) 


UNION ALL


-- 2. 쿠팡
-- 쿠팡 상품광고
SELECT 	y.yymm, y.yyww, y.yymmdd, '쿠팡' AS Channel, '쿠팡' AS store, p.brand, p.nick, 
			c.account, '상품광고' AS "ad_type", c."ad_type" AS "campaign_type", C."adspace" AS imp_area,
			c.campaign, c.ad_group, '' AS creative,
			
		 	CASE
			    WHEN (c.campaign LIKE '%자상호%' OR c.ad_group LIKE '%자상호%') AND c.keyword <> '' THEN '자상호'
			    WHEN c.keyword LIKE '%' || p.brand || '%' THEN '자상호'
			    ELSE '비자상호'
			END AS owned_keyword, c.keyword, 
			
			c.adcost AS cost, c.impressions AS imp_cnt, c.clicks AS click_cnt, c.order_cnt, c.gross AS order_price, 
			'' AS adgroup_id, '' AS utm_campaign, '' AS utm_content
FROM "AD_Coupang" AS c
LEFT JOIN "ad_mapping3" AS m ON (m.product2_id = c.product2_id)
LEFT JOIN "product" AS p ON (m.product_no = p.no)
LEFT JOIN "YMD2" AS y ON (y.yymmdd = c.reg_date)


UNION ALL


-- 쿠팡 브랜드광고
SELECT y.yymm, y.yyww, y.yymmdd, '쿠팡' AS Channel, '쿠팡' AS store,

 		CASE
         WHEN (cb.product2_id <> '0') THEN p.brand
         ELSE '파이토웨이'
     END AS brand,
     
     CASE
         WHEN ((cb.product2_id) <> '0') THEN p.nick
         ELSE '파이토웨이'
     END AS nick,
     
     cb.account, '브랜드광고' AS "ad_type", "template_type" AS campaign_type, impressions_type AS imp_area, 
     cb.campaign, cb.ad_group, cb."source" AS creative, 
     
   CASE
	    WHEN (cb.campaign LIKE '%자상호%' OR cb.ad_group LIKE '%자상호%') AND cb.impression_keyword <> '' THEN '자상호'
	    WHEN cb.impression_keyword LIKE '%' || p.brand || '%' THEN '자상호'
		 ELSE '비자상호'
	END AS owned_keyword, cb.impression_keyword AS keyword,
 	cb.adcost AS cost, cb.impressions AS imp_cnt, cb.clicks AS click_cnt, cb.order_cnt, cb.gross AS order_price, 
	 '' AS adgroup_id, '' AS utm_campaign, '' AS utm_content
FROM "AD_CoupangBrand" AS cb         
LEFT JOIN "ad_mapping3" AS  m ON (m.product2_id::text = cb.product2_id::text)
LEFT JOIN "product" AS p ON (m.product_no = p.no)
LEFT JOIN "YMD2" y ON (cb.reg_date::text = y.yymmdd::TEXT)


UNION ALL 
-- 3. 구글
-- 구글도 단차가 맞지 않아서, 매출을 말아놓으면 문제가 생김.
-- group by를 하지 않고 주는게 취지이므로, group by 없이 준 뒤 샘플 쿼리를 짜야할 듯.
SELECT 	y.yymm, y.yyww, y.yymmdd, '구글' AS Channel, s.name AS store, 
     		 CASE
              WHEN (p.brand IS NOT NULL) THEN p.brand
              ELSE '파이토웨이'
          END AS brand,
          CASE
              WHEN (p.nick IS NOT NULL) THEN p.nick
              ELSE '파이토웨이'
          END AS nick,
			g.account, '' AS ad_type, g.campaign_type, '' AS imp_area, 
			g.campaign, g.adgroup, '' AS creative, m.owned_keyword, g.keyword, 
			g.adcost AS cost, g.impression AS imp_cnt, g.click AS click_cnt, g."order" AS "order_cnt", g.gross AS "order_price", 
			g.adgroup_id, '' AS utm_campaign, '' AS utm_content
FROM 		"ad_google3" AS g
LEFT JOIN "ad_mapping3" AS m ON (g.adgroup_id = m.adgroup_id)
LEFT JOIN channel AS c ON (c.no = m.channel_no)
LEFT JOIN store AS s ON (s.no = m.store_no)
LEFT JOIN product AS p ON (p.no = m.product_no)
LEFT JOIN "YMD2" AS y ON (g.reg_date = y.yymmdd)


UNION ALL 
-- 4. 메타
-- 일자, 캠페인명, 소재명으로 매핑
-- 소재명에 리타겟 추가하는 거.
-- 매핑에 문제가 있는데, 동일한 ad가 여러개의 utm_content를 가지고 있다.
-- 단차가 안맞는걸 단차를 맞춤으로써 풀었구나.
-- 그럼에도 불구하고 값이 튀는게 있는데, 그건 어쩔 수 없다고 하자.
SELECT 	y.yymm, y.yyww, y.yymmdd, '메타' AS Channel, s.name AS store, p.brand, p.nick,
			a.ad_account AS account, '' AS ad_type, '' AS  campaign_type, '' AS imp_area, 
			a.campaign, a.adgroup, a.ad AS creative, '' AS owned_keyword, '' AS Keyword,
			a.adcost AS cost, a.impression AS imp_cnt, a.click AS click_cnt, a."order" AS order_cnt, a.gross AS order_price, 
			'' AS adgroup_id, m.utm_campaign, m.utm_content
FROM 	(
			SELECT 	*,
						CASE WHEN adgroup LIKE '%리타겟%' AND ad NOT LIKE '%리타겟%' THEN ad || '_리타겟'
						ELSE ad
						END AS ad_mod
			FROM "ad_meta"
		) AS a
LEFT JOIN (		
			SELECT DISTINCT 	campaign, ad, 
									CASE WHEN adgroup LIKE '%리타겟%' AND ad NOT LIKE '%리타겟%' THEN ad || '_리타겟'
									ELSE ad
									END AS ad_mod,
									utm_campaign, utm_content, channel_no, product_no, store_no 
			FROM "ad_mapping3" WHERE channel_no = 4
			) AS m ON (a.campaign = m.campaign AND a.ad_mod = m.ad_mod)
LEFT JOIN "product" AS p ON (m.product_no = p.no)
LEFT JOIN "store" AS s ON (m.store_no = s.no)
LEFT JOIN "channel" AS c ON (m.channel_no = c.no)
LEFT JOIN "YMD2" AS y ON (a.reg_date = y.yymmdd)


UNION ALL 
-- 5. 카카오
-- 카카오는 골치 아프니까 빼자.
-- 필요하다면 버전 2.0에서 넣어준다고 하자.


-- 6.ADN
SELECT y.yymm, y.yyww, SUBSTRING(a."date", 1, 10) AS reg_date, 'ADN' AS Channel, s.name AS store, p.brand, p.nick,
       '' AS account, '' AS ad_type, '' AS  campaign_type, '' AS imp_area,
       a.campaign, a.adgroup, a.ad AS creative, '' AS owned_keyword, '' AS Keyword,
       a.adcost AS cost, a.impression AS imp_cnt, a.click AS click_cnt, a.order_cnt, a.gross AS order_price, 
		 '' AS adgroup_id, '' AS utm_campaign, '' AS utm_content
FROM "ad_adn" AS a
LEFT JOIN ad_mapping3 m ON (a.campaign = m.campaign)
LEFT JOIN product p ON (m.product_no = p.no)
LEFT JOIN store s ON (m.store_no = s.no)
LEFT JOIN channel c ON (m.channel_no = c.no)
LEFT JOIN "YMD2" as y ON (SUBSTRING(a."date", 1, 10) = y.yymmdd)
  


----- 샘플쿼리 -----

-- 네이버
-- 1. 키워드별 클릭수
SELECT 	yymm, yyww, yymmdd, Channel, store, brand, nick, campaign, adgroup, Keyword, 
			SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt
FROM "ad_view7"
WHERE Channel = '네이버'
GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, campaign, adgroup, keyword
Order BY yymmdd desc

-- 2. 키워드별 매출
-- 단차가 맞지 않는 항목은 제외하였고 키워드로만 매핑하였음.
WITH "ad_view_naver" AS (

		SELECT 	yymm, yyww, yymmdd, Keyword, 
					SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
		FROM "ad_view7"
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
FROM "ad_view_naver" AS a
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
FROM "ad_view7"
WHERE Channel = '쿠팡'
GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, keyword
Order BY yymmdd DESC


-- 3. 구글
WITH "ad_view_google" AS (

		SELECT yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, adgroup_id,
				SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
		FROM "ad_view7"
		WHERE Channel = '구글'
		GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, adgroup_id
)

SELECT 	a.yymm, a.yyww, a.yymmdd, a.channel, a.store, a.brand, a.nick, a.account, a.campaign, a.adgroup,
			a.cost, a.imp_cnt, a.click_cnt, g.order_cnt, g.order_price
FROM "ad_view_google" AS a
LEFT JOIN (

		SELECT reg_date, adgroup_id, SUM(order_cnt) AS order_cnt, SUM(gross) AS order_price
		FROM "ad_ga_aw"
		GROUP BY reg_date, adgroup_id
		
		) AS g ON (a.yymmdd = g.reg_date AND a.adgroup_id = g.adgroup_id)
Order BY yymmdd DESC


-- cross join을 해야 할까?


-- 4. 메타
WITH "ad_view_meta" AS (

		SELECT yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, creative, utm_campaign, utm_content,
				SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
		FROM "ad_view7"
		WHERE Channel = '메타'
		GROUP BY yymm, yyww, yymmdd, Channel, store, brand, nick, account, campaign, adgroup, creative, utm_campaign, utm_content
)

SELECT 	a.yymm, a.yyww, a.yymmdd, a.channel, a.store, a.brand, a.nick, a.account, campaign, adgroup, creative,
			a.cost, a.imp_cnt, a.click_cnt, g.order_cnt, g.order_price
FROM "ad_view_meta" AS a
LEFT JOIN (

		SELECT reg_date, utm_campaign, utm_content, SUM("order") AS order_cnt, SUM(gross) AS order_price
		FROM "ad_ga_utm"
		GROUP BY reg_date, utm_campaign, utm_content
		
		) AS g ON (a.yymmdd = g.reg_date AND a.campaign = g.utm_campaign AND a.creative = g.utm_content)
Order BY yymmdd DESC




SELECT reg_date, utm_campaign, utm_content, SUM("order") AS order_cnt, SUM(gross) AS order_price
FROM "ad_ga_utm"
GROUP BY reg_date, utm_campaign, utm_content




SELECT *
FROM "ad_view7"
LIMIT 1

SELECT reg_date, adgroup_id, SUM(order_cnt) AS order_cnt, SUM(gross) AS order_price
FROM "ad_ga_aw"
GROUP BY reg_date, adgroup_id
HAVING COUNT(*) > 1

141487919417
143535828146

SELECT *
FROM "ad_ga_aw"
GROUP BY 

WHERE adgroup_id IN (
'141487919417',
'143535828146'
)
AND reg_date = '2023-01-30'


SELECT *
FROM "ad_google3"

SELECT *
FROM "ad_view7"
WHERE Channel = '쿠팡' AND yymmdd IS NULL 


SELECT *
FROM "AD_CoupangBrand"
WHERE reg_date = ''


SELECT *
FROM "AD_CoupangBrand"
LIMIT 10000

