--[데이터 수집] 콜링 관련 쿼리--


-- 자상호 콜링 구버전 테이블 --
SELECT * FROM "Query_Log";


-- 1. 자상호 콜링 구버전WBR 시트에 업로드---
SELECT	y.yymm, y.yyww, y.yymmdd,	
		case when p.nick is null then '파이토웨이' else p.nick end as Product,
		sum(q.mobile_cnt) as mobile_cnt, sum(q.pc_cnt) as pc_cnt, sum(q.mobile_cnt+q.pc_cnt) as sum
FROM	"Query_Log" as q left join "Keyword" as k on (q.keyword = k.keyword)	
		left join "Product" as p on (k.product_id = p.id)
		left join "YMD2" as y on (q.query_date = y.yymmdd)
GROUP BY y.yymm, y.yyww, y.yymmdd, product		
ORDER BY yymmdd desc, product DESC		




-- 2. 자상호 콜링 신버전 WBR 시트에 업로드, 제품별--
SELECT	y.yymm, y.yyww, y.yymmdd,			
		case when p.nick is null then '파이토웨이' else p.nick end as Product,		
		sum(q.mobile_cnt) as mobile_cnt, sum(q.pc_cnt) as pc_cnt, sum(q.mobile_cnt+q.pc_cnt) as sum		
FROM	"Query_Log2" as q left join "Keyword2" as k on (q.keyword = k.keyword)			
		left join "Product" as p on (k.product_id = p.id)		
		left join "YMD2" as y on (q.query_date = y.yymmdd)		
GROUP BY y.yymm, y.yyww, y.yymmdd, product				
ORDER BY yymmdd desc, product DESC				
				

-- 3. 자상호 콜링 신버전 WBR 시트에 업로드, 판토모나 --				
SELECT y.yymm, y.yyww, y.yymmdd, q.Keyword, q.pc_cnt, q.mobile_cnt, SUM(q.pc_cnt+q.mobile_cnt) FROM "Query_Log2" AS q				
LEFT JOIN "YMD2" AS y ON (y.yymmdd = q.query_date)				
WHERE q.Keyword = '판토모나'				
GROUP BY  y.yymm, y.yyww, y.yymmdd, q.Keyword, q.pc_cnt, q.mobile_cnt				
Order BY y.yymmdd DESC				


-- 4. 자상호 콜링 신버전 WBR 시트에 업로드, 페미론큐 --	
SELECT y.yymm, y.yyww, y.yymmdd, q.Keyword, q.pc_cnt, q.mobile_cnt, SUM(q.pc_cnt+q.mobile_cnt) FROM "Query_Log2" AS q				
LEFT JOIN "YMD2" AS y ON (y.yymmdd = q.query_date)				
WHERE q.Keyword = '페미론큐'				
GROUP BY  y.yymm, y.yyww, y.yymmdd, q.Keyword, q.pc_cnt, q.mobile_cnt				
Order BY y.yymmdd DESC






--


SELECT SUM(OUTPUT) FROM "Stock" where yymmdd = '20221018';

DELETE FROM "Stock" WHERE yymmdd = '20221018'







SELECT * FROM "Product"


