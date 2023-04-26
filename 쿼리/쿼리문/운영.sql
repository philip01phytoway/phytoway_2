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




-- 마케팅 비용은 컨텐츠와 기타로 나뉨.
-- 각각 보고서를 만들면 됨.

-- 컨텐츠부터.


-- 유튜브는 매핑 다시 해야 함
-- id가 아니라 키워드로 매핑해야 해서.






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





SELECT * FROM "cost_marketing"

SELECT * FROM "cost_product"



SELECT DISTINCT key
FROM "order_batch" 
WHERE all_cust_type = '신규' AND order_date >= '2022-10-01' 





WITH raw AS (
	SELECT order_name || cust_id AS key, * 
	FROM "EZ_Order" AS o,																		
			jsonb_to_recordset(o.order_products) as p(																	
				name character varying(255),																
				product_id character varying(255),																
				qty integer, 
				prd_amount integer															
			)
	LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
	LEFT JOIN "product" as pp on (b.product_no = pp.no)				
	WHERE order_date >= '2022-10-01' AND order_name || cust_id <> '' AND cust_id <> ''
	AND order_name || cust_id IN (
		
		SELECT DISTINCT key
		FROM "order_batch" 
		WHERE all_cust_type = '신규' AND order_date >= '2022-10-01' 
	)
)


SELECT  	*, 
		 	CASE 
			 	WHEN product_id IN ('00206', '00207', '00208', '00214') THEN 1
		 		ELSE 0
		 	END AS pamphlet 
FROM "raw"


SELECT * FROM "order_batch"
WHERE store = '스마트스토어_풀필먼트' AND brand = '판토모나' AND order_date BETWEEN '2023-04-19' AND '2023-04-25'

DENSE_RANK() over (partition BY KEY Order BY order_id) AS cnt,


주문일 이후 4개월 이내에 써큐시안 브랜드 재구매를 했느냐 안했느냐를 알아야 함.


-- 실험군_1개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 60)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 1 
								AND order_date BETWEEN '2022-04-02' AND '2022-06-07'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'





-- 실험군_3개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 180)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 3
								AND order_date BETWEEN '2022-04-02' AND '2022-06-07'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'




-- 대조군1_1개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 60)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 1
								AND order_date BETWEEN '2022-02-01' AND '2022-03-31'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'



-- 대조군1_3개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 180)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 3
								AND order_date BETWEEN '2022-02-01' AND '2022-03-31'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'




-- 대조군2_1개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 60)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 1
								AND order_date BETWEEN '2022-07-01' AND '2022-08-31'		
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'




-- 대조군2_3개입
SELECT COUNT(DISTINCT KEY)
FROM (

SELECT 	CASE 
				WHEN rank > 1 AND min_later_date > order_date THEN '재구매'
			END AS reorder, *	
FROM 	(
			SELECT 	MIN(later_date) over (partition BY KEY Order BY order_date_time) AS min_later_date, 
						*
			FROM 	(
						SELECT 	
									(order_date::DATE + 180)::text as later_date,
									rank() over (partition BY KEY Order BY order_date_time) AS rank,
									*			
						FROM "order_batch"
						WHERE KEY IN (
								SELECT DISTINCT key
								FROM "order_batch"
								WHERE brand_cust_type = '신규' AND brand = '써큐시안' AND out_qty = 3
								AND order_date BETWEEN '2022-07-01' AND '2022-08-31'	
						)
						AND brand = '써큐시안'
					) AS t
		) AS tt

) AS ttt
WHERE reorder = '재구매'



-- 대조군 1
SELECT 
			DENSE_RANK() over (partition BY KEY Order BY order_id) AS cnt,
			*,
			to_char(CASE 
							WHEN order_qty * product_qty * term * 1.2 > 365 THEN order_date::date + interval '1 day' * 365 
							ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 END, 
						'yyyy-mm-dd') AS dead_date
			
FROM "order_batch"
WHERE KEY IN (
		SELECT DISTINCT key
		FROM "order_batch"
		WHERE all_cust_type = '신규'
		AND order_date BETWEEN '2022-11-14' AND '2022-11-18'
)



-- 대조군 2
SELECT 
			DENSE_RANK() over (partition BY KEY Order BY order_id) AS cnt,
			*,
			to_char(CASE 
							WHEN order_qty * product_qty * term * 1.2 > 365 THEN order_date::date + interval '1 day' * 365 
							ELSE order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 END, 
						'yyyy-mm-dd') AS dead_date
			
FROM "order_batch"
WHERE KEY IN (
		SELECT DISTINCT key
		FROM "order_batch"
		WHERE all_cust_type = '신규'
		AND order_date BETWEEN '2022-11-28' AND '2022-12-02'
)








SELECT SUM(prd_amount_mod)
FROM "order_batch"
WHERE all_cust_type = '신규'

row_number : 17,882,566,433
rank : 18,176,049,389



SELECT SUM(prd_amount_mod)
FROM "order_batch"
WHERE order_id IN 
(
SELECT order_id
FROM "order_batch"
WHERE all_cust_type = '신규' AND order_status = '주문'
GROUP BY order_id
HAVING COUNT(*) > 1
)
