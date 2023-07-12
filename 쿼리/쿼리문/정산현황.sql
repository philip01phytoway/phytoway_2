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
with naver_settlement as (
	select "productOrderId", max("settle_1") as settle_1, max("settle_2") as settle_2, max("settle_3") as settle_3, max("settle_4") as settle_4
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
									dense_rank() over(partition by "productOrderId" order by "settleBasisDate" asc, "settleType" desc) as rank
							from public.naver_settlement_case
						) as t
				 where "settleCompleteDate" > '2023-05-31' and "settleCompleteDate" < '2023-07-01'
			) as t2
	group by "productOrderId"
)

-- select 	sum(
-- 			CASE 
-- 				WHEN "productOrderStatus" in ('EXCHANGED', 'CANCELED', 'RETURNED') THEN "totalPaymentAmount" * -1
-- 				else "totalPaymentAmount"
-- 			end
-- 		) as "매출액", 
-- 		sum(
-- 			CASE 
-- 				WHEN "productOrderStatus" in ('EXCHANGED', 'CANCELED', 'RETURNED') THEN "expectedSettlementAmount" * -1
-- 				else "expectedSettlementAmount"
-- 			end
-- 		) as "매출액(수수료제외)", 
-- 		sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "expectedSettlementAmount" end) as "정산액",
-- 		sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_1" end) 
-- 		+ sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_2" end) 
-- 		+ sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_3" end) as "입금액",
-- 		sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "expectedSettlementAmount" end) -
-- 		(
-- 			sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_1" end) 
-- 			+ sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_2" end) 
-- 			+ sum(case when "productOrderStatus" = 'PURCHASE_DECIDED' then "settle_3" end)
-- 		) as "채권금액"
select  distinct n."productOrderStatus" --n."productOrderId", n."productOrderStatus", "totalPaymentAmount", "expectedSettlementAmount", settle_1, settle_2, settle_3, settle_4
from "naver_order_product2" as n 
left join naver_settlement as s on (n."productOrderId" = s."productOrderId")
where s."productOrderId" is not null 



select distinct "productOrderId"
from "naver_settlement_case" as s
left join 
where "settleCompleteDate" > '2023-05-31' and "settleCompleteDate" < '2023-07-01'
and "productOrderType" = 'PROD_ORDER'





select *
from "naver_settlement_case"


s."settleCompleteDate" > '2023-05-31' and s."settleCompleteDate" < '2023-07-01'


-- 매출 - 수수료 - 부가사용료 = 정산액
-- 정산액 - 입금액 = 채권금액

-- 일별 정산
select "settleCompleteDate", "benefitSettleAmount", "deductionRestoreSettleAmount", "payHoldbackAmount", "minusChargeAmount", "returnCareSettleAmount"
from "naver_settlement_daily"

-- 데이터 검증
-- 회계와 확인. 네이버 어드민이 실제로 입금이 되는지.
-- vat 확인



 order by settleBasis

select "paymentDate", "productOrderId", "productOrderStatus", "totalPaymentAmount"
from "naver_order_product2"
where "paymentDate" >= '2023-06-01' and "paymentDate" < '2023-07-01' --and "productOrderStatus" in ('DELIVERING', 'PURCHASE_DECIDED', )
order by "paymentDate"



select distinct "productOrderStatus"
from "naver_order_product2"


select *
from "naver_order_product2"
where "productOrderId" = '2023062353019631'



select sum("settleExpectAmount" ) from "naver_settlement_case" as s
where s."settleCompleteDate" > '2023-05-31' and s."settleCompleteDate" < '2023-07-01'



