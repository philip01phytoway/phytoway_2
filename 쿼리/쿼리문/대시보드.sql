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




select	order_date::varchar(100) as yymmdd, sum(prd_amount_mod) as gross
from	"order_batch"
WHERE order_date < CURRENT_DATE::varchar(100)
group by order_date
order by order_date;






BEGIN
CREATE TEMP TABLE IF NOT EXISTS temp_rev_projection AS
	
		select	order_date::varchar(100) as yymmdd, sum(prd_amount_mod) as gross
		from	"order_batch"
		WHERE order_date < CURRENT_DATE::varchar(100)
		group by order_date
		order by order_date;
	
FOR i IN 1 .. periods
    LOOP
        INSERT INTO temp_rev_projection
            SELECT (
              SELECT MAX(a.yymmdd::date) + INTERVAL '1 day'
              FROM temp_rev_projection a
           ) AS yymmdd,
           (
               SELECT SUM(t.gross) 
               FROM (
                   SELECT * 
                   FROM temp_rev_projection
                   ORDER BY yymmdd DESC 
                   LIMIT periods
               ) t
           ) / periods AS gross;
    END LOOP;
 
 RETURN QUERY EXECUTE 'select yymmdd::varchar(10), gross::integer from temp_rev_projection';
 
 DROP TABLE temp_rev_projection;
END



SELECT CURRENT_DATE::text AS today
