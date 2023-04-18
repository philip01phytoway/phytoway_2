
WITH cost_mkt AS (
	SELECT yymmdd, id, SUM(cost_per_day) AS cost1
	FROM 	(
				SELECT y1.yymmdd, y1.id, c1.marketing_type, c1.owned_keyword_type, agency, cost_per_day
				FROM 	(
							SELECT *
							FROM "YMD2"
							CROSS JOIN (SELECT id FROM "Page" WHERE page_type IN ('블로그', '지식인', '유튜브', '카페') AND Channel IN ('네이버', '구글')) AS p1
						) AS y1
				LEFT JOIN 	(
									SELECT *, cost / cost_term AS cost_per_day
									FROM 	(
												SELECT *, TO_DATE(end_date, 'YYYY-MM-DD') - TO_DATE(start_date, 'YYYY-MM-DD') + 1 AS cost_term
												FROM "cost_marketing"
											) AS t1
								) AS c1 ON (y1.id = c1.id) 
				WHERE  y1.yymmdd >= c1.start_date AND y1.yymmdd <= c1.end_date
			) AS c2
	GROUP BY yymmdd, id
)

SELECT 	y.yymm, y.yyww, y.yymmdd, p.channel, pp.brand, pp.nick, p.page_type, p.id, p.keyword, 
			CASE WHEN p.keyword LIKE concat('%', pp.brand, '%') THEN '자상호'
			ELSE '비자상호'
			END AS owned_keyword_type,
			cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price
FROM 	(
			SELECT *
			FROM "YMD2"
			CROSS JOIN (SELECT id FROM "Page" WHERE page_type IN ('블로그', '지식인', '유튜브', '카페') AND Channel IN ('네이버', '구글') ) AS p
		) AS y
LEFT JOIN "Page" AS p ON (y.id = p.id)
LEFT JOIN "product" AS pp ON (p.product_id = pp."no")
LEFT JOIN (
					SELECT gift_date, id, SUM(cost) AS cost2
					FROM "cost_product"
					GROUP BY gift_date, id	
			) AS cp ON (y.yymmdd = cp.gift_date AND y.id = cp.id)
LEFT JOIN cost_mkt AS cm ON (y.yymmdd = cm.yymmdd AND y.id = cm.id)
LEFT JOIN (				
				select	to_char(pl."createdAt", 'YYYY-MM-DD') AS ymd, p.id, 								
							sum(case when pl.action_type = 'Page' then 1 else 0 end) as pv,							
							sum(case when pl.action_type = 'Click' then 1 else 0 end) as cc,							
							sum(case when pl.action_type = 'Click2' then 1 else 0 end) as cc2			
				FROM    "Page" p 								
				left join (							
								select	min("createdAt") as "createdAt", to_char("createdAt", 'YYYY-MM-DD'), page_id, product_id, action_type, header_agent, header_referer					
								FROM	"Page_Log"					
								group by to_char("createdAt", 'YYYY-MM-DD'), page_id, product_id, action_type, header_agent, header_referer						
							) pl on (p.id = pl.page_id)							
				where	to_char(pl."createdAt", 'YYYY-MM-DD') is not NULL
				group by to_char(pl."createdAt", 'YYYY-MM-DD'), p.id		
		) AS pl2 ON (y.yymmdd = pl2.ymd AND y.id = pl2.id)
LEFT JOIN (
				SELECT 	yymmdd, nt_medium, sum(inflow_cnt) as inflow_cnt, sum(order_cnt) as order_cnt, sum(order_price) as order_price
				FROM 	"Naver_Custom_Order"
				WHERE 	nt_source in ('matrix','contents', 'youtube')
				group BY  yymmdd, nt_medium
				Order BY yymmdd
		) as n on (n.nt_medium = y.id::varchar(10) and n.yymmdd = y.yymmdd)		
WHERE cp.id IS NOT NULL OR cm.id IS NOT NULL OR pl2.id IS NOT NULL OR n.nt_medium IS NOT null