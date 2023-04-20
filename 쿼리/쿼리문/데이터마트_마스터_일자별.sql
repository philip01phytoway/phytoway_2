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

select	yymmdd, '전체' as product, '전체' as channel, 
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
			select	yymmdd,
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
where	yymmdd between '2023-04-12' AND '2023-04-18'
group by yymmdd
order by yymmdd ASC


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

select	yymmdd,  product, '전체' as channel, 
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
			select	yymmdd,  product,
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
where	yymmdd between '2023-04-12' AND '2023-04-18'
group by yymmdd, product
order by yymmdd asc



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


select	yymmdd, '전체' as product, shop, 
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
			select	yymmdd, shop,
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
where	yymmdd between '2023-04-12' AND '2023-04-18'
group by yymmdd, shop
order by yymmdd ASC



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

SELECT	 yymmdd, product, shop, 
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
			select	yymmdd, product, shop,
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
where	yymmdd between '2023-04-12' AND '2023-04-18'
group BY yymmdd, product, shop
order by yymmdd asc


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

SELECT	 yymmdd, brand, '전체' AS shop,
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
			select	yymmdd, brand,
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
where	yymmdd between '2023-04-12' AND '2023-04-18'
group BY yymmdd, brand
HAVING brand = '판토모나' OR brand = '페미론큐'
order by yymmdd asc



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

SELECT	 yymmdd, brand, shop,
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
			select	yymmdd, brand, shop,
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
where	yymmdd between '2023-04-12' AND '2023-04-18'
group BY yymmdd, brand, shop
HAVING brand = '판토모나' OR brand = '페미론큐'
order by yymmdd ASC



--------------------------

평균 구매 지표

--------------------------


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
			select	t1.yymmdd, '전체' as Product, '전체' as shop, sum(new_cnt) over (order by t1.yymmdd ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
			from	(	select	yymmdd, 									
								case when rank = 1 then count(*) else 0 end as new_cnt,							
								rank, count(*) as cnt							
						from	(								
									select	distinct key, yymmdd,					
											rank() over(partition BY KEY order by key ASC, yymmdd asc) as rank				
									from "customer_zip5"   as c 
									left join "YMD2" as y on (c.order_date = y.yymmdd)	
									where	key <> ''
								) t							
						group by yymmdd, rank									
					) t1 										
			where t1.yymmdd < '2023-12-31' 										
			
			UNION ALL 
			
			-- (상품, 전체)
			select	t1.yymmdd, t1.product, '전체' as shop, sum(new_cnt) over (order by t1.yymmdd ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
			from	(	select	yymmdd, Product, 									
								case when rank = 1 then count(*) else 0 end as new_cnt,							
								rank, count(*) as cnt							
						from	(								
									select	distinct key, Product, yymmdd,					
											rank() over(partition BY KEY, Product order by key ASC, yymmdd asc) as rank				
									from "customer_zip5"   as c 
									left join "YMD2" as y on (c.order_date = y.yymmdd)	
									where	key <> ''
								) t							
						group by yymmdd, Product, rank									
					) t1 										
			where t1.yymmdd < '2023-12-31' 										
			
			UNION ALL 
			
			-- (전체, 스토어)
			select	t1.yymmdd, '전체' as product, t1.shop, sum(new_cnt) over (order by t1.yymmdd ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
			from	(	select	yymmdd, shop, 									
								case when rank = 1 then count(*) else 0 end as new_cnt,							
								rank, count(*) as cnt							
						from	(								
									select	distinct key, shop, yymmdd,					
											rank() over(partition BY KEY, shop order by key ASC, yymmdd asc) as rank				
									from "customer_zip5"   as c 
									left join "YMD2" as y on (c.order_date = y.yymmdd)	
									where	key <> ''
								) t							
						group by yymmdd, shop, rank									
					) t1 										
			where t1.yymmdd < '2023-12-31' 										
			
			UNION ALL 
			
			-- (상품, 스토어)
			select	t1.yymmdd, t1.product, t1.shop, sum(new_cnt) over (order by t1.yymmdd ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
			from	(	select	yymmdd, Product, shop, 									
								case when rank = 1 then count(*) else 0 end as new_cnt,							
								rank, count(*) as cnt							
						from	(								
									select	distinct key, Product, shop, yymmdd,					
											rank() over(partition BY KEY, Product, shop order by key ASC, yymmdd asc) as rank				
									from "customer_zip5"   as c 
									left join "YMD2" as y on (c.order_date = y.yymmdd)	
									where	key <> ''
								) t							
						group by yymmdd, Product, shop, rank									
					) t1 										
			where t1.yymmdd < '2023-12-31'
			
			UNION ALL 
				
			-- (브랜드별, 전체)
			SELECT *
			FROM 	(
						select	t1.yymmdd, t1.brand, '전체' as shop, sum(new_cnt) over (order by t1.yymmdd ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
						from	(	select	yymmdd, brand, 									
											case when rank = 1 then count(*) else 0 end as new_cnt,							
											rank, count(*) as cnt							
									from	(								
												select	distinct key, brand,  yymmdd,					
														rank() over(partition BY KEY, brand order by key ASC, yymmdd asc) as rank				
												from "customer_zip5"   as c 
												left join "YMD2" as y on (c.order_date = y.yymmdd)	
												where	key <> ''
											) t							
									group by yymmdd, brand, rank									
								) t1 										
						where t1.yymmdd < '2023-12-31' 
						) AS t2
			WHERE brand = '판토모나' OR brand = '페미론큐'
			
			
			UNION ALL 

			-- (브랜드별, 스토어별)
			SELECT *
			FROM 	(
						select	t1.yymmdd, t1.brand, t1.shop, sum(new_cnt) over (order by t1.yymmdd ASC) as tot_cnt, rank, cnt, rank * cnt as etc1									
						from	(	select	yymmdd, brand, shop, 							
											case when rank = 1 then count(*) else 0 end as new_cnt,							
											rank, count(*) as cnt							
									from	(								
												select	distinct key, brand,  shop, yymmdd,					
														rank() over(partition BY KEY, brand, shop order by key ASC, yymmdd asc) as rank				
												from "customer_zip5"   as c 
												left join "YMD2" as y on (c.order_date = y.yymmdd)	
												where	key <> ''
											) t							
									group by yymmdd, brand, shop, rank									
								) t1 										
						where t1.yymmdd < '2023-12-31' 
						) AS t2
			WHERE brand = '판토모나' OR brand = '페미론큐'
		) AS t3
WHERE t3.yymmdd BETWEEN '2023-04-12' AND '2023-04-18'




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
			select	yymmdd, '전체' as Product, '전체' as shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
			from (
				select	key, yymmdd, max(sum) as key_cnt
				from (
						select 	key, yymmdd, rank, 
								sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yymmdd ASC, Product asc) as sum
						from (
								select 	distinct key, yymmdd, Product,
										rank() over(partition BY KEY, product order by key ASC, yymmdd ASC, Product asc) as rank
								from 	"customer_zip5"   as c 
								left join "YMD2" as y on (c.order_date = y.yymmdd)	
								where 	yymmdd < '2023-12-31'  and key <> ''
						) as t 
				) as t
				group by key, yymmdd
			) as t
			group by yymmdd, key_cnt
			
			UNION ALL 
			
			-- (상품별, 전체)
			select	yymmdd, Product, '전체' as shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
			from (
				select	key, yymmdd, Product, max(sum) as key_cnt
				from (
						select 	key, yymmdd, Product, rank, 
								sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yymmdd ASC, Product asc) as sum
						from (
								select 	distinct key, yymmdd, Product,
										rank() over(partition BY KEY, Product order by key ASC, yymmdd ASC, Product asc) as rank
								from 	"customer_zip5"   as c 
								left join "YMD2" as y on (c.order_date = y.yymmdd)	
								where 	yymmdd < '2023-12-31'  and key <> ''
						) as t 
				) as t
				group by key, yymmdd, product
			) as t
			group by yymmdd, Product, key_cnt
			
			UNION ALL 
			
			-- (전체, 스토어별)
			select	yymmdd, '전체' as Product, shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
			from (
				select	key, yymmdd, shop, max(sum) as key_cnt
				from (
						select 	key, yymmdd, shop, rank, 
								sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yymmdd ASC, product ASC, shop asc) as sum
						from (
								select 	distinct key, yymmdd, Product, shop,
										rank() over(partition BY KEY, Product, shop order by key ASC, yymmdd ASC, product ASC, shop asc) as rank
								from 	"customer_zip5"   as c 
								left join "YMD2" as y on (c.order_date = y.yymmdd)	
								where 	yymmdd < '2023-12-31'  and key <> ''
						) as t 
				) as t
				group by key, yymmdd, shop
			) as t
			group by yymmdd, shop, key_cnt
			
			UNION ALL 
			
			-- (상품별, 스토어별)
			select	yymmdd, Product, shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
			from (
				select	key, yymmdd, Product, shop, max(sum) as key_cnt
				from (
						select 	key, yymmdd, Product, shop, rank, 
								sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yymmdd ASC, product ASC, shop asc) as sum
						from (
								select 	distinct key, yymmdd, Product, shop,
										rank() over(partition BY KEY, Product, shop order by key ASC, yymmdd ASC, product ASC, shop asc) as rank
								from 	"customer_zip5"   as c 
								left join "YMD2" as y on (c.order_date = y.yymmdd)	
								where 	yymmdd < '2023-12-31'  and key <> ''
						) as t 
				) as t
				group by key, yymmdd, Product, shop
			) as t
			group by yymmdd, Product, shop, key_cnt
			
			UNION ALL 
			
			-- (브랜드별, 전체)
			SELECT *
			FROM 	(
						select	yymmdd, brand, '전체' as shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
						from (
							select	key, yymmdd, brand, max(sum) as key_cnt
							from (
									select 	key, yymmdd, brand, rank, 
											sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yymmdd ASC, brand asc) as sum
									from (
											select 	distinct key, yymmdd, brand,
													rank() over(partition BY KEY, brand order by key ASC, yymmdd ASC, brand asc) as rank
											from 	"customer_zip5"   as c 
											left join "YMD2" as y on (c.order_date = y.yymmdd)	
											where 	yymmdd < '2023-12-31'  and key <> ''
									) as t 
							) as t
							group by key, yymmdd, brand
						) as t
						group by yymmdd, brand, key_cnt
					) AS t1
			WHERE brand = '판토모나' OR brand = '페미론큐'
			
			UNION ALL 
			
			-- (브랜드별, 스토어별)
			SELECT *
			FROM 	(
						select	yymmdd, brand, shop, key_cnt, count(*) as cnt, key_cnt * count(*) as etc
						from (
							select	key, yymmdd, brand, shop, max(sum) as key_cnt
							from (
									select 	key, yymmdd, brand, shop, rank, 
											sum(case  when rank = 1 then 1 else 0 end) over(partition BY KEY order by key ASC, yymmdd ASC, brand ASC, shop asc) as sum
									from (
											select 	distinct key, yymmdd, brand, shop,
													rank() over(partition BY KEY, brand, shop order by key ASC, yymmdd ASC, brand ASC, shop asc) as rank
											from 	"customer_zip5"   as c 
											left join "YMD2" as y on (c.order_date = y.yymmdd)	
											where 	yymmdd < '2023-12-31'  and key <> ''
									) as t 
							) as t
							group by key, yymmdd, brand, shop
						) as t
						group by yymmdd, brand, shop, key_cnt
					) AS t1
			WHERE brand = '판토모나' OR brand = '페미론큐'
		) AS t2
WHERE yymmdd between '2023-04-12' AND '2023-04-18'



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
			select	yymmdd, '전체' as product, '전체' as shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yymmdd, order_qty*product_qty
			--order by yymmdd, qty
			
			UNION ALL 
			
			-- (상품별, 전체)
			select	yymmdd, product, '전체' as shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yymmdd, Product, order_qty*product_qty
			--order by yymmdd, Product, qty
			
			UNION ALL 
			
			-- (전체, 스토어별)
			select	yymmdd, '전체' as product, shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yymmdd, shop, order_qty*product_qty
			--order by yymmdd, shop, qty
			
			UNION ALL 
			
			-- (상품별, 스토어별)
			select	yymmdd, product, shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yymmdd, Product, shop, order_qty*product_qty
			--order by yymmdd, Product, shop, qty
			
			UNION ALL 
			
			-- (브랜드별, 전체)
			select	yymmdd, brand, '전체' as shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yymmdd, brand, order_qty*product_qty
			HAVING brand = '판토모나' OR brand = '페미론큐'
			--order by yymmdd, brand, qty
			
			UNION ALL 
			
			-- (브랜드별, 스토어별)
			select	yymmdd, brand, shop, order_qty*product_qty as qty, count(*) as cnt
			from	"customer_zip5"   as c
			left join "YMD2" as y on (c.order_date = y.yymmdd)
			where	order_date > '2022-10-01'
			group by yymmdd, brand, shop, order_qty*product_qty
			HAVING brand = '판토모나' OR brand = '페미론큐'
			--order by yymmdd, brand, shop, qty
		) AS t
WHERE yymmdd between '2023-04-12' AND '2023-04-18'




