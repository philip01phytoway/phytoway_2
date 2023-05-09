-- cruise_ltv_view



with purchase_term AS (
		SELECT 
					*, 
					prd_amount_mod AS price,
					CASE 
						WHEN order_id <> '' AND phytoway = 'y'
							THEN lag(dead_date, +1) over (partition by key Order by order_date_time asc)
						ELSE NULL
					END AS prev_dead_date,
					CASE 
						WHEN order_id <> '' AND phytoway = 'y'
							THEN lag(dead_date, -1) over (partition by key Order by order_date_time asc)
						ELSE NULL
					END AS next_dead_date,
					CASE 
						WHEN order_id <> '' AND phytoway = 'y'
							THEN lag(order_date, +1) over (partition by key order BY order_date_time asc)
						ELSE NULL
					END AS prev_order_date,
					CASE 
						WHEN order_id <> '' AND phytoway = 'y'
							THEN lag(order_date, -1) over (partition by key order BY order_date_time asc)
						ELSE NULL
					END AS next_order_date
		FROM "order_batch"
)

SELECT   yymm, yyww, yymmdd,
                sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
                sum(order_price) as order_price, sum(new_price) as new_price,
                sum(sustain_price) as sustain_price,      
                sum(return_price) as return_price, 
                sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
                sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
                sum(sustain_cnt) as sustain_cnt, 
                sum(return_cnt) as return_cnt, 
                sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt
                
from        (
                        SELECT        y.yymm, y.yyww, y.yymmdd, nick, store,
                                        case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
                                        case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
                                        case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
                                        case when yymmdd = order_date then price else 0 end as order_price, -- 매출
                                        case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
                                        case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
                                        case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
                                        case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
                                        case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
                                        case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
                                        case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
                                        case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
                                        case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
                                        case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
                                        
                                        case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
                                        case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
                        from        purchase_term as t cross join "YMD2" as y 
                )AS t2
group BY yymm, yyww, yymmdd
