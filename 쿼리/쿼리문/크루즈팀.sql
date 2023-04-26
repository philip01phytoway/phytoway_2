-- 크루즈팀



-- 활동구간
select 	seq, order_date, order_name, order_tel, recv_name, recv_tel, recv_zip, recv_address,
		ez_channle_code, channel_id, channel_name, product_id, product_name, term, dead_date, product_qty, order_qty, price,
		case when prev_order_date is null then 'new' else 'reorder' end as order_type
from (
			select	*,
					lag(order_date, +1) over (partition by order_tel order by order_date, seq asc) as prev_order_date
			from	"Order2"
		)as o 
where dead_date between '2022-03-17' and '2023-06-10' 
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
)as o where dead_date between '2023-04-12' and '2023-05-10' order by order_date ASC


-- 문자발송
select * from sms_send_log where reserved_date between '2023-04-19' and '2023-04-26'

AND sms_content_title = '활성고객_판토모나'


-- 쿠팡 구매고객 db
SELECT         ("orderer" ->> 'name') || ("orderer" ->> 'email') AS "key",
                        LEFT("paidAt", 10) AS "order_date", 
                        REPLACE("paidAt", 'T', ' ') AS "order_date_time", 
                         ("orderer" ->> 'name') AS "ordererName",  
                         ("orderer" ->> 'email') AS "email",
                        ("orderer" ->> 'safeNumber') AS "ordererTel",
                        "orderId",
                        
                        ("receiver" ->> 'name') AS "recv_name",
                        ("receiver" ->> 'safeNumber') AS "recv_tel",
                        ("receiver" ->> 'postCode') AS "recv_zip",
                        ("receiver" ->> 'addr1') AS "recv_address",
                        
                        pp.brand, pp.nick, op.qty AS "product_qty", p."shippingCount" AS "order_qty", 1 AS "order_cnt",
                        op.qty * p."shippingCount" AS "out_qty", p."orderPrice", p."discountPrice", 
                        
                        p."orderPrice" - p."discountPrice" AS "realPrice",
                        pp.term, '쿠팡' AS store, 
                        
                        p."confirmDate"
                        
FROM "coupang_order" AS o,                                                                                                                                
                json_to_recordset(o."orderItems") as p(                                                                                                                                        
                        "vendorItemName" CHARACTER varying(255),                                                                                                                                
                        "vendorItemId" CHARACTER varying(255),
                        "shippingCount" INTEGER,
                        "orderPrice" INTEGER,
                        "discountPrice" INTEGER,
                        "confirmDate"         CHARACTER varying(255)                                                                                                                        
                )
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
WHERE LEFT("paidAt", 10) > '2022-10-13' AND LENGTH(("orderer" ->> 'safeNumber')) < 13
Order BY KEY, order_date



-- 크루즈팀 new 지표 2023-04-24	
SELECT '2023-04-25' AS "누적기준일", '써큐시안' as brand, count(distinct KEY) AS "누적고객수", '써큐시안첫구매고객' AS type
FROM "order_batch" 
WHERE all_cust_type = '신규' AND nick = '써큐시안'

UNION ALL 

SELECT  '2023-04-25' AS "누적기준일", brand, cnt, type
FROM 	(
			SELECT '판토모나' AS brand, COUNT(DISTINCT KEY) AS cnt, '판토모나교차구매고객' AS type
			FROM "order_batch"
			WHERE order_id <> '' AND phytoway = 'y' 
			AND KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND brand = '판토모나'
			
			UNION ALL 
			
			SELECT '판토모나하이퍼포머' AS nick, COUNT(DISTINCT KEY) AS cnt, '판토모나하이퍼포머교차구매고객' AS type
			FROM "order_batch"
			WHERE order_id <> '' AND phytoway = 'y' 
			AND KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND nick = '판토모나하이퍼포머'
			
			UNION ALL 
			
			SELECT '판토모나맨' AS nick, COUNT(DISTINCT o.KEY) AS cnt, '판토모나맨교차구매고객' AS type
			FROM "order_batch" AS o
			LEFT JOIN (
				SELECT DISTINCT KEY
				FROM "order_batch"
				WHERE nick = '판토모나하이퍼포머'
			) AS p ON (o.key = p.key)
			WHERE order_id <> '' AND phytoway = 'y' 
			AND p.key IS NULL
			AND o.KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND nick = '판토모나맨'
			
			UNION ALL 
			
			SELECT '판토모나레이디' AS nick, COUNT(DISTINCT o.KEY) AS cnt, '판토모나레이디교차구매고객' AS type
			FROM "order_batch" AS o
			LEFT JOIN (
				SELECT DISTINCT KEY
				FROM "order_batch"
				WHERE nick = '판토모나하이퍼포머' OR nick = '판토모나맨'
			) AS p ON (o.key = p.key)
			WHERE order_id <> '' AND phytoway = 'y' 
			AND p.key IS NULL
			AND o.KEY IN (
					
				SELECT key
				FROM "order_batch" 
				WHERE all_cust_type = '신규' AND nick = '써큐시안'
			)
			AND nick = '판토모나레이디' 
		) AS t







----------------------------------------------------------------------------------------

-- 퇴역한 쿼리

----------------------------------------------------------------------------------------

-- 크루즈팀 데이터 요청. 판토모나 고객 db. 2023-03-30
SELECT KEY, order_name AS "구매자명", order_date AS "주문일", order_tel AS "구매자 전화번호", cust_id AS "구매자 ID", recv_name AS "수령자명", recv_tel AS "수령자 전화번호", recv_address AS "수령지 주소", product_name AS "제품명", product_qty, order_qty, out_qty,
			rank() over(partition BY KEY Order BY order_date) AS "기간 내 구매횟수"
FROM "order4"
WHERE brand = '판토모나' AND store = '스마트스토어' 
AND order_date BETWEEN '2022-10-02' AND '2023-01-30' AND order_type = 'B2C'
Order BY KEY, "주문일", "기간 내 구매횟수"




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

