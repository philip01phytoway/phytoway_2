
-- 1. 네이버
SELECT 	y.yymm, y.yyww, y.yymmdd, c.name AS channel, s.name AS store,        
			p.brand, p.nick, 
			m.ad_account AS account, '검색광고' AS "ad_type", a."C" AS "campaign_type", a."I" AS imp_area, 
			a."B" AS "campaign", a."D" AS "adgroup", a."G" AS "creative", 
			
			CASE 
				WHEN m.owned_keyword = '자상호' THEN '자상호'
				ELSE '비자상호'
			END AS owned_keyword, 
			
			a."F" AS Keyword,
			a."P" AS cost, a."L" AS imp_cnt, a."M" AS click_cnt, a."Q" AS order_cnt, a."U" AS order_price, 0 AS order_cnt_14, 0 AS order_price_14, '' AS option_id
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
			
			c.adcost AS cost, c.impressions AS imp_cnt, c.clicks AS click_cnt, c.order_cnt, c.gross AS order_price, C."Z" AS order_cnt_14, c."AF" AS order_price_14, c.product2_id
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
 	cb.adcost AS cost, cb.impressions AS imp_cnt, cb.clicks AS click_cnt, cb.order_cnt, cb.gross AS order_price, cb."AO" AS order_cnt_14, cb."AU" AS order_price_14, cb.product2_id
FROM "AD_CoupangBrand" AS cb         
LEFT JOIN "ad_mapping3" AS  m ON (m.product2_id::text = cb.product2_id::text)
LEFT JOIN "product" AS p ON (m.product_no = p.no)
LEFT JOIN "YMD2" y ON (cb.reg_date::text = y.yymmdd::TEXT)


UNION ALL 

-- 3. 구글
SELECT 	yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, 
			cost, imp_cnt, click_cnt, g.order_cnt / MAX(t.adgroup_id_cnt) OVER(PARTITION BY yymmdd, t.adgroup_id) AS order_cnt_mod, g.order_price / MAX(t.adgroup_id_cnt) OVER(PARTITION BY yymmdd, t.adgroup_id) AS order_price_mod,
			0 AS order_cnt_14, 0 AS order_price_14, '' AS option_id
FROM (
    SELECT y.yymm, y.yyww, y.yymmdd, '구글' AS Channel, s.name AS store, 
           CASE
               WHEN (p.brand IS NOT NULL) THEN p.brand
               ELSE '파이토웨이'
           END AS brand,
           CASE
               WHEN (p.nick IS NOT NULL) THEN p.nick
               ELSE '파이토웨이'
           END AS nick,
           g.account, '' AS ad_type, g.campaign_type, '' AS imp_area, 
           g.campaign, g.adgroup, '' AS creative, 
			  
			  CASE 
			      WHEN g.adgroup LIKE '%' || p.brand || '%' THEN '자상호' 
			      ELSE '비자상호'
			  END AS owned_keyword, 
			  
			  g.keyword, 
           g.adcost AS cost, g.impression AS imp_cnt, g.click AS click_cnt, g."order" AS "order_cnt", g.gross AS "order_price", 
           g.adgroup_id,
           ROW_NUMBER() OVER(PARTITION BY yymmdd, g.adgroup_id ORDER BY keyword) AS adgroup_id_cnt
    FROM "ad_google3" AS g
    LEFT JOIN "ad_mapping3" AS m ON (g.adgroup_id = m.adgroup_id)
    LEFT JOIN channel AS c ON (c.no = m.channel_no)
    LEFT JOIN store AS s ON (s.no = m.store_no)
    LEFT JOIN product AS p ON (p.no = m.product_no)
    LEFT JOIN "YMD2" AS y ON (g.reg_date = y.yymmdd)
) AS t		
LEFT JOIN (

		SELECT reg_date, adgroup_id, SUM(order_cnt) AS order_cnt, SUM(gross) AS order_price
		FROM "ad_ga_aw"
		GROUP BY reg_date, adgroup_id
		
		) AS g ON (t.yymmdd = g.reg_date AND t.adgroup_id = g.adgroup_id)


UNION ALL 


-- 4. 메타
SELECT 	y.yymm, y.yyww, y.yymmdd, '메타' AS Channel, s.name AS store, p.brand, p.nick,
			a.ad_account AS account, '' AS ad_type, '' AS  campaign_type, '' AS imp_area, 
			a.campaign, a.adgroup, a.ad AS creative, '' AS owned_keyword, '' AS Keyword,
			a.adcost AS cost, a.impression AS imp_cnt, a.click AS click_cnt, a."order" AS order_cnt, a.gross AS order_price,
			0 AS order_cnt_14, 0 AS order_price_14, '' AS option_id
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


-- 6.ADN
SELECT y.yymm, y.yyww, SUBSTRING(a."date", 1, 10) AS reg_date, 'ADN' AS Channel, s.name AS store, p.brand, p.nick,
       '' AS account, '' AS ad_type, '' AS  campaign_type, '' AS imp_area,
       a.campaign, a.adgroup, a.ad AS creative, '' AS owned_keyword, '' AS Keyword,
       a.adcost AS cost, a.impression AS imp_cnt, a.click AS click_cnt, a.order_cnt, a.gross AS order_price,
       0 AS order_cnt_14, 0 AS order_price_14, '' AS option_id
FROM "ad_adn" AS a
LEFT JOIN ad_mapping3 m ON (a.campaign = m.campaign)
LEFT JOIN product p ON (m.product_no = p.no)
LEFT JOIN store s ON (m.store_no = s.no)
LEFT JOIN channel c ON (m.channel_no = c.no)
LEFT JOIN "YMD2" as y ON (SUBSTRING(a."date", 1, 10) = y.yymmdd)
  

