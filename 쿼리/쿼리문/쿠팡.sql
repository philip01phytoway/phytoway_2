
SELECT	"orderId", "orderedAt", "paidAt",
		 	("orderer" ->> 'name') AS "구매자명",
			("orderer" ->> 'safeNumber') AS "orderer_safeNumber",
			("orderer" ->> 'vendorItemName') AS "제품명",
			("receiver" ->> 'safeNumber') AS "수령자번호1",
			("receiver" ->> 'receiverNumber') AS "수령자번호2", "status",
			json_array_elements("orderItems")->>'confirmDate' AS "구매확정일",
			*
FROM "coupang_order" AS o


--WHERE "paidAt" < '2023-03-31'
ORDER BY "orderedAt" desc


-- 이건 실험을 하는게 정확할 것 같다.
-- 만약, 내가 쿠팡에서 구매를 하고 주문번호로 발주서 단건 조회를 했을 때 찍히고,
-- 취소를 한 뒤 발주서 단건 조회했을 때 안찍히고, 취소 조회에서 찍힌다면,
-- 그러면 취소 및 반품은 무시를 하고 발주서만 가져오면 그대로 매출일거잖아?

-- 음 그런데 구매도 가져오고 취소도 가져와서 sum을 하는게 낫지 않나?
-- + -를 하느냐, 0로 하느냐. 이 개념이 정확해야 한다.

-- 정확히 알아야 할 것.
-- 주문을 하면 -> 주문 api에 찍힌다.
-- 그런데 구매확정 전에 취소 및 반품을 하면 ->
-- 1) 주문 api에 여전히 찍히고, 값은 변한게 없으면서, 반품 api에 찍히는가?
-- 2) 주문 api에 여전히 찍히고, 값이 변해있으면서, 반품 api에 찍히는가?
-- 3) 주문 api에는 찍히지 않고, 반품 api에만 찍히는가? 
--(이 경우에는 db에 저장한 주문건을 삭제하거나 취소건과 sum을 해야겠지)

--> 주문 api에 여전히 찍히는 것도 있고, 찍히지 않는 것도 있는 것 같다.


-- 반품을 하면 반품 api에 찍히리라는 사실은 매우 확률이 높고,
-- 그렇다면 주문 api와의 관계를 어떻게 설정해야 하는지가 중요한 문제다.
-- 그럴땐 문서를 우선 보는게 좋겠지.

-- 그리고 쿠팡의 용어를 알아야 한다. item이 뭐냐?


SELECT *
FROM "EZ_Order"
WHERE shop_name = '쿠팡' 
--AND order_name = '이정희' AND order_mobile = '0503-8575-8497'

AND order_cs = 0
AND order_date BETWEEN '2021-01-01' AND '2021-12-31'


AND order_id = '32000172247716'

-- 배송 전 전체취소 주문번호 : 3,000,174,520,334
-- 배송 후 전체취소 주문번호 : 32,000,172,247,716

SELECT "orderId"::TEXT
FROM "coupang_order" AS o
WHERE "paidAt" BETWEEN '2022-12-01' AND '2022-12-31'

 "orderId"::TEXT IN (

	SELECT order_id
	FROM "EZ_Order"
	WHERE order_date BETWEEN '2022-12-01' AND '2022-12-31' 
	AND shop_name = '쿠팡' 
	
)
AND 


SELECT *
FROM "EZ_Order"
WHERE order_date BETWEEN '2022-01-01' AND '2022-12-31' 
AND shop_name = '쿠팡' 
AND order_id  IN (
		SELECT "orderId"::TEXT
		FROM "coupang_order" AS o
		WHERE "paidAt" BETWEEN '2022-01-01' AND '2022-12-31'
)



SELECT *
FROM "coupang_order" AS o
WHERE "orderId" =
9000157834594

[{"vendorItemPackageId":0,"vendorItemPackageName":"판토모나 비오틴 하이퍼포머","productId":6621868536,"vendorItemId":5456714771,"vendorItemName":"판토모나 비오틴 하이퍼포머 최적 배합 판토텐산 L시스틴 맥주효모 엽산 아연 셀레늄 영양제, 3박스 (6개월 분), 240정","shippingCount":1,"salesPrice":139000,"orderPrice":139000,"discountPrice":0,"instantCouponDiscount":0,"downloadableCouponDiscount":0,"coupangDiscount":0,"externalVendorSkuCode":"","etcInfoHeader":null,"etcInfoValue":null,"etcInfoValues":null,"sellerProductId":10233826143,"sellerProductName":"온누리 판토모나 240정","sellerProductItemName":"240정 3박스 (6개월 분)","firstSellerProductItemName":"240정 3박스 (6개월 분)","cancelCount":0,"holdCountForCancel":0,"estimatedShippingDate":"2022-11-15","plannedShippingDate":"","invoiceNumberUploadDate":"2022-11-15T16:15:11","extraProperties":{},"pricingBadge":false,"usedProduct":false,"confirmDate":"2022-11-23 17:27:07","deliveryChargeTypeName":"무료","canceled":false}]
-- 어라 그런데 리키님이 틀린거 아닐까.
-- 취소되어도 이지어드민에 새로운 행으로 안뜨는데?
-- 쿠팡만 그런가? 네이버는 다른가?
-- 만약에 새로운 행으로 찍히지 않는다면, 취소가 되었을 때 그 매출을 -가 아닌 0으로 집계해야 한다.


-- 취소 및 반품은
-- 취소 요청과 반품 요청을 각각 보내야되네.


-- 쿠팡 주문번호 자릿수가 다른 경우가 있다.
-- 이건 뭘까? 뭔가 단서가 될 것 같은데. (단서가 아닐 수도 있고.)



SELECT *
FROM 	(
			SELECT 	*, 
						jsonb_array_elements("order_products")->>'name' AS "n",
						jsonb_array_elements("order_products")->>'change_date' AS "change_date"
			
			FROM "EZ_Order"
			WHERE shop_name LIKE '%쿠팡%'
		) AS t
WHERE order_cs = 1

WHERE n = '체험단 안내문'

AND order_cs = 6


SELECT *
FROM "EZ_Order"

WHERE shop_name = '쿠팡'

WHERE order_id = '22000173476112'


SELECT *
FROM "coupang_return_cancel"
WHERE "orderId" = 32000172247716

[{"qty": "1", "name": "판토모나 비오틴 플러스 맥스 남성용, 1개", "brand": "", "barcode": "PRMD00164", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "476442", "order_cs": "3", "prd_amount": "79000", "product_id": "00164", "shop_price": "0", "cancel_date": "2023-02-16 18:04:40", "change_date": "", "enable_sale": "1", "extra_money": "0", "new_link_id": "", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "69789"}]
"order_cs"
"6"
"0"
"1"
"3"
"5"
[{"qty": "1", "name": "온누리 판토모나 240정, 3개", "brand": "", "barcode": "PRMD00104", "is_gift": "0", "link_id": "", "options": "", "prd_seq": "125893", "order_cs": "3", "prd_amount": "139000", "product_id": "00104", "shop_price": "0", "cancel_date": "2021-10-08 09:10:04", "change_date": "", "enable_sale": "1", "extra_money": "0", "supply_code": "20001", "supply_name": "자사", "supply_options": "", "prd_supply_price": "0"}]

order_id NOT IN (SELECT "orderId"::text FROM "coupang_order")
AND 

SELECT * FROM "coupang_return_cancel"


SELECT *
FROM "coupang_order" AS o
WHERE "orderedAt" > '2021-10-01'
Order BY "orderedAt"

56813
59177

LEFT JOIN "coupang_return_cancel" AS r ON (o."orderId" = r."orderId")
WHERE r."orderId" IS NOT NULL


IN (SELECT "orderId" FROM "coupang_return_cancel")



SELECT DISTINCT order_id
FROM "EZ_Order"
WHERE shop_name LIKE '%쿠팡%'
AND order_id NOT IN (SELECT DISTINCT "orderId"::TEXT FROM "coupang_order")


SELECT t."OrderCode"
FROM 	(
			SELECT DISTINCT LEFT("OrderCode", 14) AS "OrderCode"
			FROM "PA_Order" AS p
			WHERE "SiteName" = '쿠팡'
		) AS t
LEFT JOIN "coupang_order" AS c ON (t."OrderCode" = c."orderId"::TEXT)	
WHERE c."orderId" IS NULL AND t."OrderCode" NOT LIKE '% '

UNION ALL 

SELECT "OrderCode3"
FROM 	(
			SELECT LEFT("OrderCode2", 13) AS "OrderCode3"
			FROM 	(
						SELECT *,  LEFT("OrderCode", 14) AS "OrderCode2"
						FROM "PA_Order" AS p
						WHERE "SiteName" = '쿠팡'
					) AS t
			WHERE t."OrderCode2" LIKE '% '		
		) AS t2	
LEFT JOIN "coupang_order" AS c ON (t2."OrderCode3" = c."orderId"::TEXT)	
WHERE c."orderId" IS NULL


SELECT order_id
FROM "EZ_Order" AS e
LEFT JOIN "coupang_order" AS c ON (e.order_id = c."orderId"::text) 
WHERE shop_name = '쿠팡' AND c."orderId" IS NULL


SELECT *
FROM "EZ_Order"
WHERE order_id = '10000115346334'

SELECT *
FROM "coupang_order"
Order BY "orderedAt"


SELECT *
FROM "EZ_Order" AS e
LEFT JOIN "coupang_order" AS c ON (e.order_id = c."orderId"::text)
LEFT JOIN "coupang_return_cancel" AS r ON (e.order_id = r."orderId"::TEXT)
WHERE c."orderId" IS NULL AND r."orderId" IS NULL
AND shop_name = '쿠팡'



SELECT t."OrderCode"
FROM 	(
			SELECT DISTINCT replace(LEFT("OrderCode", 14), ' ', '') AS "OrderCode"
			FROM "PA_Order" AS p
			WHERE "SiteName" = '쿠팡'
		) AS t
LEFT JOIN "coupang_order" AS c ON (t."OrderCode" = c."orderId"::TEXT)	
LEFT JOIN "coupang_return_cancel" AS r ON (t."OrderCode" = r."orderId"::TEXT)
WHERE c."orderId" IS NULL AND r."orderId" IS NULL



SELECT 	("orderer" ->> 'name') || ("orderer" ->> 'email') AS "key",
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
			pp.term, '쿠팡' AS store, '' AS order_type, 
			
			p."confirmDate", *
			
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255),
			"shippingCount" INTEGER,
			"orderPrice" INTEGER,
			"discountPrice" INTEGER,
			"confirmDate" 	CHARACTER varying(255)															
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)



WITH return_id AS (
	SELECT r."orderId"::text
	FROM "coupang_return_cancel" AS r
	LEFT JOIN "coupang_order" AS o ON (r."orderId" = o."orderId")
	WHERE o."orderId" IS NULL
)
SELECT 
FROM "EZ_Order" AS o
LEFT JOIN return_id AS r ON (o.order_id = r."orderId") 
WHERE shop_name = '쿠팡'


SELECT o.order_id AS "EZ_Order", c."orderId"::TEXT AS "coupang_order", r."orderId"::TEXT AS "coupang_return_cancel", order_date
FROM "EZ_Order" AS o
LEFT JOIN "coupang_order" AS c ON (o.order_id = c."orderId"::TEXT)
LEFT JOIN "coupang_return_cancel" AS r ON (o.order_id = r."orderId"::TEXT)
WHERE shop_name = '쿠팡'
AND r."orderId" IS NOT null


23000175720582
20000175457156
2000174510338
SELECT *
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255),
			"shippingCount" INTEGER,
			"orderPrice" INTEGER,
			"discountPrice" INTEGER,
			"confirmDate" 	CHARACTER varying(255),
			"cancelCount" 	INTEGER														
		)


SELECT *
FROM "coupang_return_cancel" AS r
WHERE "receiptStatus" = 'RETURNS_COMPLETED'


[{"vendorItemPackageId":0,"vendorItemPackageName":"편강한방연구소 달에서 온 팩 파스형","vendorItemId":4868879777,"vendorItemName":"편강한방연구소 달에서 온 팩 파스형, 4개","purchaseCount":1,"cancelCount":1,"shipmentBoxId":923358628,"sellerProductId":792086689,"sellerProductName":"편강한방연구소 그날의 패치 달에서 온팩,4박스","releaseStatus":null,"cancelCompleteUser":NULL}]



-- coupang_order에 주문번호 있는데 & coupang_return_cancel에 주문번호 없는 경우
-- 정상 주문건
SELECT o."orderId" AS "coupang_order", r."orderId" AS "coupang_return_cancel"
FROM "coupang_order" AS o
LEFT JOIN "coupang_return_cancel" AS r ON (o."orderId" = r."orderId")
WHERE r."orderId" IS NULL
171649

-- coupang_order에 주문번호 있는데 & coupang_return_cancel에 주문번호 있는 경우
-- 취소 및 반품건
SELECT o."orderId" AS "coupang_order", r."orderId" AS "coupang_return_cancel"
FROM "coupang_order" AS o
LEFT JOIN "coupang_return_cancel" AS r ON (o."orderId" = r."orderId")
WHERE r."orderId" IS NOT NULL
46

-- coupang_order에 주문번호 없는데 & coupang_return_cancel에 주문번호 있는 경우
SELECT * --o."orderId" AS "coupang_order", r."orderId" AS "coupang_return_cancel"
FROM "coupang_return_cancel" AS r
LEFT JOIN "coupang_order" AS o ON (r."orderId" = o."orderId")
WHERE o."orderId" IS NULL
Order BY 
8726
-- 신기하게도 주문자 정보가 없음.
-- 쿠팡 윙에서 조회하면 취소건도 있고 반품건도 있다.
-- 이지어드민에서 조회하면 어떨까? 없다.
-- 주문 -> 취소 -> 발주인 경우.
-- 이 건은 원래의 주문건을 찾을 수가 없잖아?
-- 아직 일러.
-- coupang_return_cancel에 있는 건들은 전부 EZ_Order에 없느냐? 이걸 알아야 무시 여부 결정함.
SELECT *
FROM "EZ_Order"
WHERE order_id = '24000174718341'


SELECT * --r."orderId"::TEXT, e."order_id"
FROM "coupang_return_cancel" AS r
LEFT JOIN "EZ_Order" AS e ON (r."orderId"::text = e."order_id")
WHERE e."order_id" IS NOT NULL 




SELECT * --o."orderId" AS "coupang_order", r."orderId" AS "coupang_return_cancel"
FROM "coupang_return_cancel" AS r
LEFT JOIN "coupang_order" AS o ON (r."orderId" = o."orderId")
LEFT JOIN "EZ_Order" AS e ON (r."orderId"::text = e."order_id")
WHERE o."orderId" IS NULL AND e."order_id" IS NOT NULL 








SELECT	"orderId", "orderedAt", "paidAt",
		 	("orderer" ->> 'name') AS "구매자명",
			("orderer" ->> 'safeNumber') AS "orderer_safeNumber",
			("orderer" ->> 'vendorItemName') AS "제품명",
			("receiver" ->> 'safeNumber') AS "수령자번호1",
			("receiver" ->> 'receiverNumber') AS "수령자번호2", "status",
SELECT *
FROM "coupang_order" AS o
LIMIT 1000


-- 이름 + id
WITH cust_key AS (
SELECT	*,
		 	("orderer" ->> 'name') || ("receiver" ->> 'postCode') AS "name_zip",
		 	("orderer" ->> 'name') || ("orderer" ->> 'safeNumber') AS "name_tel",
			("orderer" ->> 'safeNumber') AS "tel",
			("orderer" ->> 'name') || ("orderer" ->> 'email') AS "name_id"
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255),
			"shippingCount" INTEGER,
			"orderPrice" INTEGER,
			"discountPrice" INTEGER,
			"confirmDate" 	CHARACTER varying(255)															
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
WHERE pp.brand <> '기타'
)

SELECT cnt, SUM(cnt)
FROM 	(
			SELECT "name_id", COUNT(*) AS cnt
			FROM "cust_key"
			GROUP BY "name_id"
		) AS t
GROUP BY cnt
Order BY cnt





-- 이름 + 전화번호
WITH cust_key AS (
SELECT	*,
		 	("orderer" ->> 'name') || ("receiver" ->> 'postCode') AS "name_zip",
		 	("orderer" ->> 'name') || ("orderer" ->> 'safeNumber') AS "name_tel",
			("orderer" ->> 'safeNumber') AS "tel",
			("orderer" ->> 'name') || ("orderer" ->> 'email') AS "name_id"
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255),
			"shippingCount" INTEGER,
			"orderPrice" INTEGER,
			"discountPrice" INTEGER,
			"confirmDate" 	CHARACTER varying(255)															
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
WHERE pp.brand <> '기타'
)

SELECT cnt, SUM(cnt)
FROM 	(
			SELECT "name_tel", COUNT(*) AS cnt
			FROM "cust_key"
			GROUP BY "name_tel"
		) AS t
GROUP BY cnt
Order BY cnt





{"name":"유한나","safeNumber":"0503-8195-3367","receiverNumber":null,"addr1":"강원도 고성군 토성면 아야진3길 13-1","addr2":"첫번째집","postCode":"24756"}
-- 전화번호
WITH cust_key AS (
SELECT	*,
		 	("orderer" ->> 'name') || ("receiver" ->> 'postCode') AS "name_zip",
		 	("orderer" ->> 'name') || ("orderer" ->> 'safeNumber') AS "name_tel",
			("orderer" ->> 'safeNumber') AS "tel",
			("orderer" ->> 'name') || ("orderer" ->> 'email') AS "name_id"
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255),
			"shippingCount" INTEGER,
			"orderPrice" INTEGER,
			"discountPrice" INTEGER,
			"confirmDate" 	CHARACTER varying(255)															
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
WHERE pp.brand <> '기타'
)

SELECT *
FROM "cust_key"
WHERE "name_id" IS NULL 


SELECT * --cnt, SUM(cnt)
FROM 	(
			SELECT "tel", COUNT(*) AS cnt
			FROM "cust_key"
			GROUP BY "tel"
		) AS t
WHERE cnt = 461 --671
GROUP BY cnt
Order BY cnt



-- 이름+ㅇ편번호
WITH cust_key AS (
SELECT	*,
		 	("orderer" ->> 'name') || ("receiver" ->> 'postCode') AS "name_zip",
		 	("orderer" ->> 'name') || ("orderer" ->> 'safeNumber') AS "name_tel",
			("orderer" ->> 'safeNumber') AS "tel",
			("orderer" ->> 'name') || ("orderer" ->> 'email') AS "name_id"
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(																	
			"vendorItemName" CHARACTER varying(255),																
			"vendorItemId" CHARACTER varying(255),
			"shippingCount" INTEGER,
			"orderPrice" INTEGER,
			"discountPrice" INTEGER,
			"confirmDate" 	CHARACTER varying(255)															
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
WHERE pp.brand <> '기타'
)

SELECT * --cnt, SUM(cnt)
FROM 	(
			SELECT "name_zip", COUNT(*) AS cnt
			FROM "cust_key"
			GROUP BY "name_zip"
			
		) AS t
WHERE cnt = 1671		
		
GROUP BY cnt
Order BY cnt















-- 네이버 기준 쿠팡 교차
SELECT *
FROM 	(
			SELECT 	--"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "N_name_zip", 
						--DISTINCT ("ordererName" || "ordererTel") AS "N_name_tel"
						DISTINCT "ordererTel" AS "N_tel"
						--"ordererName" || "ordererId" AS "N_name_id"
					
						
			FROM 		"naver_order_product" AS n
			LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
			LEFT JOIN "product" AS p ON (o."product_no" = p."no")
		) AS n
LEFT JOIN (
			SELECT	
					 	--("orderer" ->> 'name') || ("receiver" ->> 'postCode') AS "C_name_zip",
					 	--DISTINCT (("orderer" ->> 'name') || ("orderer" ->> 'safeNumber')) AS "C_name_tel"
						DISTINCT (("orderer" ->> 'safeNumber')) AS "C_tel"
						--("orderer" ->> 'name') || ("orderer" ->> 'email') AS "C_name_id"
			FROM "coupang_order" AS o,																
					json_to_recordset(o."orderItems") as p(																	
						"vendorItemName" CHARACTER varying(255),																
						"vendorItemId" CHARACTER varying(255),
						"shippingCount" INTEGER,
						"orderPrice" INTEGER,
						"discountPrice" INTEGER,
						"confirmDate" 	CHARACTER varying(255)															
					)
			LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
			LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
			WHERE pp.brand <> '기타'
			) AS c ON (n."N_tel" = c."C_tel")
WHERE c."C_tel" IS NOT NULL 


-- 케빈님 요청 쿠팡 데이터
-- 결제일 6개월 전, 결제 후 5일 뒤, 안심번호 필터링해서.
-- 제품별

SELECT 	("orderer" ->> 'name') || ("orderer" ->> 'email') AS "key",
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
			"confirmDate" 	CHARACTER varying(255)															
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
LEFT JOIN "product" AS pp ON (op.product_no = pp.no)
WHERE LEFT("paidAt", 10) > '2022-10-13' AND LENGTH(("orderer" ->> 'safeNumber')) < 13
Order BY KEY, order_date