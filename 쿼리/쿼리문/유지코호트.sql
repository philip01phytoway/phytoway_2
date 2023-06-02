


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
									from	"order" as o left join
											"order_option" as oo on (o.no = oo.order_no) left join
											"option_product" as op on (oo.option_code = op.option_code) left join
											"product" as p on (op.product_no = p.no)
									where	p.category <> '기타'
									order by 1,2
								) as t
			) as t
) as t
group by 1,2
order by 1,2




select * 
from "order" as o
left join "order_option" as oo on (o.no = oo.order_no)


select *
from "order_option"




SELECT 	"ordererName" || "ordererId" AS "key", 
			"orderId", 
			
			CASE 
				WHEN "productOrderStatus" = 'EXCHANGED' THEN '교환'
				WHEN "productOrderStatus" = 'CANCELED' THEN '취소'
				WHEN "productOrderStatus" = 'RETURNED' THEN '반품'
			END AS order_status, 
			
			CASE 
				WHEN "productOrderStatus" = 'EXCHANGED' THEN LEFT("claimRequestDate", 10)
				WHEN "productOrderStatus" = 'CANCELED' THEN LEFT("cancelCompletedDate", 10)
				WHEN "productOrderStatus" = 'RETURNED' THEN LEFT("returnCompletedDate", 10)
			END AS order_date
			
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE 	"productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED')	
AND n."orderId" NOT IN (SELECT order_num FROM "Non_Order")








select * from "order"
where no in 
(select order_no from "non_order")



select distinct order_no
from "non_order"
where store = '네이버'


