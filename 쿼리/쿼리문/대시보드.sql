-- 전사매출


-- 전체, 전체로. 타겟 뽑을때도 전체, 전체로.


SELECT 	y.yymm, y.yyww, y.yymmdd, gross_target, gross_prev, f.gross2 AS gross_forecast
FROM 	"YMD2" AS y left join
		(
			SELECT * FROM fn_gross_forecast2(30)
		) AS f ON (y.yymmdd = f.yymmdd2) left join
		(	
			select	yymmdd, sum(gross_target) as gross_target, sum(gross_prev) as gross_prev
			from	"Target"
			group by yymmdd
		) as t ON (y.yymmdd = t.yymmdd)
order by yymmdd



-- fn_gross_forecast2 수정하였음.
select	order_date::varchar(100) as yymmdd, sum(prd_amount_mod) as gross
from	"order_batch"
WHERE order_date < CURRENT_DATE::varchar(100) AND phytoway = 'y'
group by order_date
order by order_date;


-- 일자별 매출
SELECT order_date, SUM(prd_amount_mod)
FROM "order_batch"
WHERE phytoway = 'y'
GROUP BY order_date
Order BY order_date DESC


SELECT * FROM "Target"
WHERE yymmdd >= '2023-05-01'

