with s1 as (
	select *
	from (
			select 	*, 
					dense_rank() over(partition by "productOrderId" order by "settleBasisDate" asc, "settleType" desc) as rank
			from public.naver_settlement_case
		) as t
	where rank = 1
),
s2 as (
	select *
	from (
			select 	*, 
					dense_rank() over(partition by "productOrderId" order by "settleBasisDate" asc, "settleType" desc) as rank
			from public.naver_settlement_case
		) as t
	where rank = 2
),
s3 as (
	select *
	from (
			select 	*, 
					dense_rank() over(partition by "productOrderId" order by "settleBasisDate" asc, "settleType" desc) as rank
			from public.naver_settlement_case
		) as t
	where rank = 3
),
s4 as (
	select *
	from (
			select 	*, 
					dense_rank() over(partition by "productOrderId" order by "settleBasisDate" asc, "settleType" desc) as rank
			from public.naver_settlement_case
		) as t
	where rank = 4
)

select 	n."paymentDate", n."productOrderStatus", n."productOrderId", n."orderId", n."totalPaymentAmount", n."expectedSettlementAmount", 
		s1."settleExpectAmount", s2."settleExpectAmount", s3."settleExpectAmount", s4."settleExpectAmount"
from "naver_order_product2" as n 
left join s1 as s1 on (n."productOrderId" = s1."productOrderId")
left join s2 as s2 on (n."productOrderId" = s2."productOrderId")
left join s3 as s3 on (n."productOrderId" = s3."productOrderId")
left join s4 as s4 on (n."productOrderId" = s4."productOrderId")
where s1."productOrderId" is not null or s2."productOrderId" is not null or s3."productOrderId" is not null or s4."productOrderId" is not null



---------------------------------------------------

2차 버전

with naver_settlement as (
	select "productOrderId", max("settle_1") as settle_1, max("settle_2") as settle_2, max("settle_3") as settle_3, max("settle_4") as settle_4
	from 	(
				select 	*,
						case 
							when rank = 1 then "settleExpectAmount" 
							else null
						end as settle_1,
						case 
							when rank = 2 then "settleExpectAmount" 
							else null
						end as settle_2,
						case 
							when rank = 3 then "settleExpectAmount" 
							else null
						end as settle_3,
						case 
							when rank = 4 then "settleExpectAmount" 
							else null
						end as settle_4
				from 	(
							select 	*, 
									dense_rank() over(partition by "productOrderId" order by "settleBasisDate" asc, "settleType" desc) as rank
							from public.naver_settlement_case
						) as t
			) as t2
	group by "productOrderId"
)

select 	n."paymentDate", n."productOrderStatus", n."productOrderId", n."orderId", n."totalPaymentAmount", n."expectedSettlementAmount", 
		s."settle_1", s."settle_2", s."settle_3", s."settle_4", n."expectedSettlementAmount" - s."settle_1" - s."settle_2" - s."settle_3" - s."settle_4" as "bond"
from "naver_order_product2" as n 
left join naver_settlement as s on (n."productOrderId" = s."productOrderId")
where s."settle_1" is not null or s."settle_2" is not null or s."settle_3" is not null or s."settle_4" is not null


-- 채권을 아는 쿼리가 필요함.
-- 채권 열을 만들고, 데일리 섬을 하고, 거기에 차감할 금액 넣으면 채권 금액이 나옴.

where "settleType" like '%CANCEL%'



select 	*
from public.naver_settlement_case
where "productOrderId" = '2023050384254491'





-- 채권 요약
-- 채권 개념에 취소, 환불 포홤되어야 하는지는 논의 필요. 일단 배제했음.
-- 나중에 settle_4도 적용해서 만들기.
with naver_settlement as (
	select "productOrderId", max(case when "settle_1" <> 0 then "settle_1" end) as settle_1, max(case when "settle_2" <> 0 then "settle_2" end) as settle_2, max(case when "settle_3" <> 0 then "settle_3" end) as settle_3, max(case when "settle_4" <> 0 then "settle_4" end) as settle_4
	from 	(
				select 	*,
						case 
							when rank = 1 then "settleExpectAmount" 
							else 0
						end as settle_1,
						case 
							when rank = 2 then "settleExpectAmount" 
							else 0
						end as settle_2,
						case 
							when rank = 3 then "settleExpectAmount" 
							else 0
						end as settle_3,
						case 
							when rank = 4 then "settleExpectAmount" 
							else 0
						end as settle_4
				from 	(
							select 	*, 
									row_number() over(partition by "productOrderId" order by "settleBasisDate" asc, "settleType" desc) as rank
							from public.naver_settlement_case
						) as t
				 where "settleCompleteDate" > '2023-05-31' and "settleCompleteDate" < '2023-07-01' and "productOrderType" = 'PROD_ORDER'
			) as t2
	group by "productOrderId"
)

select 	left(n."paymentDate", 10), sum(
			CASE 
				WHEN "productOrderStatus" in ('EXCHANGED', 'CANCELED', 'RETURNED') THEN 0
				else "totalPaymentAmount"
			end
		) as "매출액", 
		sum(
			CASE 
				WHEN "productOrderStatus" in ('EXCHANGED', 'CANCELED', 'RETURNED') THEN 0
				else "expectedSettlementAmount"
			end
		) as "매출액(수수료제외)", 
		sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "expectedSettlementAmount" end) as "정산액",
		COALESCE(sum("settle_1"), 0) + COALESCE(sum("settle_2"), 0) + COALESCE(sum("settle_3"), 0) + COALESCE(sum("settle_4"), 0) as "입금액"
		
-- 		sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_1" end) 
-- 		+ sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_2" end) 
-- 		+ sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_3" end) as "입금액",
-- 		sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "expectedSettlementAmount" end) -
-- 		(
-- 			sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_1" end) 
-- 			+ sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_2" end) 
-- 			+ sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_3" end)
-- 		) as "채권금액"

-- select *		
from "naver_order_product2" as n 
left join naver_settlement as s on (n."productOrderId" = s."productOrderId")
where s."productOrderId" is not null 
group by left(n."paymentDate", 10)
order by left(n."paymentDate", 10)


-- 매출 - 수수료 - 부가사용료 = 정산액
-- 정산액 - 입금액 = 채권금액

-- 일별 정산
select "settleCompleteDate", "benefitSettleAmount", "deductionRestoreSettleAmount", "payHoldbackAmount", "minusChargeAmount", "returnCareSettleAmount"
from "naver_settlement_daily"

-- 데이터 검증
-- 회계와 확인. 네이버 어드민이 실제로 입금이 되는지.
-- vat 확인


-- 일자별로 채권이 딱딱 나오게끔 처리해줘야 함.

-- 반품 배송비도.


-- 채권과 정산의 시점 차이가 존재해서 일자별로 그날 발생한 채권 중에 얼마가 입금되었는지 알려주는 표는 작성하기 힘들다.
-- 단지 그날 발생한 채권과 그날 입금된 돈을 알려주는 표와, 누적으로 채권이 얼마가 남아있는지를 알려주는 표가 있으면 된다.


---------------------------------------------------

-- 쿠팡

---------------------------------------------------


-- 쿠팡은 key를 어떻게 매기냐면
-- 상품주문번호가 없으니까 주문번호_옵션번호_옵션넘버로 붙인다.
-- 간혹 가다 옵션번호가 같은게 있을 수 있다.




select * from "coupang_settlement_case"



select * from "coupang_settlement_history"




with c_order as (
		select "orderId", "paidAt", "vendorItemId", "status", "cancelCount", "canceled", "confirmDate", p."orderPrice" - p."discountPrice" as "price"
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
		select "orderId"::bigint, "vendorItemId", "settlementAmount", "recognitionDate", "settlementDate"
		from "coupang_settlement_case" AS o,																
				json_to_recordset(o."items") as p(																	
					"vendorItemName" CHARACTER varying(255),																
					"vendorItemId" CHARACTER varying(255),
					"quantity" INTEGER,
					"saleAmount" INTEGER,
					"settlementAmount" INTEGER
				)
	)		
	
select *
from "c_order" as o
left join "c_settle" as s on (o."orderId" = s."orderId" and o."vendorItemId" = s."vendorItemId")



select * 
from "coupang_settlement_history"
order by "revenueRecognitionDateFrom"

검증을 하려면 매출인식일 기준으로 해야 댐.



select * 
from "coupang_settlement_case" 
where "recognitionDate" between '2023-01'

order by "recognitionDate"




select * from "coupang_order"




select * from "coupang_return_cancel"





with c_order as (

	select "orderId", "paidAt", "vendorItemId", "status", "cancelCount", "canceled", "confirmDate", p."orderPrice" - p."discountPrice" as "price"
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
	), c_cs as (		
			
select *
from "coupang_return_cancel" AS o,																
		json_to_recordset(o."returnItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255)
		)
	)
	
select *
from "c_order" as o
left join "c_cs" as c on (o."orderId" = c."orderId" and o."vendorItemId" = c."vendorItemId")
where c."orderId" is null 




