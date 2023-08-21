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





SELECT * FROM "Page_Log" LIMIT 100


SELECT * FROM "Query_Log2"

SELECT * FROM keyword_view Order BY yymmdd DESC




SELECT * 
FROM "Non_Order"
WHERE order_num = '2023072861912481'

ORDER BY yymmdd desc


SELECT * 
FROM "order_batch"
WHERE order_id IN (SELECT order_num FROM "Non_Order") AND order_id <> ''



SELECT * 
FROM "order_batch"
WHERE nick = '써큐시안은행잎바나바' AND all_cust_type = '신규' AND yyww = '2023-31'
AND store = '스마트스토어'






SELECT *
FROM "Non_Order"
where order_num LIKE '20230730%'


IN ('2023073088166631', '2023073091769771')



SELECT * 
FROM "coupang_sales"
WHERE option_id = '84881967853 '
Order BY reg_date desc



SELECT * FROM "naver_order_product" LIMIT 10000



SELECT * FROM "product" Order BY no


SELECT * FROM "coupang_sales" WHERE reg_date = '2023-08-01'

option_id = '78206305759 '




SELECT 	y.yymm, y.yyww, y.yymmdd, c.name AS channel, s.name AS store,        
			
			CASE 
				WHEN p.brand IS NULL THEN '파이토웨이'
				ELSE p.brand
			END AS brand, 
			
			CASE 
				WHEN p.nick IS NULL THEN '파이토웨이'
				ELSE p.nick
			END AS nick,
			 
			m.ad_account AS account, '검색광고' AS "ad_type", a."C" AS "campaign_type", a."I" AS imp_area, 
			a."B" AS "campaign", a."D" AS "adgroup", a."G" AS "creative", 
			
			CASE 
				WHEN m.owned_keyword = '자상호' THEN '자상호'
				ELSE '비자상호'
			END AS owned_keyword, 
			
			a."F" AS Keyword,
			a."P" AS cost, a."L" AS imp_cnt, a."M" AS click_cnt, a."Q" AS order_cnt, a."U" AS order_price, 0 AS order_cnt_14, 0 AS order_price_14, '' AS option_id,
			
			CASE 
				WHEN a."C" IN ('파워링크', '쇼핑검색') THEN a."P" * 0.94
				
			
FROM 		"AD_Naver" AS a
LEFT JOIN (SELECT * FROM "ad_mapping3" WHERE channel_no = 1) as m ON (a."B" = m.campaign AND a."D" = m.adgroup) 
LEFT JOIN "product" as p ON (m.product_no = p.no)
LEFT JOIN "store" as s ON (m.store_no = s.no)
LEFT JOIN "channel" AS c ON (m.channel_no = c.no)
LEFT JOIN "YMD2" AS y ON (a.reg_date = y.yymmdd) 

LIMIT 10000





SELECT *
FROM "ad_batch"
WHERE yymmdd = '2023-08-04' AND channel = '네이버'




SELECT * FROM "Naver_Custom_Order" 
Order BY yymmdd desc
LIMIT 10000


SELECT * FROM "Page"
WHERE id = 2953564



SELECT * FROM "ad_batch" where channel = '네이버' AND ad_type = 'GFA' LIMIT 1000

SELECT * FROM "cac_gfa"





SELECT * FROM "ad_mapping3"
WHERE channel_no = 2



SELECT *
FROM "content_batch" 
WHERE channel IS NULL 

id = '4181'


SELECT * FROM "cost_marketing" WHERE id = '4181'


SELECT * FROM "Page" WHERE id = 4181 AND page_type IN ('블로그', '지식인', '유튜브', '카페') AND Channel IN ('네이버', '구글')

WHERE product_id = 0 AND page_type = '광고'


 id = 4181 
 
 
 
SELECT SUM(click)
FROM "ad_google3"
WHERE reg_date BETWEEN '2023-07-26' AND '2023-08-01'
AND campaign LIKE '%youtube%' AND campaign LIKE '%써큐시안%'


SELECT SUM(click_cnt)
FROM "ad_batch"
WHERE channel = '구글' AND campaign_type = '동영상' AND yymmdd BETWEEN '2023-07-26' AND '2023-08-01'
AND nick = '써큐시안블러드케어' 



campaign LIKE '%써큐시안%'




 
SELECT *
FROM "ad_google3"



SELECT channel, SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price)
FROM "ad_batch"
WHERE yymmdd >= '2023-01-01'
GROUP BY channel



SELECT SUM(cost) / 31 AS cost, SUM(imp_cnt) / 31 AS imp_cnt, SUM(click_cnt) / 31 AS click_cnt, SUM(order_cnt) / 31 AS order_cnt, SUM(order_price) / 31 AS order_price
FROM "ad_batch"
WHERE yymmdd >= '2023-07-01' AND yymmdd < '2023-08-01'




SELECT channel, SUM(cost) / 31 AS cost, SUM(imp_cnt) / 30 AS imp_cnt, SUM(click_cnt) / 31 AS click_cnt, SUM(order_cnt) / 31 AS order_cnt, SUM(order_price) / 30 AS order_price
FROM "ad_batch"
WHERE yymmdd >= '2023-07-01' AND yymmdd < '2023-08-01'
GROUP BY channel


SELECT * FROM "ad_batch" WHERE campaign_type = 'GFA다이나믹'
  

SELECT * FROM "cac_gfa" LIMIT 1
  
SELECT * FROM "ad_batch" LIMIT 1
  
  
  

SELECT SUM(order_cnt) AS order_cnt, SUM(prd_amount_mod) AS price, SUM(prd_amount_mod) / SUM(order_cnt) AS price_per_order
FROM "order_batch"
WHERE yymm = '2023-07' AND store IN ('스마트스토어', '스마트스토어_풀필먼트')





SELECT SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "ad_batch"
WHERE Channel = '네이버' AND yymm = '2023-07'









SELECT SUM("E") AS cust_cnt, SUM("F") AS inflow_cnt, SUM("I") AS order_cnt, SUM("K") AS order_price,
SUM("K") / SUM("I") AS price_per_order
FROM "Naver_Search_Channel"
WHERE yymmdd BETWEEN '2023-07-01' AND '2023-07-31'



SELECT SUM("E") AS cust_cnt, SUM("F") AS inflow_cnt, SUM("I") AS order_cnt, SUM("K") AS order_price,
SUM("K") / SUM("I") AS price_per_order
FROM "Naver_Search_Channel"
WHERE yymmdd = '2023-08-08'


SELECT SUM("G")
FROM "Naver_Search_Channel"
WHERE yymmdd = '2023-08-08'






-- cac는 신규 매출 / 신규 주문건수로 객단가를 계산하고 있고 (사실 고객수로 해야할텐데 수식 오류가 있는듯)
-- 또한 스마트스토어만이 아니라 모든 스토어에서 계산하고 있고
-- 제트배송이 신규매출 및 신규고객수로 포함되어 있다.


-- 그렇다면 만약 cac 기준으로 스마트스토어에서의 객단가를 계산해본다면
-- 그래도 신규 고객과 리셀러 제외하면 11~12만원이 나오네.

-- 리셀러 제외, 재구매 고객 제외 조건을 빼니까 13~14만원 꼴이 나오네.

SELECT yymm, SUM(prd_amount_mod) AS price, SUM(order_cnt) AS order_cnt, SUM(prd_amount_mod) / SUM(order_cnt) AS price_per_order
FROM "order_batch"
WHERE phytoway = 'y' AND order_id <> '' AND prd_amount_mod < 500000 AND all_cust_type = '신규' 
--AND store IN ('스마트스토어', '스마트스토어_풀필먼트')
GROUP BY yymm
Order BY yymm desc

				
				
						
SELECT yymm, SUM(prd_amount_mod) AS price, SUM(order_cnt) AS order_cnt, SUM(prd_amount_mod) / SUM(order_cnt) AS price_per_order
FROM "order_batch"
WHERE phytoway = 'y' AND order_id <> '' --AND prd_amount_mod < 500000 
AND store IN ('스마트스토어', '스마트스토어_풀필먼트')
GROUP BY yymm
Order BY yymm DESC	



SELECT *
FROM "order_batch"
WHERE store = '쿠팡'
LIMIT 100
				
				
				

SELECT order_date, store, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y'
GROUP BY order_date, store
Order BY order_date desc, price desc




SELECT *
FROM "product"
Order BY NO




SELECT k.product_no, p.nick
FROM "keyword_occ" AS k
LEFT JOIN "product" AS p ON (k.product_no = p.no) 







SELECT *
FROM "ad_batch"
WHERE Channel IS NULL 


Keyword = '오메가3' AND Channel = '쿠팡' AND owned_keyword = '자상호'





SELECT store, account, SUM(prd_amount_mod)
FROM "order_batch"
WHERE order_date = '2023-03-28' AND store IN ('쿠팡', '쿠팡2', '쿠팡_제트배송')
GROUP BY store, account



SELECT *
FROM "order_batch"
WHERE store = '쿠팡_제트배송'
LIMIT 10000


-- 통합검색 점유
SELECT o.reg_date, '네이버' AS channel, p.brand, p.nick, k.main_keyword, k.sub_keyword, o.imp_area, o.imp_order, o.title, o.url, o.rank
FROM "naver_inte_occ" AS o
LEFT JOIN "keyword_occ" AS k ON (o.sub_keyword = k.sub_keyword)
LEFT JOIN "product" AS p ON (k.product_no = p.no)
Order BY o.reg_date DESC, o.sub_keyword, imp_order, rank


-- 뷰검색 점유
-- 이건 Page 테이블에 join을 해서 자사 점유현황파악이 가능하도록.


-- 사전정의 vs 유연한 접근
-- body도 넣도록
-- 제목 혹은 텍스트에 판토모나 키워드 있으면 점유로 체크한다든지
-- 주요 키워드에서 판토모나 노출 갯수와 콜링 관계 비교
-- 경쟁사 콜링수 비교
-- 노출 개수와 콜링을 비교하거나

-- 서비스 안정성 작업
-- 리팩토링, 주석 작성
-- cac 전달
-- 출처 디렉토리 기입
-- 서브 노트북에 스케줄링 세팅
-- 요구사항을 받을 땐 좀 더 폭넓게 생각

-- 경쟁사 제품 라인업을 만들어서 랭킹을 구함. 키워드 개수로. 판토모나 1000개 타제품 몇개.
-- 콜링과의 상관관계와 영향을 가장 미치는 노출영역을 찾아본다거나. 가중치 부여.
-- 키워드 테이블에 자상호 비자상호 구분.
-- 비자상호 키워드에서만 우리제품vs경쟁사제품 비교한 후 콜링 비교.
-- 파워링크를 먹은 날에 콜링이 올라간다면? 파워링크에 집중한다든지.
-- 경쟁사 자상호 키워드도 넣어보고.
-- 콜링수가 높은걸 벤치마킹
-- 우리보다 높은 애들은 어떤 패턴을 가지고 있는지 조사
-- 대시보드도 구상
-- 이 프로젝트의 골 : 네이버에서 광고 및 컨텐츠의 운영전략을 어떻게 해야 가장 효율적일까.
-- 남들의 매출은 잘 모르니 상수는 검색수(콜링수)
-- 우리보다 높은 콜링수를 가진 애들이 어떻게 하고있는지를 분석
-- 한달정도 데이터 쌓으면 패턴이 나올 것.
-- 우리는 콜링당 매출을 알 수 있음. 다른 곳도 평균객단가를 계산해서 콜링당매출을 알 수 있음.
-- 우리보다 나은 제품을 분석해서 우리가 가장 최적화된 방법으로 콜링수를 높이는 전략을 찾을 것.
-- 5개 노출되면 A등급 이런 식으로 등급 부여 가능.
-- 데이터가 쌓이는 시간이 필요하니 생각나는 키워드는 다 때려넣을 것. 경쟁사 키워드도.
-- 대시보드 구상은 데이터 분석 이후에 작업







SELECT *
FROM "ad_batch"
WHERE channel IS NULL 


= '구글' AND store IS null








-- 2. 쿠팡
-- 쿠팡 상품광고
-- 자상호 기준 변경
SELECT 	y.yymm, y.yyww, y.yymmdd, '쿠팡' AS Channel, '쿠팡' AS store, p.brand, p.nick, 
			c.account, '상품광고' AS "ad_type", c."ad_type" AS "campaign_type", C."adspace" AS imp_area,
			c.campaign, c.ad_group, '' AS creative,
			
		 	CASE
		 		WHEN REPLACE(c.keyword, ' ', '') LIKE '트리플' AND REPLACE(c.keyword, ' ', '') NOT LIKE'마그네슘' THEN '비자상호'
			    WHEN REPLACE(c.keyword, ' ', '') LIKE '%' || p.brand || '%' AND c.keyword <> '' THEN '자상호'
			    WHEN REPLACE(c.keyword, ' ', '') LIKE '파이토웨이' THEN '자상호'
			    WHEN REPLACE(c.keyword, ' ', '') LIKE '하이퍼포머' THEN '자상호'
			    WHEN REPLACE(c.keyword, ' ', '') LIKE '플러스맥스' THEN '자상호'
			    WHEN REPLACE(c.keyword, ' ', '') LIKE '블러드케어' THEN '자상호'
			    WHEN REPLACE(c.keyword, ' ', '') LIKE '에버그린' THEN '자상호'
			    WHEN REPLACE(c.keyword, ' ', '') LIKE '트리플마그네슘' THEN '자상호'
			    
			    ELSE '비자상호'
			END AS owned_keyword, c.keyword, 
			
			c.adcost AS cost, c.impressions AS imp_cnt, c.clicks AS click_cnt, c.order_cnt, c.gross AS order_price, C."Z" AS order_cnt_14, c."AF" AS order_price_14, c.product2_id, c.adcost AS "cost_payback"
FROM "AD_Coupang" AS c
LEFT JOIN (SELECT * FROM "ad_mapping3" WHERE channel_no = 5) AS m ON (m.product2_id = c.product2_id)
LEFT JOIN "product" AS p ON (m.product_no = p.no)
LEFT JOIN "YMD2" AS y ON (y.yymmdd = c.reg_date)








-- 쿠팡 브랜드광고
-- 자상호 기준 변경
SELECT y.yymm, y.yyww, y.yymmdd, '쿠팡' AS Channel, '쿠팡' AS store,

 		CASE
         WHEN (cb.product2_id <> '0') THEN p.brand
         ELSE '파이토웨이'
     END AS brand,
     
     CASE
         WHEN ((cb.product2_id) <> '0') THEN p.nick
         ELSE '파이토웨이'
     END AS nick,
     
     cb.account, '브랜드광고' AS "ad_type", "template_type" AS campaign_type, impressions_type AS imp_area, 
     cb.campaign, cb.ad_group, cb."source" AS creative, 
     
   CASE
   	 WHEN REPLACE(cb.impression_keyword, ' ', '') LIKE '%트리플%' AND REPLACE(cb.impression_keyword, ' ', '') NOT LIKE '%마그네슘%' THEN '비자상호'
	    WHEN REPLACE(cb.impression_keyword, ' ', '') LIKE '%' || p.brand || '%' THEN '자상호'
	    WHEN REPLACE(cb.impression_keyword, ' ', '') LIKE '%파이토웨이%' THEN '자상호'
	    WHEN REPLACE(cb.impression_keyword, ' ', '') LIKE '%하이퍼포머%' THEN '자상호'
	    WHEN REPLACE(cb.impression_keyword, ' ', '') LIKE '%플러스맥스%' THEN '자상호'
	    WHEN REPLACE(cb.impression_keyword, ' ', '') LIKE '%블러드케어%' THEN '자상호'
	    WHEN REPLACE(cb.impression_keyword, ' ', '') LIKE '%에버그린%' THEN '자상호'
	    WHEN REPLACE(cb.impression_keyword, ' ', '') LIKE '%트리플마그네슘%' THEN '자상호'
		 ELSE '비자상호'
	END AS owned_keyword, cb.impression_keyword AS keyword,
 	cb.adcost AS cost, cb.impressions AS imp_cnt, cb.clicks AS click_cnt, cb.order_cnt, cb.gross AS order_price, cb."AO" AS order_cnt_14, cb."AU" AS order_price_14, cb.product2_id, cb.adcost AS "cost_payback"
FROM "AD_CoupangBrand" AS cb         
LEFT JOIN (SELECT * FROM "ad_mapping3" WHERE channel_no = 5) AS m ON (m.product2_id::text = cb.product2_id::text)
LEFT JOIN "product" AS p ON (m.product_no = p.no)
LEFT JOIN "YMD2" y ON (cb.reg_date::text = y.yymmdd::TEXT)










SELECT *
FROM "ad_mapping3"
WHERE channel_no = 2



SELECT *
FROM "product"
Order BY no



SELECT *
FROM "store"
Order BY no




