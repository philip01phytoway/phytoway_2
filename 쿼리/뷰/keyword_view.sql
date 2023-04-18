	
SELECT 	y.yymm, y.yyww, y.yymmdd, 
			CASE 
				WHEN p.brand is null then '파이토웨이' 
				ELSE p.brand 
			END AS brand,
			CASE 
				WHEN p.nick is null then '파이토웨이' 
				ELSE p.nick 
			END AS Product,
			q.Keyword,
			mobile_cnt, pc_cnt, mobile_cnt+q.pc_cnt AS tot_cnt
FROM "Query_Log2" as q 
LEFT JOIN "Keyword2" as k on (q.keyword = k.keyword)			
LEFT JOIN "product" as p on (k.product_id = p.no)		
LEFT JOIN "YMD2" as y on (q.query_date = y.yymmdd)		
