


select	start_mm, mm, count(*)
from 	(
			select	distinct key, start_mm, mm
			from	(
						select	key,
								to_char(first_value (month) over (partition by key order by month asc), 'yyyy-mm') as start_mm,
								to_char(month, 'yyyy-mm') as mm
						from	(
									select	o.customer_key as key,
											generate_series(
												DATE_TRUNC('month', o.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									from	"order" as o 
									LEFT JOIN "order_option" as oo on (o.no = oo.order_no) 
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.category <> '기타' 
									AND o.no not in (select order_no from "non_order")
									AND o.no NOT IN (SELECT no FROM "order" WHERE order_type IN ('취소', '반품'))
									--order by 1,2
									
									UNION ALL 
									
									SELECT 	customer_key AS key,
												generate_series(
												DATE_TRUNC('month', oo.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									FROM "order_option2" AS oo
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.category <> '기타' 
									AND oo.no not in (select order_no from "non_order")
									
								) as t
			) as t
) as t
group by 1,2
order by 1,2






-- 1. (상품 : 전체, 스토어 : 전체)
select	start_mm, mm, '전체' as product, '전체' as store, count(*)
from 	(
			select	distinct key, start_mm, mm
			from	(
						select	KEY, 
								to_char(first_value (month) over (partition by key order by month asc), 'yyyy-mm') as start_mm,
								to_char(month, 'yyyy-mm') as mm
						from	(
									select	o.customer_key as KEY, o.store, p.nick,
											generate_series(
												DATE_TRUNC('month', o.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									from	"order" as o 
									LEFT JOIN "order_option" as oo on (o.no = oo.order_no) 
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND o.no not in (select order_no from "non_order")
									AND o.no NOT IN (SELECT no FROM "order" WHERE order_type IN ('취소', '반품'))
									--order by 1,2
									
									UNION ALL 
									
									SELECT 	customer_key AS KEY, oo.store, p.nick,
												generate_series(
												DATE_TRUNC('month', oo.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									FROM "order_option2" AS oo
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND oo.no not in (select order_no from "non_order")
									
								) as t
			) as t
) as t
group by 1,2
order by 1,2




-- 2. (상품 : 상품별, 스토어 : 전체)
select	start_mm, mm, nick, '전체' as store, count(*)
from 	(
			select	distinct key, start_mm, nick, mm
			from	(
						select	KEY, 
								to_char(first_value (month) over (partition by KEY, nick order by month asc), 'yyyy-mm') as start_mm,
								nick,
								to_char(month, 'yyyy-mm') as mm
						from	(
									select	o.customer_key as KEY, 
												
												CASE  
													WHEN o.store IN ('스마트스토어', '자사몰') THEN o.store
													ELSE '기타'
												END AS store_mod, 
												p.nick,
											generate_series(
												DATE_TRUNC('month', o.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									from	"order" as o 
									LEFT JOIN "order_option" as oo on (o.no = oo.order_no) 
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND o.no not in (select order_no from "non_order")
									AND o.no NOT IN (SELECT no FROM "order" WHERE order_type IN ('취소', '반품'))
									--order by 1,2
									
									UNION ALL 
									
									SELECT 	customer_key AS KEY, oo.store, p.nick,
												generate_series(
												DATE_TRUNC('month', oo.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									FROM "order_option2" AS oo
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND oo.no not in (select order_no from "non_order")
									
								) as t
			) as t
) as t
group by 1,2,3
order by 1,2,3



-- 3. (상품 : 전체, 스토어 : 스토어별)
select	start_mm, mm, '전체' as nick, store_mod, count(*)
from 	(
			select	distinct key, start_mm, store_mod, mm
			from	(
						select	KEY, 
								to_char(first_value (month) over (partition by KEY, store_mod order by month asc), 'yyyy-mm') as start_mm,
								store_mod,
								to_char(month, 'yyyy-mm') as mm
						from	(
									select	o.customer_key as KEY, 
												
												CASE  
													WHEN o.store IN ('스마트스토어', '자사몰') THEN o.store
													ELSE '기타'
												END AS store_mod, 
												p.nick,
											generate_series(
												DATE_TRUNC('month', o.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									from	"order" as o 
									LEFT JOIN "order_option" as oo on (o.no = oo.order_no) 
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND o.no not in (select order_no from "non_order")
									AND o.no NOT IN (SELECT no FROM "order" WHERE order_type IN ('취소', '반품'))
									--order by 1,2
									
									UNION ALL 
									
									SELECT 	customer_key AS KEY, oo.store, p.nick,
												generate_series(
												DATE_TRUNC('month', oo.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									FROM "order_option2" AS oo
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND oo.no not in (select order_no from "non_order")
									
								) as t
			) as t
) as t
group by start_mm, mm, store_mod
order by start_mm, mm, store_mod




-- 4. (상품 : 상품별, 스토어 : 스토어별)
select	start_mm, mm, nick, store_mod, count(*)
from 	(
			select	distinct key, start_mm, nick, store_mod, mm
			from	(
						select	KEY, 
								to_char(first_value (month) over (partition by KEY, nick, store_mod order by month asc), 'yyyy-mm') as start_mm,
								nick, store_mod,
								to_char(month, 'yyyy-mm') as mm
						from	(
									select	o.customer_key as KEY, 
												
												CASE  
													WHEN o.store IN ('스마트스토어', '자사몰') THEN o.store
													ELSE '기타'
												END AS store_mod, 
												p.nick,
											generate_series(
												DATE_TRUNC('month', o.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									from	"order" as o 
									LEFT JOIN "order_option" as oo on (o.no = oo.order_no) 
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND o.no not in (select order_no from "non_order")
									AND o.no NOT IN (SELECT no FROM "order" WHERE order_type IN ('취소', '반품'))
									--order by 1,2
									
									UNION ALL 
									
									SELECT 	customer_key AS KEY, oo.store, p.nick,
												generate_series(
												DATE_TRUNC('month', oo.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									FROM "order_option2" AS oo
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND oo.no not in (select order_no from "non_order")
									
								) as t
			) as t
) as t
group by start_mm, mm, nick, store_mod
order by start_mm, mm, nick, store_mod





-- 5. (상품 : 브랜드별, 스토어 : 전체)
select	start_mm, mm, brand, '전체' as store_mod, count(*)
from 	(
			select	distinct key, start_mm, brand, mm
			from	(
						select	KEY, 
								to_char(first_value (month) over (partition by KEY, brand order by month asc), 'yyyy-mm') as start_mm,
								brand,
								to_char(month, 'yyyy-mm') as mm
						from	(
									select	o.customer_key as KEY, 
												
												CASE  
													WHEN o.store IN ('스마트스토어', '자사몰') THEN o.store
													ELSE '기타'
												END AS store_mod, 
												p.brand,
											generate_series(
												DATE_TRUNC('month', o.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									from	"order" as o 
									LEFT JOIN "order_option" as oo on (o.no = oo.order_no) 
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND o.no not in (select order_no from "non_order")
									AND o.no NOT IN (SELECT no FROM "order" WHERE order_type IN ('취소', '반품'))
									--order by 1,2
									
									UNION ALL 
									
									SELECT 	customer_key AS KEY, oo.store, p.brand,
												generate_series(
												DATE_TRUNC('month', oo.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									FROM "order_option2" AS oo
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND oo.no not in (select order_no from "non_order")
									
								) as t
			) as t
			WHERE brand IN ('판토모나', '페미론큐')
) as t
group by start_mm, mm, brand
order by start_mm, mm, brand




-- 6. (상품 : 브랜드별, 스토어 : 스토어별)
select	start_mm, mm, brand, store_mod, count(*)
from 	(
			select	distinct key, start_mm, brand, store_mod, mm
			from	(
						select	KEY, 
								to_char(first_value (month) over (partition by KEY, brand, store_mod order by month asc), 'yyyy-mm') as start_mm,
								brand, store_mod,
								to_char(month, 'yyyy-mm') as mm
						from	(
									select	o.customer_key as KEY, 
												
												CASE  
													WHEN o.store IN ('스마트스토어', '자사몰') THEN o.store
													ELSE '기타'
												END AS store_mod, 
												p.brand,
											generate_series(
												DATE_TRUNC('month', o.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									from	"order" as o 
									LEFT JOIN "order_option" as oo on (o.no = oo.order_no) 
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND o.no not in (select order_no from "non_order")
									AND o.no NOT IN (SELECT no FROM "order" WHERE order_type IN ('취소', '반품'))
									--order by 1,2
									
									UNION ALL 
									
									SELECT 	customer_key AS KEY, oo.store, p.brand,
												generate_series(
												DATE_TRUNC('month', oo.order_datetime),
												case when oo.qty * op.bundle_qty * term * 1.2 > 365 then order_datetime + interval '1 day' * 365 else
														order_datetime + interval '1 day' * oo.qty * op.bundle_qty * term * 1.2 end,
												'1 month'::interval
											)::date AS month
									FROM "order_option2" AS oo
									LEFT JOIN "option_product" as op on (oo.option_code = op.option_code) 
									LEFT JOIN "product" as p on (op.product_no = p.no)
									where	p.brand <> '기타' 
									AND oo.no not in (select order_no from "non_order")
									
								) as t
			) as t
			WHERE brand IN ('판토모나', '페미론큐')
) as t
group by start_mm, mm, brand, store_mod
order by start_mm, mm, brand, store_mod




SELECT * FROM "product"



SELECT * 
FROM "option_product"


SELECT * FROM "customer" LIMIT 100


SELECT COUNT(DISTINCT "orderId") FROM "coupang_order" LIMIT 100




SELECT * FROM "ez_order"


SELECT * FROM "order_option"



SELECT * FROM "order" LIMIT 100



SELECT * FROM "order2"




SELECT * FROM "order_option" LIMIT 100


SELECT * FROM "order_option2" LIMIT 100 






SELECT * FROM "ez_order" WHERE seq = 492586



SELECT * FROM "option_product"


SELECT * FROM "order_option"


INSERT INTO "option_product"
SELECT ez_code, product_no, qty 
FROM "bundle"


SELECT * FROM "store"

SELECT * FROM "order"




