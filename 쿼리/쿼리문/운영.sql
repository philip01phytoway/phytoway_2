-- 2023-05-25 코호트 요청
-- (상품별, 전체)
SELECT cohort_group, cohort_index, nick, '전체' AS qty, COUNT(DISTINCT key)
FROM 	(
			SELECT *,
						(DATE_PART('year', order_date::date) - DATE_PART('year', first_date::DATE)) * 12 +
						DATE_PART('month', order_date::date) - DATE_PART('month', first_date::date) AS cohort_index,
						TO_CHAR(DATE_TRUNC('month', first_date::DATE), 'YYYY-MM-DD') AS cohort_group
			FROM 	(
						SELECT 	KEY, order_date, nick,
									first_value(order_date) over(partition BY KEY, nick Order BY order_date_time) AS first_date
						FROM 	order_batch
						WHERE order_id <> '' AND phytoway = 'y' AND store IN ('스마트스토어', '스마트스토어_풀필먼트')
					) AS t1
		) AS t2
GROUP BY cohort_group, cohort_index, nick



SELECT * 
FROM "Naver_Search_Channel"
WHERE "D" LIKE '%판토모나%' OR "D" LIKE '%써큐시안%'


SELECT *
FROM "ad_mapping3"


SELECT *
FROM "naver_option"
WHERE option_code = '31861468601'

SELECT * FROM "stock_log"

SELECT *
FROM "product"
Order BY NO




select *
from "EZ_Order"
where seq = 502705



SELECT *
FROM "naver_option"
WHERE option_code = '32006841737'


SELECT * FROM "cost_marketing"


SELECT * FROM "cost_product"








SELECT SUM(cost1), SUM(cost2) FROM "content_batch"
WHERE yyww IN( '2023-22','2023-23','2023-24') AND page_type = '블로그'


SELECT * FROM "content_batch" LIMIT 10



SELECT "orderId", COUNT("productOrderId") AS cnt
FROM "naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
WHERE p.nick = '판토모나하이퍼포머'
GROUP BY "orderId"
HAVING COUNT("productOrderId") > 1




SELECT * FROM "settlement"



select * from "Stock"
--where product LIKE '%밤%'
WHERE INPUT > 0
order by yymmdd





SELECT *
FROM "order_batch"
WHERE KEY = '최지환al*****@na'


-- 3회 이상 주문? - o
-- 주문일 7개월 이내? : 
-- 만료일? - 딱 복용기간만.
복용기간, 복용기간 -14, 복용기간+14
주문일 + 2
-- key_rank인지, key_nick_rank인지? - key_nick_rank
-- 고객 리스트



-- 주문 내역
SELECT *
FROM 	(
			select 	
						dense_rank() over(partition by key, nick order by order_date_time) as "key_nick_rank",
						*
			from "order_batch"
			where order_id <> '' and phytoway = 'y' AND order_status = '주문'
		) AS t
WHERE order_date > '2022-11-16' AND brand IN ('판토모나', '써큐시안') AND key_nick_rank >= 3 




-- 고객 명단
-- where절 nick 조건 바꿔서 사용
SELECT DISTINCT KEY, order_name, cust_id, order_tel
FROM 	(
			select 	
						dense_rank() over(partition by key, nick order by order_date_time) as "key_nick_rank",
						*
			from "order_batch"
			where order_id <> '' and phytoway = 'y' AND order_status = '주문'
		) AS t
WHERE order_date > '2022-11-16' AND brand IN ('판토모나', '써큐시안') AND key_nick_rank >= 3 
AND nick = '판토모나하이퍼포머'







SELECT * FROM "product" Order BY NO





SELECT * FROM "order_batch" LIMIT 100



SELECT * FROM "coupang_settlement_case"



SELECT "orderId", "saleType", "saleDate", "recognitionDate", "settlementDate", "finalSettlementDate", "deliveryFee", "taxType", "productId", "productName", "vendorItemId", "vendorItemName", "salePrice", quantity, "coupangDiscountCoupon", "discountCouponPolicyAgreement", "saleAmount", "sellerDiscountCoupon", "downloadableCoupon", "serviceFee", "serviceFeeVat", "serviceFeeRatio", "settlementAmount", "couranteeFeeRatio", "couranteeFee", "couranteeFeeVat", "storeFeeDiscountVat", "storeFeeDiscount", "externalSellerSkuCode"
--select sum("settlementAmount")
--select ("deliveryFee" ->> 'settlementAmount')
FROM public.coupang_settlement_case
where 	--"orderId" = '10000183218467'

"recognitionDate" between '2023-06-19' and '2023-06-25'




SELECT DISTINCT "store" FROM "order_batch" Order BY "store"



SELECT * FROM "order_batch" WHERE order_id = '20000178562967'


store = '쿠팡_제트배송'



SELECT SUM(cost), SUM(click_cnt), SUM(order_cnt)
FROM "ad_batch" 
WHERE yymmdd = '2023-07-19' AND channel = '쿠팡'
AND account <> 'A00197911'

-- 전화번호 db
-- 기간 및 전화번호 수정하여 사용
-- 전화번호 마지막 쉼표 제거 필요
SELECT *
FROM 	(
			SELECT 	*,
						dense_rank() over(partition by key order by order_date_time) as "key_rank",
						dense_rank() over(partition by key, nick order by order_date_time) as "key_nick_rank"
			FROM "order_batch"
		) AS t
WHERE --order_date BETWEEN '2023-01-01' AND '2023-07-01'
--AND 
order_tel IN (
'01091957198',
'01024082390',
'01052229970',
'01056111545',
'01085996602',
'01066698323',
'01046508648',
'01045984184',
'01066341095',
'01090984749',
'01044112940',
'01071256863',
'01041494644',
'01071353673',
'01091914562'
)



SUM(score)


-- 날짜 전처리
-- YMD2 join
-- 상품 매칭
-- 주차별 상품별 전체 리뷰 개수, A급 리뷰 개수, S급 리뷰 개수


------------------------
 
-- 제품 구분 x

------------------------


-- 전체 리뷰 개수
SELECT yyww, COUNT(*)
FROM 	(
			SELECT 	replace(left(review_date, 10), '.', '-') AS "review_date_mod",
						*
			FROM "naver_review" AS r
			LEFT JOIN "naver_order_product" AS n ON (r.product_order_no = n."productOrderId")
			LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
			LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
			WHERE n."productOrderId" IS NOT NULL 
		) AS r
LEFT JOIN "YMD2" AS y ON (r.review_date_mod = y.yymmdd)
GROUP by y.yyww
Order BY y.yyww DESC


-- 포토/영상 리뷰 개수
SELECT yyww, COUNT(*)
FROM 	(
			SELECT 	replace(left(review_date, 10), '.', '-') AS "review_date_mod",
						*
			FROM "naver_review" AS r
			LEFT JOIN "naver_order_product" AS n ON (r.product_order_no = n."productOrderId")
			LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
			LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
			WHERE n."productOrderId" IS NOT NULL AND photo_video <> ''
		) AS r
LEFT JOIN "YMD2" AS y ON (r.review_date_mod = y.yymmdd)
GROUP by y.yyww
Order BY y.yyww desc


-- 포토/영상 & 300자 이상 리뷰 개수
SELECT yyww, COUNT(*)
FROM 	(
			SELECT 	replace(left(review_date, 10), '.', '-') AS "review_date_mod",
						*
			FROM "naver_review" AS r
			LEFT JOIN "naver_order_product" AS n ON (r.product_order_no = n."productOrderId")
			LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
			LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
			WHERE n."productOrderId" IS NOT NULL AND photo_video <> '' AND LENGTH(review) > 299
		) AS r
LEFT JOIN "YMD2" AS y ON (r.review_date_mod = y.yymmdd)
GROUP by y.yyww
Order BY y.yyww desc


------------------------
 
-- 제품 구분 O

------------------------

-- 전체 리뷰 개수
SELECT yyww, r.brand, COUNT(*)
FROM 	(
			SELECT 	replace(left(review_date, 10), '.', '-') AS "review_date_mod",
						*
			FROM "naver_review" AS r
			LEFT JOIN "naver_order_product" AS n ON (r.product_order_no = n."productOrderId")
			LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
			LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
			WHERE n."productOrderId" IS NOT NULL 
		) AS r
LEFT JOIN "YMD2" AS y ON (r.review_date_mod = y.yymmdd)
WHERE r.brand = '써큐시안'
GROUP by y.yyww, r.brand
Order BY y.yyww DESC


-- 포토/영상 리뷰 개수
SELECT yyww, r.brand, COUNT(*)
FROM 	(
			SELECT 	replace(left(review_date, 10), '.', '-') AS "review_date_mod",
						*
			FROM "naver_review" AS r
			LEFT JOIN "naver_order_product" AS n ON (r.product_order_no = n."productOrderId")
			LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
			LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
			WHERE n."productOrderId" IS NOT NULL AND photo_video <> ''
		) AS r
LEFT JOIN "YMD2" AS y ON (r.review_date_mod = y.yymmdd)
WHERE r.brand = '써큐시안'
GROUP by y.yyww, r.brand
Order BY y.yyww desc


-- 포토/영상 & 300자 이상 리뷰 개수
SELECT yyww, r.brand, COUNT(*)
FROM 	(
			SELECT 	replace(left(review_date, 10), '.', '-') AS "review_date_mod",
						*
			FROM "naver_review" AS r
			LEFT JOIN "naver_order_product" AS n ON (r.product_order_no = n."productOrderId")
			LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
			LEFT JOIN "product" AS p ON (o."product_no" = p."no")	
			WHERE n."productOrderId" IS NOT NULL AND photo_video <> '' AND LENGTH(review) > 299
		) AS r
LEFT JOIN "YMD2" AS y ON (r.review_date_mod = y.yymmdd)
WHERE r.brand = '써큐시안'
GROUP by y.yyww, r.brand
Order BY y.yyww desc







SELECT * --DISTINCT product_no
FROM "naver_review" 
Order BY review_date

WHERE review_date < '2022-04-01'


SELECT * --r.product_order_no, o."productOrderId"
FROM "naver_review" AS r
LEFT JOIN "naver_order_product" AS o ON (r.product_order_no = o."productOrderId")
WHERE o."productOrderId" IS NOT NULL 





SELECT *
FROM "naver_review" AS r
Order BY review_date desc


LEFT JOIN "naver_order_product" AS o ON (r.product_order_no = o."productOrderId")
WHERE o."productOrderId" IS NULL 


SELECT *
FROM 
2021073177737791


SELECT SUM(prd_amount_mod)
FROM "order_batch"
WHERE store = '쿠팡' AND yymm = '2022-06' AND phytoway = 'y' AND brand = '판토모나'


SELECT SUM(order_price)
FROM "ad_batch"
WHERE channel = '쿠팡' AND yymm = '2022-06' AND brand = '판토모나'



SELECT yymm, channel, store, brand, nick, owned_keyword,ad_type,campaign_type,imp_area, SUM(cost)AS cost, SUM(imp_cnt)AS 노출수, SUM(click_cnt) AS 클릭수, SUM(order_cnt) AS 전환수, SUM(order_price) AS 전환매출
FROM "ad_batch"
WHERE brand NOT IN ('기타','자사') AND channel='쿠팡'
GROUP BY yymm,  channel, store, brand, nick, owned_keyword,ad_type,campaign_type,imp_area
ORDER BY yymm DESC




SELECT * 
FROM "EZ_Order" 
WHERE order_id = '20230714-0000058'


SELECT *
FROM "order_batch"
WHERE store = '자사몰' AND product_qty = 0


order_id = '20230714-0000058-01'




SELECT * 
FROM "naver_order_product"
WHERE "paymentDate" > '2023-07-23'






SELECT * --SUM(click_cnt)
FROM "ad_batch" 
WHERE channel = '네이버' AND Keyword = '비오틴' AND yymmdd BETWEEN '2023-01-01' AND '2023-06-31'
11108



SELECT SUM("K")
FROM "Naver_Search_Channel"
WHERE "D" = '비오틴' AND yymmdd BETWEEN '2023-01-01' AND '2023-06-31'
AND "B" = '검색광고'
996



SELECT DISTINCT "B" 
FROM "Naver_Search_Channel"



-- 주차별, 상품별 판매수량
SELECT yyww, onnuri_name, SUM(out_qty)
FROM "order_batch"
GROUP BY yyww, onnuri_name
Order BY yyww desc


SELECT * FROM "order_batch" 
WHERE onnuri_name IS null

LIMIT 1



SELECT SUM(out_qty)
FROM "order_batch"
WHERE store NOT LIKE '%스마트스토어%' AND store <> '쿠팡_제트배송' AND trans_pos_date = '2023-07-12' AND nick = '판토모나하이퍼포머'





SELECT onnuri_name, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE order_date BETWEEN '2023-07-01' AND '2023-07-25' AND phytoway = 'n'
GROUP BY onnuri_name
Order BY price desc


SELECT SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE order_date BETWEEN '2023-07-01' AND '2023-07-25' AND phytoway = 'n'



SELECT *
FROM "order_batch"
WHERE nick = '판토모나샴푸'




SELECT * 
FROM "naver_review"










SELECT yymm, yyww, yymmdd, channel, store, brand, nick, owned_keyword,keyword, SUM(imp_cnt)AS 노출수, SUM(click_cnt) AS 클릭수, SUM(order_cnt) AS 전환수, SUM(order_price) AS 전환매출
FROM "ad_batch"
WHERE brand NOT IN ('기타','자사') AND yyww >='2023-01' AND yyww <='2023-30'AND channel='네이버'AND campaign_type LIKE '브랜드검색%'
and keyword='써큐시안에버그린'
GROUP BY yymm, yyww, yymmdd, channel, store, brand, nick, owned_keyword,keyword
ORDER BY yymmdd DESC




SELECT * 
FROM "ad_batch"
WHERE Keyword='써큐시안에버그린'


SELECT * FROM "order_batch" WHERE store = '쿠팡' LIMIT 1000