select 	*,
		CASE 
			WHEN order_id <> '' AND phytoway = 'y' THEN
				TO_CHAR(CASE 
								WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
								ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
							END, 'yyyy-mm-dd')
			ELSE ''
		END AS dead_date_2
from 	"order_batch"
limit 10




-- 만료건수
select SUM(order_cnt) AS dead_cnt
from 	(
			SELECT * 
			from 	(
						select 	*,
								max(key_rank) over(partition by key) as max_key_rank
						from 	(
									select 	*,
											TO_CHAR(CASE 
														WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
														ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
													END, 'yyyy-mm-dd')
											AS dead_date_2,
											dense_rank() over(partition by key order by order_date_time) as "key_rank"
									from 	"order_batch"
									where order_id <> '' AND phytoway = 'y'
								) as t
					) as t2
			WHERE max_key_rank > 3 
		) as t3
where dead_date_2 BETWEEN '2023-01-01' AND '2023-06-01'



-- 이탈건수
-- 만료일자 기간 수정하여 사용
select SUM(order_cnt) AS chuck_cnt
from 	(
			SELECT * 
			from 	(
						select 	*,
								max(key_nick_rank) over(partition by key, nick) as max_key_nick_rank
						from 	(
									select 	*,
											TO_CHAR(CASE 
														WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
														ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
													END, 'yyyy-mm-dd')
											AS dead_date_2,
											dense_rank() over(partition by key, nick order by order_date_time) as "key_nick_rank"
									from 	"order_batch"
									where order_id <> '' AND phytoway = 'y'
								) as t
					) as t2
			WHERE max_key_nick_rank = 2 and nick = '판토모나하이퍼포머'
		) as t3
WHERE dead_date_2 BETWEEN '2023-03-08' AND '2023-03-14' AND (next_order_date IS NULL OR next_order_date > dead_date_2)


-- 재구매건수
select SUM(order_cnt) AS reorder_cnt
from 	(
			SELECT * 
			from 	(
						select 	*,
								max(key_rank) over(partition by key) as max_key_rank
						from 	(
									select 	*,
											TO_CHAR(CASE 
														WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
														ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
													END, 'yyyy-mm-dd')
											AS dead_date_2,
											dense_rank() over(partition by key order by order_date_time) as "key_rank"
									from 	"order_batch"
									where order_id <> '' AND phytoway = 'y'
								) as t
					) as t2
			WHERE max_key_rank > 3 
		) as t3
WHERE dead_date_2 BETWEEN '2023-01-01' AND '2023-06-01' AND (next_order_date BETWEEN order_date AND dead_date_2)




-- 구매매출, 구매건수, 평균구매금액
-- 주문일자 기간 수정하여 사용
SELECT SUM(prd_amount_mod) AS order_price, SUM(order_cnt) AS order_cnt, SUM(prd_amount_mod) / SUM(order_cnt) AS "avg_order_price"
from 	(
			select 	*,
					CASE 
						WHEN order_id <> '' AND phytoway = 'y' THEN
							TO_CHAR(CASE 
											WHEN order_qty * product_qty * term * 1.33 > 365 THEN order_date::date + interval '1 day' * 365 
											ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.33
										END, 'yyyy-mm-dd')
						ELSE ''
					END AS dead_date_2
			from 	"order_batch"
		) as t
WHERE order_date BETWEEN '2023-03-08' AND '2023-03-14'



-- 구매횟수


select * 
from "order_batch"
where key = 'HONG SUNG HEElyv4****'

where dead_date <> '' and phytoway = 'n'

