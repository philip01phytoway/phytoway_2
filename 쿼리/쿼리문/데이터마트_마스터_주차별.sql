-----------------------------------------

데이터마트 > 마스터 폴더

-----------------------------------------

--매출 및 고객
-- (전체, 전체)
-- (상품별, 전체)
-- (전체, 스토어별)
-- (상품별, 스토어별)
-- (브랜드별, 전체)
-- (브랜드별, 스토어별)


--wbr2최종 코호트 > DA
-- (전체, 전체)
with purchase_term as (
	select 	key, order_date, order_date_time,
			order_qty * product_qty * term * 1.2 as real_term,
			case when order_qty * product_qty * term * 1.2 > 365 then 365 else order_qty * product_qty * term * 1.2 end as active_term,
			to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date,
			price,
			lag(order_date, +1) over (partition by key order by order_date, order_date_time asc) as prev_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), +1) 
					over (partition by key order by order_date, order_date_time ) as prev_dead_date,
			lag(order_date, -1) over (partition by key order by order_date, order_date_time asc) as next_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), -1) 
					over (partition by key order by order_date, order_date_time ASC) as next_dead_date,
			rank() over(partition BY key order by order_date, order_date_time desc) as rank
	from 	"customer_zip5"  
	WHERE price < 500000  
)

select	yyww, '전체' as product, '전체' as channel, 
		sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
		sum(order_price) as order_price, sum(new_price) as new_price,
		sum(sustain_price) as sustain_price, sum(sustain_price_w1) as sustain_price_w1, sum(sustain_price_w2) as sustain_price_w2, sum(sustain_price_w3) as sustain_price_w3, sum(sustain_price_w4) as sustain_price_w4, sum(sustain_price_w5) as sustain_price_w5,
		sum(return_price) as return_price, sum(return_price_w1) as return_price_w1, sum(return_price_w2) as return_price_w2, sum(return_price_w3) as return_price_w3, sum(return_price_w4) as return_price_w4, sum(return_price_w5) as return_price_w5,
		avg(active_term) as active_term, sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
		sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
		sum(sustain_cnt) as sustain_cnt, sum(sustain_cnt_w1) as sustain_cnt_w1, sum(sustain_cnt_w2) as sustain_cnt_w2, sum(sustain_cnt_w3) as sustain_cnt_w3, sum(sustain_cnt_w4) as sustain_cnt_w4, sum(sustain_cnt_w5) as sustain_cnt_w5,
		sum(return_cnt) as return_cnt, sum(return_cnt_w1) as return_cnt_w1, sum(return_cnt_w2) as return_cnt_w2, sum(return_cnt_w3) as return_cnt_w3, sum(return_cnt_w4) as return_cnt_w4, sum(return_cnt_w5) as return_cnt_w5,
		sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt
from	(
			select	yyww,
					case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then price else 0 end as order_price, -- 매출
					case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then price else 0 end as sustain_price_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then price else 0 end as sustain_price_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then price else 0 end as sustain_price_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then price else 0 end as sustain_price_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then price else 0 end as sustain_price_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then price else 0 end as return_price_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then price else 0 end as return_price_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then price else 0 end as return_price_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then price else 0 end as return_price_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then price else 0 end as return_price_w5, --(W>+4)
					case when yymmdd = order_date then active_term else null end as active_term,
					case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
					case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then 1 else 0 end as sustain_cnt_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then 1 else 0 end as return_cnt_w5, --(W>+4)
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
			from	purchase_term as t cross join "YMD2" as y 
		)as t
where	yyww = '2023-15'
group by yyww
order by yyww ASC



--wbr2최종 코호트  > DA
-- (상품별, 전체)
with purchase_term as (
	select 	key, product, order_date, order_date_time,
			order_qty * product_qty * term * 1.2 as real_term,
			case when order_qty * product_qty * term * 1.2 > 365 then 365 else order_qty * product_qty * term * 1.2 end as active_term,
			to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date,
			price,
			lag(order_date, +1) over (partition by key order by order_date, order_date_time asc) as prev_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), +1) 
					over (partition by key order by order_date, order_date_time asc) as prev_dead_date,
			lag(order_date, -1) over (partition by key order by order_date, order_date_time asc) as next_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), -1) 
					over (partition by key order by order_date, order_date_time asc) as next_dead_date,
			rank() over(partition BY key order by order_date, order_date_time desc) as rank
	from 	"customer_zip5"   
	WHERE price < 500000 
)

select	yyww,  product, '전체' as channel, 
		sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
		sum(order_price) as order_price, sum(new_price) as new_price,
		sum(sustain_price) as sustain_price, 
		sum(sustain_price_w1) as sustain_price_w1, sum(sustain_price_w2) as sustain_price_w2, sum(sustain_price_w3) as sustain_price_w3, sum(sustain_price_w4) as sustain_price_w4, sum(sustain_price_w5) as sustain_price_w5,
		sum(return_price) as return_price, 
		sum(return_price_w1) as return_price_w1, sum(return_price_w2) as return_price_w2, sum(return_price_w3) as return_price_w3, sum(return_price_w4) as return_price_w4, sum(return_price_w5) as return_price_w5,
		avg(active_term) as active_term, sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
		sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
		sum(sustain_cnt) as sustain_cnt, 
		sum(sustain_cnt_w1) as sustain_cnt_w1, sum(sustain_cnt_w2) as sustain_cnt_w2, sum(sustain_cnt_w3) as sustain_cnt_w3, sum(sustain_cnt_w4) as sustain_cnt_w4, sum(sustain_cnt_w5) as sustain_cnt_w5,
		sum(return_cnt) as return_cnt, 
		sum(return_cnt_w1) as return_cnt_w1, sum(return_cnt_w2) as return_cnt_w2, sum(return_cnt_w3) as return_cnt_w3, sum(return_cnt_w4) as return_cnt_w4, sum(return_cnt_w5) as return_cnt_w5,
		sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt
from	(
			select	yyww,  product,
					case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then price else 0 end as order_price, -- 매출
					case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then price else 0 end as sustain_price_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then price else 0 end as sustain_price_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then price else 0 end as sustain_price_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then price else 0 end as sustain_price_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then price else 0 end as sustain_price_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then price else 0 end as return_price_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then price else 0 end as return_price_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then price else 0 end as return_price_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then price else 0 end as return_price_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then price else 0 end as return_price_w5, --(W>+4)
					case when yymmdd = order_date then active_term else null end as active_term,
					case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
					case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then 1 else 0 end as sustain_cnt_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then 1 else 0 end as return_cnt_w5, --(W>+4)
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
			from	purchase_term as t cross join "YMD2" as y 
		)as t
where	yyww = '2023-15'
group by yyww, product
order by yyww asc




--wbr2최종 코호트 > DA
-- (전체, 스토어별)
with purchase_term as (
	select 	key, shop, order_date, order_date_time,
			order_qty * product_qty * term * 1.2 as real_term,
			case when order_qty * product_qty * term * 1.2 > 365 then 365 else order_qty * product_qty * term * 1.2 end as active_term,
			to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date,
			price,
			lag(order_date, +1) over (partition by key order by order_date, order_date_time asc) as prev_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), +1) 
					over (partition by key order by order_date, order_date_time asc) as prev_dead_date,
			lag(order_date, -1) over (partition by key order by order_date, order_date_time asc) as next_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), -1) 
					over (partition by key order by order_date, order_date_time asc) as next_dead_date,
			rank() over(partition BY key order by order_date, order_date_time desc) as rank
	from 	"customer_zip5" 
	WHERE price < 500000   
)


select	yyww, '전체' as product, shop, 
		sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
		sum(order_price) as order_price, sum(new_price) as new_price,
		sum(sustain_price) as sustain_price, sum(sustain_price_w1) as sustain_price_w1, sum(sustain_price_w2) as sustain_price_w2, sum(sustain_price_w3) as sustain_price_w3, sum(sustain_price_w4) as sustain_price_w4, sum(sustain_price_w5) as sustain_price_w5,
		sum(return_price) as return_price, sum(return_price_w1) as return_price_w1, sum(return_price_w2) as return_price_w2, sum(return_price_w3) as return_price_w3, sum(return_price_w4) as return_price_w4, sum(return_price_w5) as return_price_w5,
		avg(active_term) as active_term, sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
		sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
		sum(sustain_cnt) as sustain_cnt, sum(sustain_cnt_w1) as sustain_cnt_w1, sum(sustain_cnt_w2) as sustain_cnt_w2, sum(sustain_cnt_w3) as sustain_cnt_w3, sum(sustain_cnt_w4) as sustain_cnt_w4, sum(sustain_cnt_w5) as sustain_cnt_w5,
		sum(return_cnt) as return_cnt, sum(return_cnt_w1) as return_cnt_w1, sum(return_cnt_w2) as return_cnt_w2, sum(return_cnt_w3) as return_cnt_w3, sum(return_cnt_w4) as return_cnt_w4, sum(return_cnt_w5) as return_cnt_w5,
		sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt
from	(
			select	yyww, shop,
					case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then price else 0 end as order_price, -- 매출
					case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then price else 0 end as sustain_price_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then price else 0 end as sustain_price_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then price else 0 end as sustain_price_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then price else 0 end as sustain_price_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then price else 0 end as sustain_price_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then price else 0 end as return_price_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then price else 0 end as return_price_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then price else 0 end as return_price_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then price else 0 end as return_price_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then price else 0 end as return_price_w5, --(W>+4)
					case when yymmdd = order_date then active_term else null end as active_term,
					case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
					case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then 1 else 0 end as sustain_cnt_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then 1 else 0 end as return_cnt_w5, --(W>+4)
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
			from	purchase_term as t cross join "YMD2" as y 
		)as t
where	yyww = '2023-15'
group by yyww, shop
order by yyww ASC



--wbr2최종 코호트 > DA
-- (상품별, 스토어별)
with purchase_term as (
	select 	key, product, shop, order_date, order_date_time,
			order_qty * product_qty * term * 1.2 as real_term,
			case when order_qty * product_qty * term * 1.2 > 365 then 365 else order_qty * product_qty * term * 1.2 end as active_term,
			to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date,
			price,
			lag(order_date, +1) over (partition by key order by order_date, order_date_time asc) as prev_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), +1) 
					over (partition by key order by order_date, order_date_time asc) as prev_dead_date,
			lag(order_date, -1) over (partition by key order by order_date, order_date_time asc) as next_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), -1) 
					over (partition by key order by order_date, order_date_time asc) as next_dead_date,
			rank() over(partition BY key order by order_date, order_date_time desc) as rank
	from 	"customer_zip5"   
	WHERE price < 500000 
)

SELECT	 yyww, product, shop, 
		sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
		sum(order_price) as order_price, sum(new_price) as new_price,
		sum(sustain_price) as sustain_price, 
		sum(sustain_price_w1) as sustain_price_w1, sum(sustain_price_w2) as sustain_price_w2, sum(sustain_price_w3) as sustain_price_w3, sum(sustain_price_w4) as sustain_price_w4, sum(sustain_price_w5) as sustain_price_w5,
		sum(return_price) as return_price, 
		sum(return_price_w1) as return_price_w1, sum(return_price_w2) as return_price_w2, sum(return_price_w3) as return_price_w3, sum(return_price_w4) as return_price_w4, sum(return_price_w5) as return_price_w5,
		avg(active_term) as active_term, sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
		sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
		sum(sustain_cnt) as sustain_cnt, sum(sustain_cnt_w1) as sustain_cnt_w1, sum(sustain_cnt_w2) as sustain_cnt_w2, sum(sustain_cnt_w3) as sustain_cnt_w3, sum(sustain_cnt_w4) as sustain_cnt_w4, sum(sustain_cnt_w5) as sustain_cnt_w5,
		sum(return_cnt) as return_cnt, sum(return_cnt_w1) as return_cnt_w1, sum(return_cnt_w2) as return_cnt_w2, sum(return_cnt_w3) as return_cnt_w3, sum(return_cnt_w4) as return_cnt_w4, sum(return_cnt_w5) as return_cnt_w5,
		sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt


from	(
			select	yyww, product, shop,
					case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then price else 0 end as order_price, -- 매출
					case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then price else 0 end as sustain_price_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then price else 0 end as sustain_price_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then price else 0 end as sustain_price_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then price else 0 end as sustain_price_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then price else 0 end as sustain_price_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then price else 0 end as return_price_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then price else 0 end as return_price_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then price else 0 end as return_price_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then price else 0 end as return_price_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then price else 0 end as return_price_w5, --(W>+4)
					case when yymmdd = order_date then active_term else null end as active_term,
					case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
					case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then 1 else 0 end as sustain_cnt_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then 1 else 0 end as return_cnt_w5, --(W>+4)
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
			from	purchase_term as t cross join "YMD2" as y 
		)as t
where	yyww = '2023-15'
group BY yyww, product, shop
order by yyWW asc



-- (브랜드별, 전체)
with purchase_term as (
	select 	key, brand, order_date, order_date_time,
			order_qty * product_qty * term * 1.2 as real_term,
			case when order_qty * product_qty * term * 1.2 > 365 then 365 else order_qty * product_qty * term * 1.2 end as active_term,
			to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date,
			price,
			lag(order_date, +1) over (partition by key order by order_date, order_date_time asc) as prev_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), +1) 
					over (partition by key order by order_date, order_date_time asc) as prev_dead_date,
			lag(order_date, -1) over (partition by key order by order_date, order_date_time asc) as next_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), -1) 
					over (partition by key order by order_date, order_date_time asc) as next_dead_date,
			rank() over(partition BY key order by order_date, order_date_time desc) as rank
	from 	"customer_zip5"   
	WHERE price < 500000 
)

SELECT	 yyww, brand, '전체' AS shop,
		sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
		sum(order_price) as order_price, sum(new_price) as new_price,
		sum(sustain_price) as sustain_price, 
		sum(sustain_price_w1) as sustain_price_w1, sum(sustain_price_w2) as sustain_price_w2, sum(sustain_price_w3) as sustain_price_w3, sum(sustain_price_w4) as sustain_price_w4, sum(sustain_price_w5) as sustain_price_w5,
		sum(return_price) as return_price, 
		sum(return_price_w1) as return_price_w1, sum(return_price_w2) as return_price_w2, sum(return_price_w3) as return_price_w3, sum(return_price_w4) as return_price_w4, sum(return_price_w5) as return_price_w5,
		avg(active_term) as active_term, sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
		sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
		sum(sustain_cnt) as sustain_cnt, sum(sustain_cnt_w1) as sustain_cnt_w1, sum(sustain_cnt_w2) as sustain_cnt_w2, sum(sustain_cnt_w3) as sustain_cnt_w3, sum(sustain_cnt_w4) as sustain_cnt_w4, sum(sustain_cnt_w5) as sustain_cnt_w5,
		sum(return_cnt) as return_cnt, sum(return_cnt_w1) as return_cnt_w1, sum(return_cnt_w2) as return_cnt_w2, sum(return_cnt_w3) as return_cnt_w3, sum(return_cnt_w4) as return_cnt_w4, sum(return_cnt_w5) as return_cnt_w5,
		sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt


from	(
			select	yyww, brand,
					case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then price else 0 end as order_price, -- 매출
					case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then price else 0 end as sustain_price_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then price else 0 end as sustain_price_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then price else 0 end as sustain_price_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then price else 0 end as sustain_price_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then price else 0 end as sustain_price_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then price else 0 end as return_price_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then price else 0 end as return_price_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then price else 0 end as return_price_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then price else 0 end as return_price_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then price else 0 end as return_price_w5, --(W>+4)
					case when yymmdd = order_date then active_term else null end as active_term,
					case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
					case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then 1 else 0 end as sustain_cnt_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then 1 else 0 end as return_cnt_w5, --(W>+4)
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
			from	purchase_term as t cross join "YMD2" as y 
		)as t
where	yyww = '2023-15'
group BY yyww, brand
HAVING brand = '판토모나' OR brand = '페미론큐'
order by yyWW asc



-- (브랜드별, 스토어별)
with purchase_term as (
	select 	key, brand, shop, order_date, order_date_time,
			order_qty * product_qty * term * 1.2 as real_term,
			case when order_qty * product_qty * term * 1.2 > 365 then 365 else order_qty * product_qty * term * 1.2 end as active_term,
			to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date,
			price,
			lag(order_date, +1) over (partition by key order by order_date, order_date_time asc) as prev_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), +1) 
					over (partition by key order by order_date, order_date_time asc) as prev_dead_date,
			lag(order_date, -1) over (partition by key order by order_date, order_date_time asc) as next_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), -1) 
					over (partition by key order by order_date, order_date_time asc) as next_dead_date,
			rank() over(partition BY key order by order_date, order_date_time desc) as rank
	from 	"customer_zip5"   
	WHERE price < 500000 
)

SELECT	 yyww, brand, shop,
		sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
		sum(order_price) as order_price, sum(new_price) as new_price,
		sum(sustain_price) as sustain_price, 
		sum(sustain_price_w1) as sustain_price_w1, sum(sustain_price_w2) as sustain_price_w2, sum(sustain_price_w3) as sustain_price_w3, sum(sustain_price_w4) as sustain_price_w4, sum(sustain_price_w5) as sustain_price_w5,
		sum(return_price) as return_price, 
		sum(return_price_w1) as return_price_w1, sum(return_price_w2) as return_price_w2, sum(return_price_w3) as return_price_w3, sum(return_price_w4) as return_price_w4, sum(return_price_w5) as return_price_w5,
		avg(active_term) as active_term, sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
		sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
		sum(sustain_cnt) as sustain_cnt, sum(sustain_cnt_w1) as sustain_cnt_w1, sum(sustain_cnt_w2) as sustain_cnt_w2, sum(sustain_cnt_w3) as sustain_cnt_w3, sum(sustain_cnt_w4) as sustain_cnt_w4, sum(sustain_cnt_w5) as sustain_cnt_w5,
		sum(return_cnt) as return_cnt, sum(return_cnt_w1) as return_cnt_w1, sum(return_cnt_w2) as return_cnt_w2, sum(return_cnt_w3) as return_cnt_w3, sum(return_cnt_w4) as return_cnt_w4, sum(return_cnt_w5) as return_cnt_w5,
		sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt


from	(
			select	yyww, brand, shop,
					case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then price else 0 end as order_price, -- 매출
					case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then price else 0 end as sustain_price_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then price else 0 end as sustain_price_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then price else 0 end as sustain_price_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then price else 0 end as sustain_price_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then price else 0 end as sustain_price_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then price else 0 end as return_price_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then price else 0 end as return_price_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then price else 0 end as return_price_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then price else 0 end as return_price_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then price else 0 end as return_price_w5, --(W>+4)
					case when yymmdd = order_date then active_term else null end as active_term,
					case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
					case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then 1 else 0 end as sustain_cnt_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then 1 else 0 end as return_cnt_w5, --(W>+4)
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
			from	purchase_term as t cross join "YMD2" as y 
		)as t
where	yyww = '2023-15'
group BY yyww, brand, shop
HAVING brand = '판토모나' OR brand = '페미론큐'
order by yyWW ASC




-- 평균 구매 횟수
-- (전체, 전체)
-- (상품별, 전체)
-- (전체, 스토어별)
-- (상품별, 스토어별)
-- (브랜드별, 전체)
-- (브랜드별, 스토어별)

SELECT *
FROM 	(
			-- (전체, 전체)
			select	t1.yyww, '전체' as Product, '전체' as shop, sum(new_cnt) over (order by t1.yyww ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
			from	(	select	yyww, 									
								case when rank = 1 then count(*) else 0 end as new_cnt,							
								rank, count(*) as cnt							
						from	(								
									select	distinct key, yyww,					
											rank() over(partition BY KEY order by key ASC, yyww asc) as rank				
									from "customer_zip5"   as c 
									left join "YMD2" as y on (c.order_date = y.yymmdd)	
									where	key <> ''
								) t							
						group by yyww, rank									
					) t1 										
			where t1.yyww < '2023-99' 										
			
			UNION ALL 
			
			-- (상품, 전체)
			select	t1.yyww, t1.product, '전체' as shop, sum(new_cnt) over (order by t1.yyww ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
			from	(	select	yyww, Product, 									
								case when rank = 1 then count(*) else 0 end as new_cnt,							
								rank, count(*) as cnt							
						from	(								
									select	distinct key, Product, yyww,					
											rank() over(partition BY KEY, Product order by key ASC, yyww asc) as rank				
									from "customer_zip5"   as c 
									left join "YMD2" as y on (c.order_date = y.yymmdd)	
									where	key <> ''
								) t							
						group by yyww, Product, rank									
					) t1 										
			where t1.yyww < '2023-99' 										
			
			UNION ALL 
			
			-- (전체, 스토어)
			select	t1.yyww, '전체' as product, t1.shop, sum(new_cnt) over (order by t1.yyww ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
			from	(	select	yyww, shop, 									
								case when rank = 1 then count(*) else 0 end as new_cnt,							
								rank, count(*) as cnt							
						from	(								
									select	distinct key, shop, yyww,					
											rank() over(partition BY KEY, shop order by key ASC, yyww asc) as rank				
									from "customer_zip5"   as c 
									left join "YMD2" as y on (c.order_date = y.yymmdd)	
									where	key <> ''
								) t							
						group by yyww, shop, rank									
					) t1 										
			where t1.yyww < '2023-99' 										
			
			UNION ALL 
			
			-- (상품, 스토어)
			select	t1.yyww, t1.product, t1.shop, sum(new_cnt) over (order by t1.yyww ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
			from	(	select	yyww, Product, shop, 									
								case when rank = 1 then count(*) else 0 end as new_cnt,							
								rank, count(*) as cnt							
						from	(								
									select	distinct key, Product, shop, yyww,					
											rank() over(partition BY KEY, Product, shop order by key ASC, yyww asc) as rank				
									from "customer_zip5"   as c 
									left join "YMD2" as y on (c.order_date = y.yymmdd)	
									where	key <> ''
								) t							
						group by yyww, Product, shop, rank									
					) t1 										
			where t1.yyww < '2023-99'
			
			UNION ALL 
				
			-- (브랜드별, 전체)
			SELECT *
			FROM 	(
						select	t1.yyww, t1.brand, '전체' as shop, sum(new_cnt) over (order by t1.yyww ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
						from	(	select	yyww, brand, 									
											case when rank = 1 then count(*) else 0 end as new_cnt,							
											rank, count(*) as cnt							
									from	(								
												select	distinct key, brand,  yyww,					
														rank() over(partition BY KEY, brand order by key ASC, yyww asc) as rank				
												from "customer_zip5"   as c 
												left join "YMD2" as y on (c.order_date = y.yymmdd)	
												where	key <> ''
											) t							
									group by yyww, brand, rank									
								) t1 										
						where t1.yyww < '2023-99' 
						) AS t2
			WHERE brand = '판토모나' OR brand = '페미론큐'
			
			
			UNION ALL 

			-- (브랜드별, 스토어별)
			SELECT *
			FROM 	(
						select	t1.yyww, t1.brand, t1.shop, sum(new_cnt) over (order by t1.yyww ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
						from	(	select	yyww, brand, shop, 							
											case when rank = 1 then count(*) else 0 end as new_cnt,							
											rank, count(*) as cnt							
									from	(								
												select	distinct key, brand,  shop, yyww,					
														rank() over(partition BY KEY, brand, shop order by key ASC, yyww asc) as rank				
												from "customer_zip5"   as c 
												left join "YMD2" as y on (c.order_date = y.yymmdd)	
												where	key <> ''
											) t							
									group by yyww, brand, shop, rank									
								) t1 										
						where t1.yyww < '2023-99' 
						) AS t2
			WHERE brand = '판토모나' OR brand = '페미론큐'
		) AS t3
WHERE t3.yyww = '2023-15'




-- 평균 구매 종수
-- (전체, 전체)
-- (상품별, 전체)
-- (전체, 스토어별)
-- (상품별, 스토어별)
-- (브랜드별, 전체)
-- (브랜드별, 스토어별)

SELECT *
FROM 	(
			-- (전체, 전체)
			select	yyww, '전체' as Product, '전체' as shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
			from (
				select	key, yyww, max(sum) as key_cnt
				from (
						select 	key, yyww, rank, 
								sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yyww ASC, Product asc) as sum
						from (
								select 	distinct key, yyww, Product,
										rank() over(partition BY KEY, product order by key ASC, yyww ASC, Product asc) as rank
								from 	"customer_zip5"   as c 
								left join "YMD2" as y on (c.order_date = y.yymmdd)	
								where 	yyww < '2023-99'  and key <> ''
						) as t 
				) as t
				group by key, yyww
			) as t
			group by yyww, key_cnt
			
			UNION ALL 
			
			-- (상품별, 전체)
			select	yyww, Product, '전체' as shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
			from (
				select	key, yyww, Product, max(sum) as key_cnt
				from (
						select 	key, yyww, Product, rank, 
								sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yyww ASC, Product asc) as sum
						from (
								select 	distinct key, yyww, Product,
										rank() over(partition BY KEY, Product order by key ASC, yyww ASC, Product asc) as rank
								from 	"customer_zip5"   as c 
								left join "YMD2" as y on (c.order_date = y.yymmdd)	
								where 	yyww < '2023-99'  and key <> ''
						) as t 
				) as t
				group by key, yyww, product
			) as t
			group by yyww, Product, key_cnt
			
			UNION ALL 
			
			-- (전체, 스토어별)
			select	yyww, '전체' as Product, shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
			from (
				select	key, yyww, shop, max(sum) as key_cnt
				from (
						select 	key, yyww, shop, rank, 
								sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yyww ASC, product ASC, shop asc) as sum
						from (
								select 	distinct key, yyww, Product, shop,
										rank() over(partition BY KEY, Product, shop order by key ASC, yyww ASC, product ASC, shop asc) as rank
								from 	"customer_zip5"   as c 
								left join "YMD2" as y on (c.order_date = y.yymmdd)	
								where 	yyww < '2023-99'  and key <> ''
						) as t 
				) as t
				group by key, yyww, shop
			) as t
			group by yyww, shop, key_cnt
			
			UNION ALL 
			
			-- (상품별, 스토어별)
			select	yyww, Product, shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
			from (
				select	key, yyww, Product, shop, max(sum) as key_cnt
				from (
						select 	key, yyww, Product, shop, rank, 
								sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yyww ASC, product ASC, shop asc) as sum
						from (
								select 	distinct key, yyww, Product, shop,
										rank() over(partition BY KEY, Product, shop order by key ASC, yyww ASC, product ASC, shop asc) as rank
								from 	"customer_zip5"   as c 
								left join "YMD2" as y on (c.order_date = y.yymmdd)	
								where 	yyww < '2023-99'  and key <> ''
						) as t 
				) as t
				group by key, yyww, Product, shop
			) as t
			group by yyww, Product, shop, key_cnt
			
			UNION ALL 
			
			-- (브랜드별, 전체)
			SELECT *
			FROM 	(
						select	yyww, brand, '전체' as shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
						from (
							select	key, yyww, brand, max(sum) as key_cnt
							from (
									select 	key, yyww, brand, rank, 
											sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yyww ASC, brand asc) as sum
									from (
											select 	distinct key, yyww, brand,
													rank() over(partition BY KEY, brand order by key ASC, yyww ASC, brand asc) as rank
											from 	"customer_zip5"   as c 
											left join "YMD2" as y on (c.order_date = y.yymmdd)	
											where 	yyww < '2023-99'  and key <> ''
									) as t 
							) as t
							group by key, yyww, brand
						) as t
						group by yyww, brand, key_cnt
					) AS t1
			WHERE brand = '판토모나' OR brand = '페미론큐'
			
			UNION ALL 
			
			-- (브랜드별, 스토어별)
			SELECT *
			FROM 	(
						select	yyww, brand, shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
						from (
							select	key, yyww, brand, shop, max(sum) as key_cnt
							from (
									select 	key, yyww, brand, shop, rank, 
											sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yyww ASC, brand ASC, shop asc) as sum
									from (
											select 	distinct key, yyww, brand, shop,
													rank() over(partition BY KEY, brand, shop order by key ASC, yyww ASC, brand ASC, shop asc) as rank
											from 	"customer_zip5"   as c 
											left join "YMD2" as y on (c.order_date = y.yymmdd)	
											where 	yyww < '2023-99'  and key <> ''
									) as t 
							) as t
							group by key, yyww, brand, shop
						) as t
						group by yyww, brand, shop, key_cnt
					) AS t1
			WHERE brand = '판토모나' OR brand = '페미론큐'
		) AS t2
WHERE yyww = '2023-15'



-- 구매 수량별
-- (전체, 전체)
-- (상품별, 전체)
-- (전체, 스토어별)
-- (상품별, 스토어별)
-- (브랜드별, 전체)
-- (브랜드별, 스토어별)

SELECT *
FROM (
			
			-- (전체, 전체)
			select	yyww, '전체' as product, '전체' as shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yyww, order_qty*product_qty
			--order by yyww, qty
			
			UNION ALL 
			
			-- (상품별, 전체)
			select	yyww, product, '전체' as shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yyww, Product, order_qty*product_qty
			--order by yyww, Product, qty
			
			UNION ALL 
			
			-- (전체, 스토어별)
			select	yyww, '전체' as product, shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yyww, shop, order_qty*product_qty
			--order by yyww, shop, qty
			
			UNION ALL 
			
			-- (상품별, 스토어별)
			select	yyww, product, shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yyww, Product, shop, order_qty*product_qty
			--order by yyww, Product, shop, qty
			
			UNION ALL 
			
			-- (브랜드별, 전체)
			select	yyww, brand, '전체' as shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yyww, brand, order_qty*product_qty
			HAVING brand = '판토모나' OR brand = '페미론큐'
			--order by yyww, brand, qty
			
			UNION ALL 
			
			-- (브랜드별, 스토어별)
			select	yyww, brand, shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yyww, brand, shop, order_qty*product_qty
			HAVING brand = '판토모나' OR brand = '페미론큐'
			--order by yyww, brand, shop, qty
		) AS t
WHERE yyww = '2023-15'



-- 광고
-- (전체, 전체)
-- (상품별, 전체)
-- (전체, 스토어별)
-- (상품별, 스토어별)
-- (브랜드별, 전체)
-- (브랜드별, 스토어별)

SELECT *
FROM 	(
			
			-- (전체, 전체)
			SELECT 	yymm, yyww, yymmdd, channel, '전체' as Product, '전체'AS store, owned_keyword_type,
						SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click, SUM("order") AS "order", SUM(price) AS price
			FROM 		"ad_view6"
			GROUP BY yymm, yyww, yymmdd, channel, owned_keyword_type
			
			UNION ALL 
			
			-- (상품별, 전체)
			SELECT 	yymm, yyww, yymmdd, channel, Product, '전체'AS store, owned_keyword_type,
						SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click, SUM("order") AS "order", SUM(price) AS price
			FROM 		"ad_view6"
			GROUP BY yymm, yyww, yymmdd, channel, Product, owned_keyword_type
			
			UNION ALL 
			
			-- (전체, 스토어별)
			SELECT 	yymm, yyww, yymmdd, channel, '전체' as Product, store, owned_keyword_type,
						SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click, SUM("order") AS "order", SUM(price) AS price
			FROM 		"ad_view6"
			GROUP BY yymm, yyww, yymmdd, channel, store, owned_keyword_type
			
			UNION ALL 
			
			-- (상품별, 스토어별)
			SELECT 	yymm, yyww, yymmdd, channel, Product, store, owned_keyword_type,
						SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click, SUM("order") AS "order", SUM(price) AS price
			FROM 		"ad_view6"
			GROUP BY yymm, yyww, yymmdd, channel, Product, store, owned_keyword_type
			
			UNION ALL 
			
			-- (브랜드별, 전체)
			SELECT 	yymm, yyww, yymmdd, channel, brand, '전체'AS store, owned_keyword_type,
						SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click, SUM("order") AS "order", SUM(price) AS price
			FROM 		"ad_view6"
			GROUP BY yymm, yyww, yymmdd, channel, brand, owned_keyword_type
			HAVING brand = '판토모나' OR brand = '페미론큐'
			
			UNION ALL 
			
			-- (브랜드별, 스토어별)
			SELECT 	yymm, yyww, yymmdd, channel, brand, store, owned_keyword_type,
						SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click, SUM("order") AS "order", SUM(price) AS price
			FROM 		"ad_view6"
			GROUP BY yymm, yyww, yymmdd, channel, brand, store, owned_keyword_type
			HAVING brand = '판토모나' OR brand = '페미론큐'
) AS t
WHERE yyww = '2023-15'
Order BY yymmdd, channel, Product, store, owned_keyword_type



-- 컨텐츠
-- (전체, 전체)
-- (상품별, 전체)
-- (전체, 스토어별)
-- (상품별, 스토어별)
-- (브랜드별, 전체)
-- (브랜드별, 스토어별)

update "Naver_Custom_Order" set nt_medium = '2617' where nt_source='youtube' AND nt_medium <> '2617'

SELECT *
FROM "Naver_Custom_Order"
WHERE nt_source='youtube' AND nt_medium <> '2617'


SELECT *
FROM 	(
			
			-- (전체, 전체)
			SELECT 	yymm, yyww, yymmdd, channel, '전체' AS store, '전체' as nick, page_type, owned_keyword_type,
						SUM(cost1) AS cost1, SUM(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
			FROM "content_view2"
			WHERE (channel IN ('네이버', '구글') OR page_type IN ('파워컨텐츠', '인플루언서', '쇼핑상세'))
			GROUP BY yymm, yyww, yymmdd,  channel, page_type, owned_keyword_type
			
			UNION ALL 
			
			-- (상품별, 전체)
			SELECT 	yymm, yyww, yymmdd, channel, '전체' as store, nick, page_type, owned_keyword_type,
						SUM(cost1) AS cost1, SUM(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
			FROM "content_view2"
			WHERE (channel IN ('네이버', '구글') OR page_type IN ('파워컨텐츠', '인플루언서', '쇼핑상세'))
			GROUP BY yymm, yyww, yymmdd,  channel, nick, page_type, owned_keyword_type
			
			UNION ALL 
			
			-- (전체, 스토어별)
			SELECT 	yymm, yyww, yymmdd, channel, store, '전체' as nick, page_type, owned_keyword_type,
						SUM(cost1) AS cost1, SUM(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
			FROM "content_view2"
			WHERE (channel IN ('네이버', '구글') OR page_type IN ('파워컨텐츠', '인플루언서', '쇼핑상세'))
			GROUP BY yymm, yyww, yymmdd, channel, store, page_type, owned_keyword_type
			
			UNION ALL 
			
			-- (상품별, 스토어별)
			SELECT 	yymm, yyww, yymmdd, channel, store, nick, page_type, owned_keyword_type,
						SUM(cost1) AS cost1, SUM(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
			FROM "content_view2"
			WHERE (channel IN ('네이버', '구글') OR page_type IN ('파워컨텐츠', '인플루언서', '쇼핑상세'))
			GROUP BY yymm, yyww, yymmdd,  channel, store, brand, nick, page_type, owned_keyword_type
			
			UNION ALL 
			
			-- (브랜드별, 전체)
			SELECT 	yymm, yyww, yymmdd, channel, '전체' as store, brand, page_type, owned_keyword_type,
						SUM(cost1) AS cost1, SUM(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
			FROM "content_view2"
			WHERE (channel IN ('네이버', '구글') OR page_type IN ('파워컨텐츠', '인플루언서', '쇼핑상세'))
			GROUP BY yymm, yyww, yymmdd,  channel, brand, page_type, owned_keyword_type
			having brand = '판토모나' OR brand = '페미론큐'
			
			UNION ALL 
			
			-- (브랜드별, 스토어별)
			SELECT 	yymm, yyww, yymmdd, channel, store, brand, page_type, owned_keyword_type,
						SUM(cost1) AS cost1, SUM(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
			FROM "content_view2"
			WHERE (channel IN ('네이버', '구글') OR page_type IN ('파워컨텐츠', '인플루언서', '쇼핑상세'))
			GROUP BY yymm, yyww, yymmdd,  channel, store, brand, page_type, owned_keyword_type
			having brand = '판토모나' OR brand = '페미론큐'
		) AS t
WHERE yyww = '2023-15'
AND (cost1 > 0 OR cost2 > 0 OR pv > 0 OR cc > 0 OR cc2 > 0 OR inflow_cnt > 0 OR order_cnt > 0 OR order_price > 0)


------

데이터분석팀WBR리포트

------

-- (전체, 전체)
with purchase_term as (
	select 	key, order_date, order_date_time,
			order_qty * product_qty * term * 1.2 as real_term,
			case when order_qty * product_qty * term * 1.2 > 365 then 365 else order_qty * product_qty * term * 1.2 end as active_term,
			to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date,
			price,
			lag(order_date, +1) over (partition by key order by order_date, order_date_time asc) as prev_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), +1) 
					over (partition by key order by order_date, order_date_time asc) as prev_dead_date,
			lag(order_date, -1) over (partition by key order by order_date, order_date_time asc) as next_order_date,
			lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
					order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), -1) 
					over (partition by key order by order_date, order_date_time asc) as next_dead_date,
			rank() over(partition BY key order by order_date, order_date_time desc) as rank
	from 	"customer_zip5"  
	WHERE price < 500000  
)

select	yyww, yymmdd, '전체' as product, '전체' as channel, 
		sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
		sum(order_price) as order_price, sum(new_price) as new_price,
		sum(sustain_price) as sustain_price, sum(sustain_price_w1) as sustain_price_w1, sum(sustain_price_w2) as sustain_price_w2, sum(sustain_price_w3) as sustain_price_w3, sum(sustain_price_w4) as sustain_price_w4, sum(sustain_price_w5) as sustain_price_w5,
		sum(return_price) as return_price, sum(return_price_w1) as return_price_w1, sum(return_price_w2) as return_price_w2, sum(return_price_w3) as return_price_w3, sum(return_price_w4) as return_price_w4, sum(return_price_w5) as return_price_w5,
		avg(active_term) as active_term, sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
		sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
		sum(sustain_cnt) as sustain_cnt, sum(sustain_cnt_w1) as sustain_cnt_w1, sum(sustain_cnt_w2) as sustain_cnt_w2, sum(sustain_cnt_w3) as sustain_cnt_w3, sum(sustain_cnt_w4) as sustain_cnt_w4, sum(sustain_cnt_w5) as sustain_cnt_w5,
		sum(return_cnt) as return_cnt, sum(return_cnt_w1) as return_cnt_w1, sum(return_cnt_w2) as return_cnt_w2, sum(return_cnt_w3) as return_cnt_w3, sum(return_cnt_w4) as return_cnt_w4, sum(return_cnt_w5) as return_cnt_w5,
		sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt
from	(
			select	yyww, yymmdd,
					case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then price else 0 end as order_price, -- 매출
					case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then price else 0 end as sustain_price_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then price else 0 end as sustain_price_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then price else 0 end as sustain_price_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then price else 0 end as sustain_price_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then price else 0 end as sustain_price_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then price else 0 end as return_price_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then price else 0 end as return_price_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then price else 0 end as return_price_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then price else 0 end as return_price_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then price else 0 end as return_price_w5, --(W>+4)
					case when yymmdd = order_date then active_term else null end as active_term,
					case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
					case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
					case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
					case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
					case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
					case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then 1 else 0 end as sustain_cnt_w1, --(W-1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w2, --(W-2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w3, --(W-3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w4, --(W-4)
					case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w5, --(W<-4)
					case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w1, --(W+1)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w2, --(W+2)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w3, --(W+3)
					case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w4, --(W+4)
					case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then 1 else 0 end as return_cnt_w5, --(W>+4)
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
					case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
			from	purchase_term as t cross join "YMD2" as y 
		)as t
where	yyww = '2023-15'
group by yyww, yymmdd
order by yyww, yymmdd ASC



-- B2B 매출 마스터
SELECT *
FROM 	(

			-- (전체, 전체)
			SELECT yymm, yyww, yymmdd, '전체' AS store, '전체' AS nick, SUM(gross)
			FROM 	(
						SELECT yymm, yyww, yymmdd, s.name AS store, p.nick, SUM(gross) AS gross
						FROM "b2b_gross" AS b
						LEFT JOIN "store" AS s ON (b.store_no = s.no)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						LEFT JOIN "YMD2" AS y ON (b.order_date = y.yymmdd)
						GROUP BY yymm, yyww, yymmdd, s.name, p.nick
						
						UNION ALL 	
						
						SELECT y.yymm, y.yyww, y.yymmdd, store, nick, sum(amount) AS gross
						FROM 	(
									SELECT 	"substring"((o.order_date)::text, 1, 10) AS order_date,
												CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
												WHEN o."options" LIKE '%온유%' THEN '온유약국'
												ELSE s.name
												END AS store,
												o.nick,
												o.amount
									FROM 	(
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM "EZ_Order" AS o,
													(
														LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
														LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
														LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
													)
											) AS o
									LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
									WHERE 
											(
													(
														o.shop_id IN (10087, 10286) 
													)
												OR
													(
														o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
													)
												OR 
													(
														o."options" LIKE '%온유%'
													)
											) AND 
											o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' 
											AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									
								) AS t
						LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)
						GROUP BY y.yymm, y.yyww, y.yymmdd, store, nick
					) AS t
			GROUP BY yymm, yyww, yymmdd
			
			UNION ALL 
			
			-- (상품별, 전체)
			SELECT yymm, yyww, yymmdd, '전체' AS store, nick, SUM(gross)
			FROM 	(
						SELECT yymm, yyww, yymmdd, s.name AS store, p.nick, SUM(gross) AS gross
						FROM "b2b_gross" AS b
						LEFT JOIN "store" AS s ON (b.store_no = s.no)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						LEFT JOIN "YMD2" AS y ON (b.order_date = y.yymmdd)
						GROUP BY yymm, yyww, yymmdd, s.name, p.nick
						
						UNION ALL 	
						
						SELECT y.yymm, y.yyww, y.yymmdd, store, nick, sum(amount) AS gross
						FROM 	(
									SELECT 	"substring"((o.order_date)::text, 1, 10) AS order_date,
												CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
												WHEN o."options" LIKE '%온유%' THEN '온유약국'
												ELSE s.name
												END AS store,
												o.nick,
												o.amount
									FROM 	(
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM "EZ_Order" AS o,
													(
														LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
														LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
														LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
													)
											) AS o
									LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
									WHERE 
											(
													(
														o.shop_id IN (10087, 10286) 
													)
												OR
													(
														o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
													)
												OR 
													(
														o."options" LIKE '%온유%'
													)
											) AND 
											o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' 
											AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									
								) AS t
						LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)
						GROUP BY y.yymm, y.yyww, y.yymmdd, store, nick
					) AS t
			GROUP BY yymm, yyww, yymmdd, nick
			
			UNION ALL 
			
			-- (전체, 스토어별)
			SELECT yymm, yyww, yymmdd, store, '전체' AS nick, SUM(gross)
			FROM 	(
						SELECT yymm, yyww, yymmdd, s.name AS store, p.nick, SUM(gross) AS gross
						FROM "b2b_gross" AS b
						LEFT JOIN "store" AS s ON (b.store_no = s.no)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						LEFT JOIN "YMD2" AS y ON (b.order_date = y.yymmdd)
						GROUP BY yymm, yyww, yymmdd, s.name, p.nick
						
						UNION ALL 	
						
						SELECT y.yymm, y.yyww, y.yymmdd, store, nick, sum(amount) AS gross
						FROM 	(
									SELECT 	"substring"((o.order_date)::text, 1, 10) AS order_date,
												CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
												WHEN o."options" LIKE '%온유%' THEN '온유약국'
												ELSE s.name
												END AS store,
												o.nick,
												o.amount
									FROM 	(
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM "EZ_Order" AS o,
													(
														LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
														LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
														LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
													)
											) AS o
									LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
									WHERE 
											(
													(
														o.shop_id IN (10087, 10286) 
													)
												OR
													(
														o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
													)
												OR 
													(
														o."options" LIKE '%온유%'
													)
											) AND 
											o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' 
											AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									
								) AS t
						LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)
						GROUP BY y.yymm, y.yyww, y.yymmdd, store, nick
					) AS t
			GROUP BY yymm, yyww, yymmdd, store
			
			UNION ALL 
			
			-- (상품별, 스토어별)
			SELECT yymm, yyww, yymmdd, store, nick, SUM(gross)
			FROM 	(
						SELECT yymm, yyww, yymmdd, s.name AS store, p.nick, SUM(gross) AS gross
						FROM "b2b_gross" AS b
						LEFT JOIN "store" AS s ON (b.store_no = s.no)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						LEFT JOIN "YMD2" AS y ON (b.order_date = y.yymmdd)
						GROUP BY yymm, yyww, yymmdd, s.name, p.nick
						
						UNION ALL 	
						
						SELECT y.yymm, y.yyww, y.yymmdd, store, nick, sum(amount) AS gross
						FROM 	(
									SELECT 	"substring"((o.order_date)::text, 1, 10) AS order_date,
												CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
												WHEN o."options" LIKE '%온유%' THEN '온유약국'
												ELSE s.name
												END AS store,
												o.nick,
												o.amount
									FROM 	(
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM "EZ_Order" AS o,
													(
														LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
														LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
														LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
													)
											) AS o
									LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
									WHERE 
											(
													(
														o.shop_id IN (10087, 10286) 
													)
												OR
													(
														o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
													)
												OR 
													(
														o."options" LIKE '%온유%'
													)
											) AND 
											o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' 
											AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									
								) AS t
						LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)
						GROUP BY y.yymm, y.yyww, y.yymmdd, store, nick
					) AS t
			GROUP BY yymm, yyww, yymmdd, store, nick
			
			UNION ALL 
			
			-- (브랜드별, 전체)
			SELECT yymm, yyww, yymmdd, '전체' as store, left(nick, 4) AS brand,  SUM(gross)
			FROM 	(
						SELECT yymm, yyww, yymmdd, s.name AS store, p.nick, SUM(gross) AS gross
						FROM "b2b_gross" AS b
						LEFT JOIN "store" AS s ON (b.store_no = s.no)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						LEFT JOIN "YMD2" AS y ON (b.order_date = y.yymmdd)
						GROUP BY yymm, yyww, yymmdd, s.name, p.nick
						
						UNION ALL 	
						
						SELECT y.yymm, y.yyww, y.yymmdd, store, nick, sum(amount) AS gross
						FROM 	(
									SELECT 	"substring"((o.order_date)::text, 1, 10) AS order_date,
												CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
												WHEN o."options" LIKE '%온유%' THEN '온유약국'
												ELSE s.name
												END AS store,
												o.nick,
												o.amount
									FROM 	(
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM "EZ_Order" AS o,
													(
														LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
														LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
														LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
													)
											) AS o
									LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
									WHERE 
											(
													(
														o.shop_id IN (10087, 10286) 
													)
												OR
													(
														o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
													)
												OR 
													(
														o."options" LIKE '%온유%'
													)
											) AND 
											o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' 
											AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									
								) AS t
						LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)
						GROUP BY y.yymm, y.yyww, y.yymmdd, store, nick
					) AS t
			WHERE nick LIKE '%판토모나%' OR nick LIKE '%페미론큐%'
			GROUP BY yymm, yyww, yymmdd, nick
			
			UNION ALL 
			
			-- (브랜드별, 스토어별)
			SELECT yymm, yyww, yymmdd, store, left(nick, 4) AS brand,  SUM(gross)
			FROM 	(
						SELECT yymm, yyww, yymmdd, s.name AS store, p.nick, SUM(gross) AS gross
						FROM "b2b_gross" AS b
						LEFT JOIN "store" AS s ON (b.store_no = s.no)
						LEFT JOIN "product" AS p ON (b.product_no = p.no)
						LEFT JOIN "YMD2" AS y ON (b.order_date = y.yymmdd)
						GROUP BY yymm, yyww, yymmdd, s.name, p.nick
						
						UNION ALL 	
						
						SELECT y.yymm, y.yyww, y.yymmdd, store, nick, sum(amount) AS gross
						FROM 	(
									SELECT 	"substring"((o.order_date)::text, 1, 10) AS order_date,
												CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
												WHEN o."options" LIKE '%온유%' THEN '온유약국'
												ELSE s.name
												END AS store,
												o.nick,
												o.amount
									FROM 	(
												SELECT *, p.qty AS order_qty, b.qty AS product_qty
												FROM "EZ_Order" AS o,
													(
														LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
														LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
														LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
													)
											) AS o
									LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
									WHERE 
											(
													(
														o.shop_id IN (10087, 10286) 
													)
												OR
													(
														o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
													)
												OR 
													(
														o."options" LIKE '%온유%'
													)
											) AND 
											o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' 
											AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									
								) AS t
						LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)
						GROUP BY y.yymm, y.yyww, y.yymmdd, store, nick
					) AS t
			WHERE nick LIKE '%판토모나%' OR nick LIKE '%페미론큐%'
			GROUP BY yymm, yyww, yymmdd, store, nick
		) AS t2
WHERE t2.yyww = '2023-15'
Order BY yyww




-- 리셀러 (50만원 이상) 마스터

SELECT *
FROM 	(
			-- (전체, 전체)
			SELECT y.yymm, y.yyww, y.yymmdd, '전체' AS shop, '전체' as product, SUM(price) AS price
			FROM "customer_zip5" AS c
			LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
			WHERE price >= 500000
			GROUP BY y.yymm, y.yyww, y.yymmdd
			--Order BY y.yymmdd desc
			
			UNION ALL 
			
			-- (상품별, 전체)
			SELECT y.yymm, y.yyww, y.yymmdd, '전체' AS shop, c.product, SUM(price) AS price
			FROM "customer_zip5" AS c
			LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
			WHERE price >= 500000
			GROUP BY y.yymm, y.yyww, y.yymmdd, c.product
			--Order BY y.yymmdd desc
			
			UNION ALL 
			
			-- (전체, 스토어별)
			SELECT y.yymm, y.yyww, y.yymmdd, c.shop, '전체' as product, SUM(price) AS price
			FROM "customer_zip5" AS c
			LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
			WHERE price >= 500000
			GROUP BY y.yymm, y.yyww, y.yymmdd, c.shop
			--Order BY y.yymmdd DESC
			
			UNION ALL 
			
			-- (상품별, 스토어별)
			SELECT y.yymm, y.yyww, y.yymmdd, c.shop, c.product, SUM(price) AS price
			FROM "customer_zip5" AS c
			LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
			WHERE price >= 500000
			GROUP BY y.yymm, y.yyww, y.yymmdd, c.shop, c.product
			--Order BY y.yymmdd desc
			
			UNION ALL 
			
			-- (브랜드별, 전체)
			SELECT y.yymm, y.yyww, y.yymmdd, '전체' AS shop, c.brand, SUM(price) AS price
			FROM "customer_zip5" AS c
			LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
			WHERE price >= 500000
			GROUP BY y.yymm, y.yyww, y.yymmdd, c.brand
			HAVING brand = '판토모나' OR brand = '페미론큐'
			--Order BY y.yymmdd DESC
			
			UNION ALL 
			
			-- (브랜드별, 스토어별)
			SELECT y.yymm, y.yyww, y.yymmdd, c.shop, c.brand, SUM(price) AS price
			FROM "customer_zip5" AS c
			LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
			WHERE price >= 500000
			GROUP BY y.yymm, y.yyww, y.yymmdd, c.shop, c.brand
			HAVING brand = '판토모나' OR brand = '페미론큐'
			--Order BY y.yymmdd DESC	
		) AS t
WHERE t.yyww = '2023-15'
Order BY t.yyww	

