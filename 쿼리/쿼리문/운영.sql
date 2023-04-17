SELECT *
FROM "EZ_Order"
WHERE order_date >= '2023-04-10'
Order BY order_date



-- 파이토웨이 계간지
SELECT	order_id, '계간지, 공통삽지' AS 삽지, order_date_time
from	"order3" AS o
where	order_date_time between '2023-04-11 14:00:00' AND '2023-04-12 09:00:00'
and	order_name || recv_zip 
IN (
		select	order_name || recv_zip
		from 	"order3"
		group by order_name || recv_zip
		having count(*) = 1
	)
AND product_name <> '기타'
Order BY order_date_time ASC, seq



-- 서큐시안 미니북
SELECT order_id, '미니책자' AS 삽지, order_date_time
from	"order3"
WHERE	(order_date_time between '2023-04-11 14:00:00' AND '2023-04-12 09:00:00' ) 
		and product_name = '써큐시안' 
		and order_name || recv_zip 
in (
		select	order_name || recv_zip
		from 	"order3"
		where	product_name = '써큐시안'
		group by order_name || recv_zip
		having count(*) = 1
	)
Order BY order_date_time ASC, seq



-- 활동구간
select 	seq, order_date, order_name, order_tel, recv_name, recv_tel, recv_zip, recv_address,
		ez_channle_code, channel_id, channel_name, product_id, product_name, term, dead_date, product_qty, order_qty, price,
		case when prev_order_date is null then 'new' else 'reorder' end as order_type
from (
			select	*,
					lag(order_date, +1) over (partition by order_tel order by order_date, seq asc) as prev_order_date
			from	"Order2"
		)as o 
where dead_date between '2022-03-03' and '2023-05-27' 
AND product_name LIKE '%판토모나%'
order by order_date ASC



-- 만료구간
select 	seq, order_date, order_name, order_tel, recv_name, recv_tel, recv_zip, recv_address,
		ez_channle_code, channel_id, channel_name, product_id, product_name, term, dead_date, product_qty, order_qty, price,
		case when prev_order_date is null then 'new' else 'reorder' end as order_type
from (
select	*,
					lag(order_date, +1) over (partition by order_tel order by order_date, seq asc) as prev_order_date
			from	"Order2"
)as o where dead_date between '2023-03-29' and '2023-04-26' order by order_date ASC


-- 문자발송
select * from sms_send_log where reserved_date between '2023-04-05' and '2023-04-12'
AND sms_content_title = '활성고객_판토모나'


-- 마케팅 비용은 컨텐츠와 기타로 나뉨.
-- 각각 보고서를 만들면 됨.

-- 컨텐츠부터.


-- 유튜브는 매핑 다시 해야 함
-- id가 아니라 키워드로 매핑해야 해서.






--써큐시안 재구매 고객 db 3차. 2023-02-22
SELECT *
FROM  (
		   select key, seq, order_name, zip, tel, Product, order_date,
		   
                     lag(product, -1) over(partition BY KEY Order BY seq) as product2,
                     lag(order_date, -1) over(partition BY KEY Order BY seq) as order_date2,
                     
                     lag(product, -2) over(partition BY KEY Order BY seq) as product3,
                     lag(order_date, -2) over(partition BY KEY Order BY seq) as order_date3,
                     
                     lag(product, -3) over(partition BY KEY Order BY seq) as product4,
                     lag(order_date, -3) over(partition BY KEY Order BY seq) as order_date4,
                     
                     lag(product, -4) over(partition BY KEY Order BY seq) as product5,
                     lag(order_date, -4) over(partition BY KEY Order BY seq) as order_date5                
		   FROM   (
                     select        key, seq, order_name, zip, tel, product || '_' || (product_qty * order_qty)::varchar(20) as Product, order_date
                     from        customer_zip2
               ) AS t
      ) AS t                
WHERE (key, seq) in (select key, min(seq) AS seq from customer_zip2 group by key)
and Product LIKE  '%써큐시안%'
Order BY order_date, KEY


옵션별 이지어드민 상품코드를 Bundle 테이블 매핑 후 Bundle 테이블에 Product 테이블을 매핑하고 있기 때문에
옵션별로 상품코드를 따지 않고 상품 하나로 통합한다면?
물론 그래도 상품 알 수 있고, 주문서에 있는 qty로 수량도 알 수 있긴 한데.
그럼 order3 만들어야 함.
그럼 qty에 product_qty랑 order_qty 다 반영이 되는 거지?
1개 짜리를 3개 시키면 qty = 3으로 나오는거지?


--
store 연결해서 b2b는 제외하고
order3 만들고
Customer_Zip4 만들자.


-- customer_zip4
-- 상품코드 반영
-- b2b 제외
-- 자사몰 네이버페이 반영  


가설 : 
B2B를 제외하면서
메디에서 사고 스스, 쿠팡에서 재구매한 고객들을
B2C 신규고객으로 측정했기 때문에 신규 매출이 늘었을 것이다.

그럼, 2022년에 메디에서 첫구매했고 2023년에 스스, 쿠팡에서 재구매한 고객들이 얼마나 되는지 알아보자.

데이터분석가가 일하는 방법은 이미 circula 공식으로 나와있지 않나?
그것도 책의 첫 장에 나오는 건데.
그냥 그걸 따라서 일하는게 일 잘하는거 아닐까?
중요한 내용이 책의 첫 장에 나올 확률이 높겠지.
 


사은품이 나가면 2행으로 찍힌다.
prd_amount도 중복으로 찍힌다.
그럼 사은품은 제거하는게 맞고.

근데 자사몰 사은품 말고
스스 사은품은 어떻게 찍히지?

그거랑 한 주문에 2개 상품 주문시 어떻게 찍히지?

사은품이 order_products에 포함되지 않는 것도 있군.

사은품으로 2개 찍히는 경우도 약통이라면 필터링이 됨.
실제 제품이라도 사은품인 경우 term은 찍히는데 prd_amount는 0으로 찍힘.

이제 문제는 교차구매가 어떻게 찍히냐는 것.

교차동시구매의 경우 주문번호는 같은데 각 행으로 찍힘
사은품의 경우 주문번호는 같고 각 행으로 찍히는데 가격은 0으로 찍힘.

목요일 출고부터 상품코드 1개입로 나가고,
어차피 product_qty = 1이니까 쿼리문 안바꿔도 되겠다.

매칭을 출고 수량에 맞게 해야 함.


같은 주문번호 안에서 여러개의 옵션을 주문했을 경우
주문번호는 같을지라도 관리번호는 옵션별로 다르게 찍힌다.
즉, 판토모나 남성용 여성용을 같은 주문번호에서 구매했을 시 이지어드민에 다른 관리번호로 찍힌다.
그런데 옵션 안에 판토모나 남성용과 여성용이 같은 묶음이라면?
그런 경우가 있나?
그런 경우일 때는 어떻게 찍히나?

[{"qty": "1", "name": "판토모나 비오틴 플러스 맥스 남성용, 4개 + 페미론큐 엘라스틴 콜라겐, 1개", "brand": "", "barcode": "PRMD00175", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "395960", "order_cs": "0", "prd_amount": "159000", "product_id": "00175", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "150049"}, {"qty": "1", "name": "페미론큐 엘라스틴 콜라겐, 1개", "brand": "", "barcode": "00063", "is_gift": "1", "link_id": "", "options": "", "prd_seq": "396229", "order_cs": "0", "prd_amount": "0", "product_id": "00063", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "0"}]
만약 사은품으로 나갔을 경우 prd_amount가 0이므로 걸러지고, 각 행으로 
만약 결합상품인 경우 00184, 00182


사은품 약통은 각 상품별로 order_products에 찍히지만 
판토모나 결합상품 (00182, 00184)일 땐 상품별로 안찍히네?
이건 이지어드민 설정에서 기인하는 것 같고,
이거 정확히 알아놔야 대처할 수 있을 거 같은데.


--써큐시안 3개입을 딱 1번 구매했으면서, 2023년 3월 8일 기준 6개월 이전에 구매한 고객
SELECT * 
FROM "customer_zip4" 
WHERE KEY in
			(
				SELECT key
				FROM "customer_zip4" 
				WHERE Product = '써큐시안' AND order_qty * product_qty = 3 AND shop <> '자사몰'
				GROUP BY KEY
				HAVING COUNT(*) = 1
			)
AND order_date > '2022-09-08' AND Product = '써큐시안' AND order_qty * product_qty = 3 AND shop <> '자사몰'
Order BY order_date, key


--써큐시안 3개입을 딱 2번 구매했으면서, 
-- 마지막 구매가 2023년 3월 8일 기준 6개월 이전에 구매한 고객
SELECT *
FROM 	(
			SELECT	*, rank() over(partition BY KEY Order BY seq) AS rank
			FROM 		"customer_zip4" 
			WHERE KEY in
						(
							SELECT key
							FROM "customer_zip4" 
							WHERE Product = '써큐시안' AND order_qty * product_qty = 3 AND shop <> '자사몰'
							GROUP BY KEY
							HAVING COUNT(*) = 2
						)
					AND  Product = '써큐시안' AND order_qty * product_qty = 3 AND shop <> '자사몰'
		) AS t
WHERE rank = 2 AND order_date > '2022-09-08'
Order BY order_date, KEY 


--써큐시안 3개입을 3회 이상  구매했으면서, 
-- 마지막 구매가 2023년 3월 8일 기준 6개월 이전에 구매한 고객
SELECT MAX(order_date) AS order_date, KEY, MAX(order_name) AS order_name,  MIN(tel) AS tel, MAX(zip) AS zip, MAX(brand) AS brand, MAX(Product) AS Product, shop, MAX(price) AS price, MAX(seq) AS seq, MAX(order_qty) AS order_qty, MAX(product_qty) AS product_qty, MAX(term) AS term, MAX(rank) AS max_rank
FROM 	(
			SELECT	*, rank() over(partition BY KEY Order BY seq) AS rank
			FROM 		"customer_zip4" 
			WHERE KEY in
						(
							SELECT key
							FROM "customer_zip4" 
							WHERE Product = '써큐시안' AND order_qty * product_qty = 3 AND shop <> '자사몰'
							GROUP BY KEY
							HAVING COUNT(*) >= 3
						)
					AND  Product = '써큐시안' AND order_qty * product_qty = 3 AND shop <> '자사몰'
		) AS t
WHERE rank >= 3 AND order_date > '2022-09-08'
GROUP BY KEY, shop
Order BY order_date, KEY


SELECT max_rank, COUNT(*)
FROM	(
			
			SELECT KEY, MAX(rank) AS max_rank
			FROM 	(
						SELECT *, rank() over(partition BY KEY Order BY seq) AS rank
						FROM "customer_zip4"
					) AS t
			GROUP BY key
			Order BY max_rank desc, KEY

		) AS t2
GROUP BY max_rank




-- 크루즈팀 데이터 요청. 판토모나 고객 db. 2023-03-30
SELECT KEY, order_name AS "구매자명", order_date AS "주문일", order_tel AS "구매자 전화번호", cust_id AS "구매자 ID", recv_name AS "수령자명", recv_tel AS "수령자 전화번호", recv_address AS "수령지 주소", product_name AS "제품명", product_qty, order_qty, out_qty,
			rank() over(partition BY KEY Order BY order_date) AS "기간 내 구매횟수"
FROM "order4"
WHERE brand = '판토모나' AND store = '스마트스토어' 
AND order_date BETWEEN '2022-10-02' AND '2023-01-30' AND order_type = 'B2C'
Order BY KEY, "주문일", "기간 내 구매횟수"



SELECT *
FROM "EZ_Order"
WHERE shop_name = '폐쇄몰' AND "options" LIKE '%미담라이프%'
AND order_date BETWEEN '2023-03-01' AND '2023-03-31'


SELECT *
FROM "EZ_Order"
WHERE order_id = '20230326-0000115'

'20230326-0000074'

[{"qty": "3", "name": "싸이토팜 관절 식물성 엠에스엠 MSM 100, 1개", "brand": "", "barcode": "PRMD00157", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "498781", "order_cs": "0", "prd_amount": "89250", "product_id": "00157", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "89250"}]
[{"qty": "1", "name": "페미론큐 글루타치온 플러스 비타민C, 1개", "brand": "", "barcode": "PRMD00189", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "498780", "order_cs": "0", "prd_amount": "89250", "product_id": "00189", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "89250"}]

11900 | 59500
59500 | 29750

89250

[{"qty": "3", "name": "써큐시안 블러드케어, 1개", "brand": "", "barcode": "00051", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "498785", "order_cs": "0", "prd_amount": "213500", "product_id": "00051", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "213500"}, {"qty": "1", "name": "써큐시안 미니책자", "brand": "", "barcode": "PRMD00206", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "499087", "order_cs": "0", "prd_amount": "0", "product_id": "00206", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "0"}]

1. 따블 제거
2. 각각 상품 매출


SELECT *
FROM "EZ_Order"
WHERE order_cs = 1 AND shop_name LIKE '%스토어%'
[{"qty": "3", "name": "판토모나 비오틴 플러스 맥스 남성용, 1개", "brand": "", "barcode": "PRMD00164", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "486528", "order_cs": "1", "prd_amount": "159000", "product_id": "00164", "shop_price": "0", "cancel_date": "2023-03-07 10:24:59", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "153229"}, {"qty": "1", "name": "약통, 1개", "brand": "", "barcode": "00068", "is_gift": "1", "link_id": "", "options": "", "prd_seq": "486579", "order_cs": "1", "prd_amount": "0", "product_id": "00068", "shop_price": "0", "cancel_date": "2023-03-07 10:24:59", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "0"}]


SELECT *
FROM "customer_zip5"
WHERE order_date = '2023-03-01' AND shop = '스마트스토어'


SELECT *
FROM "order4"
WHERE order_date = '2023-03-01' AND store = '스마트스토어'
Order BY key

WHERE order_id = '2023030158400061'


SELECT *
FROM "EZ_Order"
WHERE order_id = '2023030158400061'




SELECT 	"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "key", 
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') THEN LEFT("paymentDate", 10) 
			WHEN "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') THEN LEFT("claimRequestDate", 10) 
			END AS "order_date", 
			LEFT("paymentDate", 10) || ' ' || SUBSTRING("paymentDate", 12, 8) AS "order_date_time", "ordererName", "ordererId", "ordererTel", "orderId",		
			("shippingAddress" ->> 'name')::text AS "recv_name", REPLACE(("shippingAddress" ->> 'tel1')::text, '-', '') AS "recv_tel", ("shippingAddress" ->> 'zipCode')::TEXT AS recv_zip, ("shippingAddress" ->> 'baseAddress')::TEXT AS recv_address, 
			p.brand, p.nick AS product_name, o.option_qty AS "product_qty", "quantity" AS order_qty, 
			
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') THEN 1
			WHEN "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') THEN 0
			END AS "order_cnt", 
			
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') THEN "quantity" * o.option_qty
			WHEN "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') THEN 0
			END AS "out_qty", 
			
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') THEN "totalPaymentAmount"
			WHEN "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED') THEN 0
			END AS "price",
			
			p.term, '스마트스토어' AS store, 
			
			CASE WHEN "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED') AND "totalPaymentAmount" >= 500000 THEN '리셀러'
			ELSE 'B2C'
			END AS order_type,
			
			"decisionDate"
			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")



WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE'


SELECT * --SUM("totalPaymentAmount")
FROM 		"naver_order_product"
WHERE LEFT("paymentDate", 10) BETWEEN '2023-03-01' AND '2023-03-31'
AND "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED', 'PAYMENT_WAITING', 'CANCELED_BY_NOPAYMENT')
Order BY "paymentDate"

AND "productOrderStatus" IN ('EXCHANGED', 'CANCELED', 'RETURNED', 'PAYMENT_WAITING', 'CANCELED_BY_NOPAYMENT')


SELECT "deliveryAttributeType", * --SUM("totalPaymentAmount")
FROM 		"naver_order_product"
WHERE LEFT("cancelApprovalDate", 10) = '2023-03-01'

2023022833488361
2023030138712961
2023030147196701
2023030147471671
2023030158400061
2023022674524071

24420500

833900
912900

23586600

SELECT *
FROM "order4" WHERE order_id IN 

2023030155908211
2023030155908211
SELECT *
FROM "EZ_Order"
WHERE order_id IN 
(
'2023030155908211',
'2023030138712961',
'2023030139467791',
'2023030143370891',
'2023030147471671',
'2023030147196701',
'2023030158400061',
'2023030137738451')


SELECT *
FROM "EZ_Order"
WHERE order_id = '2023022833488361'


'2022070422958701'

WHERE order_cs > 0


SELECT *
FROM "naver_order_product"

SELECT *
FROM "Query_Log2"
WHERE query_date = '2023-03-01' AND Keyword IN (
'판토모나',
'판토모나비오틴',
'판토모나비오틴하이퍼포머',
'판토모나정',
'판토모나하이퍼포머',
'판토모나샴푸')


'판토모나하이퍼포머'

 '판토모나하이퍼포머'
 

SELECT order_id
FROM "order4"
GROUP BY order_id
HAVING COUNT(*) > 1

LIMIT 100



SELECT *
FROM "order4"
WHERE order_date > '2023-04-03' AND store = '스마트스토어' AND brand = '써큐시안'


order_id = '2023040481558411'

SELECT *
FROM "EZ_Order"
WHERE order_id = '2023040481558411'

39975
119925
[{"qty": "1", "name": "써큐시안 3구 선물 박스", "brand": "", "barcode": "PRMD00188", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "506321", "order_cs": "0", "prd_amount": "39975", "product_id": "00188", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "38524"}, {"qty": "3", "name": "써큐시안 블러드케어, 1개", "brand": "", "barcode": "00051", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "506526", "order_cs": "0", "prd_amount": "119925", "product_id": "00051", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "115572"}]

[{"qty": "1", "name": "판토모나 비오틴 플러스 맥스 남성용, 4개 + 페미론큐 엘라스틴 콜라겐, 1개", "brand": "", "barcode": "PRMD00175", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "394913", "order_cs": "0", "prd_amount": "159000", "product_id": "00175", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "153229"}, {"qty": "1", "name": "페미론큐 엘라스틴 콜라겐, 1개", "brand": "", "barcode": "00063", "is_gift": "1", "link_id": "", "options": "", "prd_seq": "395660", "order_cs": "0", "prd_amount": "0", "product_id": "00063", "shop_price": "0", "cancel_date": "", "change_date": "", "enable_sale": "1", "extra_money": "0", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "0"}]



SELECT *
FROM "EZ_Order" as o,																		
		jsonb_to_recordset(o.order_products) as p(																	
			name character varying(255),																
			product_id character varying(255),																
			qty integer, prd_amount integer,																
			order_cs integer,																
			cancel_date character varying(255),																
			change_date character varying(255)																
		)
LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
LEFT JOIN "product" as pp on (b.product_no = pp.no)		
WHERE pp.brand = '써큐시안' AND shop_name = '스토어팜(파이토웨이)'
Order BY seq


b.ez_code = '00188'


WHERE shop_produ
LIMIT 100

-- order5 1차
-- 제트배송 제외
-- key = 이름 + (id 혹은 id 없으면 전화번호)
SELECT * 
FROM "order5"
WHERE order_id = '22000064600171'

store = '쿠팡'
LIMIT 1

SELECT yymm, brand, SUM(prd_amount_mod) 
FROM "order_batch"
GROUP BY yymm, brand

DELETE FROM "order_batch"

INSERT INTO "order_batch" (yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type)
SELECT yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type FROM "order5"





SELECT *
FROM "order5"
LIMIT 1



CREATE PROCEDURE "cac_batch"()
BEGIN
    DELETE FROM "order_batch";
    INSERT INTO "order_batch" (
        yymm, yyww, order_date, order_date_time, key, order_id,
        order_status, order_name, cust_id, order_tel, recv_name, recv_tel,
        recv_zip, recv_address, store, phytoway, brand, nick, product_qty,
        order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price,
        term, decide_date, all_cust_type, brand_cust_type
    )
    SELECT
        yymm, yyww, order_date, order_date_time, key, order_id,
        order_status, order_name, cust_id, order_tel, recv_name, recv_tel,
        recv_zip, recv_address, store, phytoway, brand, nick, product_qty,
        order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price,
        term, decide_date, all_cust_type, brand_cust_type
    FROM "order5";
END


SELECT *
FROM "ad_view7"
LIMIT 1



SELECT *
FROM "EZ_Order"
WHERE order_id = '2023011022401371'


SELECT *
FROM "b2b_gross"
WHERE store_no = 25


SELECT 	("orderer" ->> 'name') || ("orderer" ->> 'email') AS KEY,
			"orderId"::text, '주문' as order_status, 
			
			LEFT("paidAt", 10) AS order_date,
			REPLACE("paidAt", 'T', ' ') AS "order_date_time",
			
			("orderer" ->> 'name') AS "ordererName",
			("orderer" ->> 'email') AS "ordererEmail",
			("orderer" ->> 'safeNumber') AS "ordererTel",
		 	 
			("receiver" ->> 'name') AS "receiverName",
			("receiver" ->> 'safeNumber') AS "receiverTel", -- 이건 case when 처리 필요한지?
			("receiver" ->> 'postCode') AS "receiverZip",
			("receiver" ->> 'addr1') AS "receiverAddress",
			
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255),
			"shippingCount" INTEGER,
			"cancelCount" INTEGER,
			"orderPrice" INTEGER,
			"discountPrice" INTEGER,
			"confirmDate" 	CHARACTER varying(255)															
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
WHERE "orderId"::text NOT IN (SELECT order_num FROM "Non_Order")



SELECT ("orderer" ->> 'safeNumber') AS "ordererTel"
FROM "coupang_order"
WHERE LENGTH(("orderer" ->> 'safeNumber')) <> 11

"ordererTel"
"165730"


171902
98046
67684


SELECT *
FROM "EZ_Order"
WHERE seq = 488089


SELECT *
FROM "order_batch"
WHERE yymm = '2022-08' AND brand = '판토모나'


SELECT *
FROM "naver_order_product"
WHERE "optionCode" = '5620800705'


SELECT 	*,
			to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
                                        order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date
FROM "order4"
WHERE product_name IN ('싸이토팜', '페미론큐글루타치온', '콘디맥스')
AND store = '스마트스토어'
AND order_date >= '2023-01-14'
Order BY KEY, order_date, brand


SELECT *
FROM "EZ_Order"
WHERE order_id = '2023022827820511'
