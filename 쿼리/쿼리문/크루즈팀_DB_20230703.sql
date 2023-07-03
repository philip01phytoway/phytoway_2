-- 전체, 제품별
-- 매출 포함
-- 리셀러 제외 (50만원 이상 제외)
-- 취소, 반품 제외
-- 추후 쿼리문 리팩토링 필요


-- 만료건수 전체
select	key_rank, sum(order_cnt) as dead_cnt, sum(prd_amount_mod) as dead_price
from 	(
			select 	*,
					TO_CHAR(CASE 
								WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
								ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
							END, 'yyyy-mm-dd')
					AS dead_date_2,
					dense_rank() over(partition by key order by order_date_time) as "key_rank"
			from 	"order_batch"
			where order_id <> '' AND phytoway = 'y' and prd_amount_mod < 500000 and order_status = '주문'
		) as t
where dead_date_2 BETWEEN '2023-01-01' AND '2023-06-01'			
group by key_rank


-- 재구매건수 전체
select 	key_rank, sum(order_cnt) as reorder_cnt, sum(prd_amount_mod) as reorder_price
from 	(
			select 	*,
					TO_CHAR(CASE 
								WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
								ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
							END, 'yyyy-mm-dd')
					AS dead_date_2,
					lag(order_date, -1) over (partition by key order BY order_date_time asc) as next_order_date_2,
					dense_rank() over(partition by key order by order_date_time) as "key_rank"
			from 	"order_batch"
			where order_id <> '' AND phytoway = 'y' and prd_amount_mod < 500000 and order_status = '주문'
		) as t
WHERE dead_date_2 BETWEEN '2023-01-01' AND '2023-06-01' AND (next_order_date_2 BETWEEN order_date AND dead_date_2)
group by key_rank



-- 만료건수 제품별
select	nick, key_nick_rank, sum(order_cnt), sum(prd_amount_mod) as dead_price
from 	(
			select 	*,
					TO_CHAR(CASE 
								WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
								ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
							END, 'yyyy-mm-dd')
					AS dead_date_2,
					dense_rank() over(partition by key, nick order by order_date_time) as "key_nick_rank"
			from 	"order_batch"
			where order_id <> '' AND phytoway = 'y' and prd_amount_mod < 500000 and order_status = '주문'
		) as t
where dead_date_2 BETWEEN '2023-01-01' AND '2023-06-01'			
group by nick, key_nick_rank




-- 재구매건수 제품별
select	nick, key_nick_rank, sum(order_cnt), sum(prd_amount_mod) as dead_price
from 	(
			select 	*,
					TO_CHAR(CASE 
								WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
								ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
							END, 'yyyy-mm-dd')
					AS dead_date_2,
					lag(order_date, -1) over (partition by key, nick order BY order_date_time asc) as next_order_date_2,
					dense_rank() over(partition by key, nick order by order_date_time) as "key_nick_rank"
			from 	"order_batch"
			where order_id <> '' AND phytoway = 'y' and prd_amount_mod < 500000 and order_status = '주문'
		) as t
WHERE dead_date_2 BETWEEN '2023-01-01' AND '2023-06-01' AND (next_order_date_2 BETWEEN order_date AND dead_date_2)
group by nick, key_nick_rank