몇가지 의문들.

1. 주문번호와 상품주문번호는 1:1 관계인가? 1:N 관계일텐데, 그럼 중복이 얼마나 있지?
상품주문번호 : 658
주문번호 : 642
==> 주문번호는 중복이 있다! 따라서 1:N 관계이다.

2. 상품주문번호 테이블은 이지오더와 일치하는가?
어제자 데이터로 검증해보자.
결제일자가 주문일자이고,
주문 취소한 경우도 필터 걸어야 함.

3. 최근 6개월로 업데이트, 토큰 30분 업데이트





SELECT PUBLIC.naver_order_product."productOrderId", PUBLIC.naver_order_product."orderId", PUBLIC.naver_order_product."ordererName"
, PUBLIC.naver_order_product."paymentDate"
FROM "naver_order_product"
WHERE PUBLIC.naver_order_product."paymentDate" >= '2023-03-12' AND 
PUBLIC.naver_order_product."paymentDate" < '2023-03-13' AND
PUBLIC.naver_order_product."cancelReason" IS NULL
ORDER BY PUBLIC.naver_order_product."productOrderId"

"naver_order_product.paymentDate" >= '2023-03-12' AND "naver_order_product.paymentDate" < '2023-03-13'


SELECT order_id, order_id_order_date_time, order_name, order_date
FROM "EZ_Order" WHERE order_date >= '2023-03-12' AND order_date < '2023-03-13'
AND shop_name = '스토어팜(파이토웨이)'
Order BY order_id_order_date_time


SELECT *
FROM "EZ_Order"
WHERE order_id_order_date_time = 
'2023031283575501'


'2023031276526031'

'2023031266579891'


'2023031266136431'
2023-03-12 00:14:07

SELECT *
FROM "naver_order_product"
ORDER BY 
WHERE PUBLIC.naver_order_product."cancelReason" IS NULL AND 
PUBLIC.naver_order_product."returnReason" IS NULL AND 
PUBLIC.naver_order_product."exchangeReason" IS NULL

12047

취소말고 반품도 있겠지.

12719

SELECT * --DISTINCT "productOrderId" --"orderId"
FROM "naver_order"

12719
WHERE PUBLIC.naver_order_product."productOrderId" = '2023031283575501'


SELECT *
FROM "naver_order"







SELECT 	o.order_date_time,
    		"substring"((o.order_date)::text, 1, 10) AS order_date,
    		replace((o.order_name)::text, ' '::text, ''::text) AS order_name,
        CASE
            WHEN (("substring"((o.order_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o.order_mobile)::text, 1, 3) = '050'::text)) THEN replace((o.order_mobile)::text, '-'::text, ''::text)
            ELSE
            CASE
                WHEN (("substring"((o.order_tel)::text, 1, 3) = '010'::text) OR ("substring"((o.order_tel)::text, 1, 3) = '050'::text)) THEN replace((o.order_tel)::text, '-'::text, ''::text)
                ELSE
                CASE
                    WHEN (("substring"((o.recv_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o.recv_mobile)::text, 1, 3) = '050'::text)) THEN replace((o.recv_mobile)::text, '-'::text, ''::text)
                    ELSE
                    CASE
                        WHEN (("substring"((o.recv_tel)::text, 1, 3) = '010'::text) OR ("substring"((o.recv_tel)::text, 1, 3) = '050'::text)) THEN replace((o.recv_tel)::text, '-'::text, ''::text)
                        ELSE replace((o.order_mobile)::text, '-'::text, ''::text)
                    END
                END
            END
        END AS order_tel,
    		replace((o.recv_name)::text, ' '::text, ''::text) AS recv_name,
        CASE
            WHEN (("substring"((o.recv_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o.recv_mobile)::text, 1, 3) = '050'::text)) THEN replace((o.recv_mobile)::text, '-'::text, ''::text)
            ELSE
            CASE
                WHEN (("substring"((o.recv_tel)::text, 1, 3) = '010'::text) OR ("substring"((o.recv_tel)::text, 1, 3) = '050'::text)) THEN replace((o.recv_tel)::text, '-'::text, ''::text)
                ELSE
                CASE
                    WHEN (("substring"((o.order_mobile)::text, 1, 3) = '010'::text) OR ("substring"((o.order_mobile)::text, 1, 3) = '050'::text)) THEN replace((o.order_mobile)::text, '-'::text, ''::text)
                    ELSE
                    CASE
                        WHEN (("substring"((o.order_tel)::text, 1, 3) = '010'::text) OR ("substring"((o.order_tel)::text, 1, 3) = '050'::text)) THEN replace((o.order_tel)::text, '-'::text, ''::text)
                        ELSE replace((o.recv_mobile)::text, '-'::text, ''::text)
                    END
                END
            END
        END AS recv_tel,
o.recv_zip,
o.recv_address,
o.shop_id AS ez_channle_code,
s.no AS store_no,
s.name AS store_name,
o.product_id AS ez_product_code,
o.product_no,
o.brand,
o.nick AS product_name,
o.term,
to_char(
  CASE
      WHEN (((((o.product_qty * o.order_qty) * o.term))::numeric * 1.2) > (365)::numeric) THEN ((o.order_date)::date + ('1 day'::interval * (365)::double precision))
      ELSE ((o.order_date)::date + (((('1 day'::interval * (o.product_qty)::double precision) * (o.order_qty)::double precision) * (o.term)::double precision) * (1.2)::double precision))
  END, 'yyyy-mm-dd'::text) AS dead_date,
o.product_qty,
o.order_qty,
o.prd_amount_mod AS price,
o.order_products,
o.trans_no,
o.trans_date,
o.cust_id,
o.order_id,
o.order_date as order_date_time,
o."options"
FROM 	(
			SELECT *, p.qty AS order_qty, b.qty AS product_qty,
						CASE 
							WHEN shop_name = '자사몰' AND prd_amount = 0 THEN b.price
							ELSE prd_amount
						END AS prd_amount_mod 
			FROM "EZ_Order" AS o,
				(
					LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
					LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
					LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
				)
		) AS o
LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
WHERE 
		o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' AND o.term > 0 AND o.order_name <> '' and o.prd_amount_mod > 0
		AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")
		
		
		
SELECT *
FROM "order3"
WHERE store_no = 41

store_name LIKE '%로켓%'


("options" LIKE '%메디%' AND order_date >= '2022-08-23')


SELECT * --shop_id, shop_name, product_name, OPTIONS, collect_date, order_date, trans_date, trans_date_pos
FROM "EZ_Order" AS o 
WHERE shop_name LIKE '%로켓%'
Order BY order_date




SELECT * FROM "b2b_gross"
Order BY order_date

 WHERE store_no = 41


LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
WHERE shop_id = 10087

Order BY order_date_time DESC
LIMIT 10000

B2B_로켓배송

SELECT * FROM "prev_product_order_id"


SELECT "productOrderId"
FROM "naver_order"
WHERE "productOrderId" NOT IN (SELECT "productOrderId" FROM "naver_order_product")
ORDER BY "productOrderId"

"naver_order"에는 있는데 "naver_order_product"에는 없는 상품주문번호를 가져와야 한다.



"ordererId", "ordererNo", "shippingAddress", "productOrderId",
"orderId", "orderDate",  "placeOrderDate", "deliveredDate", "decisionDate",
"optionCode", "productId",
CASE WHEN "productId" = '4989285456' THEN '판토모나하이퍼포머'
WHEN "productId" = '6914442284' THEN '페미론큐이노시톨'
END AS product,
"productName", "productOption", "quantity", "totalPaymentAmount", "paymentCommission", "expectedSettlementAmount",
"productOrderStatus", "inflowPath"



-- 옵션코드로 번들 구분
SELECT  LEFT("paymentDate", 10) AS "paymentDate", p."optionCode", p."productName", p."totalPaymentAmount", o."option_qty", o."product_no", "quantity", o."option_qty" * "quantity" AS "qty"
FROM 		"naver_order_product" AS p
LEFT JOIN "naver_option" AS o ON (p."optionCode" = o."optionCode")
WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE'
AND "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED')
ORDER BY "paymentDate" 




-- product, ymd2 테이블 복사
WITH naver_fulfillment 
AS (
		SELECT 	"ordererName", "ordererTel", "ordererId", "ordererNo", "productOrderId",
					"orderId", "orderDate", LEFT("paymentDate", 10) AS "paymentDate", "placeOrderDate", "deliveredDate", "decisionDate",
					"optionCode", "productId",
					"productName", "productOption", "quantity", "totalPaymentAmount", "paymentCommission", "expectedSettlementAmount",
					"productOrderStatus", "inflowPath"
		FROM 		"naver_order_product"
		WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE'
					AND "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED')
		ORDER BY "paymentDate" 
)


SELECT y.yymm, y.yyww, y.yymmdd, p.brand, p.nick, '스마트스토어_풀필먼트' AS store, SUM("totalPaymentAmount") AS "gross", COUNT(*) AS "주문건수", SUM(o."option_qty" * "quantity") AS "주문수량"
FROM naver_fulfillment AS f
LEFT JOIN "naver_option" AS o ON (f."optionCode" = o."optionCode")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")
LEFT JOIN "YMD2" AS y ON (f."paymentDate" = y."yymmdd")
GROUP BY y.yymm, y.yyww, y.yymmdd, p.brand, p.nick
ORDER BY y.yymmdd desc


"optionCode"	"productName"
"25890867418"	"판토모나-비오틴 판토텐산 10가지 기능성 복합 영양제 650mg x 240정"
"27752723288"	"판토모나-비오틴 판토텐산 10가지 기능성 복합 영양제 650mg x 240정"
"29180498354"	"판토모나-비오틴 판토텐산 10가지 기능성 복합 영양제 650mg x 240정"
"6914442284"	"페미론큐 이노시톨 플러스 콜린-복합 관리 49종 복합 성분 3g x 50포" (편집됨) 


SELECT * FROM "YMD2"


SELECT * FROM "product"


SELECT * FROM "naver_order"


SELECT * FROM "naver_order_product"


SELECT "shippingAddress" ->> 'zipCode'
FROM 		"naver_order_product"
WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE'



SELECT 	LEFT("paymentDate", 10) AS "order_date", 
			"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "key", 
			"ordererName" AS "order_name", "ordererTel" AS "tel", "shippingAddress" ->> 'zipCode' AS "zip",
			p.brand, p.nick, '스마트스토어_풀필먼트' AS "shop", "totalPaymentAmount", '' AS "order_date_time", "quantity" , o.option_qty AS "product_qty", p.term			
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")
LEFT JOIN "YMD2" AS y ON (n."paymentDate" = y."yymmdd")
WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE' AND "productOrderStatus" IN ('PAYED', 'DELIVERING', 'DELIVERED', 'PURCHASE_DECIDED')



			