SELECT "orderId", "saleType", "saleDate", "recognitionDate", "settlementDate", "finalSettlementDate", "deliveryFee", "taxType", "productId", "productName", "vendorItemId", "vendorItemName", "salePrice", quantity, "coupangDiscountCoupon", "discountCouponPolicyAgreement", "saleAmount", "sellerDiscountCoupon", "downloadableCoupon", "serviceFee", "serviceFeeVat", "serviceFeeRatio", "settlementAmount", "couranteeFeeRatio", "couranteeFee", "couranteeFeeVat", "storeFeeDiscountVat", "storeFeeDiscount", "externalSellerSkuCode"


select sum("settlementAmount"), sum( ( ("deliveryFee" ->> 'settlementAmount'))::int ) 
FROM public.coupang_settlement_case
where "recognitionDate" between '2023-06-05' and '2023-06-11'
	

select abs((("deliveryFee" ->> 'settlementAmount'))::int)
FROM public.coupang_settlement_case
where "recognitionDate" between '2023-06-19' and '2023-06-25'
and (("deliveryFee" ->> 'settlementAmount'))::int < 0


select * 
FROM public.coupang_settlement_case
order by "recognitionDate"

where "orderId" = '30000185385200'

select abs(-3)
from


select sum("settlementAmount_mod"), sum("settle_2")
from 	(
			select 
					case 
						when "saleType" = 'REFUND' then "settlementAmount"  * -1
						else "settlementAmount"
					end as "settlementAmount_mod",
					abs((("deliveryFee" ->> 'settlementAmount'))::int) as "settle_2"
			FROM public.coupang_settlement_case
			where "recognitionDate" between '2023-05-01' and '2023-05-31'
			order by "settlementAmount_mod" 
	) as t




select *
FROM public.coupang_settlement_history
order by "settlementDate" desc

where "settlementType" = 'RESERVE'




1차 정산일과
2차 정산일을 이용하면 건별 채권을 알 수 있다.
정산금액에 0.7이랑 0.3을 각각 곱해주면 되고,
공제금액은 따로 빼주면 됨.


그럼 이제 주문과 정산을 건별로 연결해보자.






select "orderId", "vendorItemId", sum("saleAmount") as "실결제금액", sum("settlementAmount_mod") + sum("settle_2") as "정산대상액", ( sum("settlementAmount_mod") + sum("settle_2") ) * 0.7 as "1차정산금액", ( sum("settlementAmount_mod") + sum("settle_2") ) * 0.3 as "2차정산금액"
from 	(
			select *,
					case 
						when "saleType" = 'REFUND' then "settlementAmount"  * -1
						else "settlementAmount"
					end as "settlementAmount_mod",
					abs((("deliveryFee" ->> 'settlementAmount'))::int) as "settle_2"
			FROM public.coupang_settlement_case
			where "recognitionDate" between '2023-05-01' and '2023-05-31'
			order by "settlementAmount_mod" 
		) as t
group by "orderId", "vendorItemId"



입금액은 coupang_settlement_history에 있는 거고.

-- 매출 - 수수료 - 부가사용료 = 정산액
-- 정산액 - 입금액 = 채권금액



with c_order as (
		select "orderId", "paidAt", "vendorItemId", "status", "cancelCount", "canceled", "confirmDate", p."orderPrice" as "price"
		from "coupang_order" AS o,																
				json_to_recordset(o."orderItems") as p(																	
					"vendorItemName" CHARACTER varying(255),																
					"vendorItemId" CHARACTER varying(255),
					"shippingCount" INTEGER,
					"cancelCount" INTEGER,
					"orderPrice" INTEGER,
					"discountPrice" INTEGER,
					"confirmDate" 	CHARACTER varying(255),
					"invoiceNumberUploadDate" CHARACTER varying(255),
					"canceled" CHARACTER varying(255)
				)
	), c_settle as (
		select "orderId"::bigint, "vendorItemId", sum("settlementAmount_mod") + sum("settle_2") as "정산대상액", ( sum("settlementAmount_mod") + sum("settle_2") ) * 0.7 as "1차정산금액", ( sum("settlementAmount_mod") + sum("settle_2") ) * 0.3 as "2차정산금액"
		from 	(
					select *,
							case 
								when "saleType" = 'REFUND' then "settlementAmount" * -1
								else "settlementAmount" 
							end as "settlementAmount_mod",
							abs((("deliveryFee" ->> 'settlementAmount'))::int) as "settle_2"
					FROM public.coupang_settlement_case
					where "recognitionDate" between '2023-05-01' and '2023-05-31'
					order by "settlementAmount_mod" 
				) as t
		group by "orderId", "vendorItemId"
	)		
	
select price - "정산대상액" as tt, *
from "c_order" as o
left join "c_settle" as s on (o."orderId" = s."orderId" and o."vendorItemId" = s."vendorItemId")
order by tt







select * from "coupang_order" where "orderId" = '21000179708489'
 - p."discountPrice"

'1000177001952'


해야 되는 것은 주문과 취소를 하나로 합치는 것


-- 구매확정 후 취소건
-- CANCEL인 경우 존재하지 않음
select * 
from "coupang_return_cancel" as r
left join "coupang_settlement_case" as s on (r."orderId" = s."orderId"::bigint)
where s."orderId" is not null 
and "receiptType" = 'RETURN'




SELECT *
from "coupang_settlement_case"
where "orderId"::bigint in (
		select r."orderId"
		from "coupang_return_cancel" as r
		left join "coupang_settlement_case" as s on (r."orderId" = s."orderId"::bigint)
		where s."orderId" is not null 
		and "receiptType" = 'RETURN'
)
order by "orderId"


