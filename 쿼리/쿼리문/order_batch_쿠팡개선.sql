-- order_batch 쿠팡 개선





SELECT order_date, SUM(price)
FROM "customer_zip5"
WHERE shop = '쿠팡' AND order_date BETWEEN '2023-01-01' AND '2023-04-30'
GROUP BY order_date



SELECT order_date, SUM(prd_amount_mod)
FROM "order_batch"
WHERE store = '쿠팡' AND order_date BETWEEN '2023-01-01' AND '2023-04-30' AND order_status <> '주문'
GROUP BY order_date



SELECT DISTINCT order_id
FROM "EZ_Order" as o,																		
		jsonb_to_recordset(o.order_products) as p(																	
			name character varying(255),																
			product_id character varying(255),																
			qty integer, 
			prd_amount integer,	
			prd_supply_price integer,															
			order_cs integer,																
			cancel_date character varying(255),																
			change_date character varying(255)																
		)
LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
LEFT JOIN "product" as pp on (b.product_no = pp.no)																		
WHERE	order_date > '2021-09-01' AND order_date < '2023-12-31' 
		AND order_id NOT IN (SELECT order_num FROM "Non_Order")	
		 AND pp.term > 0 AND o.order_name <> '' AND shop_name = '쿠팡'
AND order_date > '2022-12-31' AND order_date < '2023-05-01'



SELECT DISTINCT order_id
FROM "order_batch"
WHERE store = '쿠팡' AND order_date BETWEEN '2023-01-01' AND '2023-04-30' -- AND order_status <> '주문'











SELECT *
FROM "EZ_Order" as o,																		
		jsonb_to_recordset(o.order_products) as p(																	
			name character varying(255),																
			product_id character varying(255),																
			qty integer, 
			prd_amount integer,	
			prd_supply_price integer,															
			order_cs integer,																
			cancel_date character varying(255),																
			change_date character varying(255)																
		)
LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
LEFT JOIN "product" as pp on (b.product_no = pp.no)																		
WHERE	order_date > '2021-09-01' AND order_date < '2023-12-31' 
		AND order_id NOT IN (SELECT order_num FROM "Non_Order")	
		 AND pp.term > 0 AND o.order_name <> '' AND shop_name = '쿠팡'
AND order_date BETWEEN '2023-01-01' AND '2023-04-30'
AND order_id IN (
'21000168592762', '22000174851169', '22000173476112', '14000164581371', '5000170177986', '23000165839972', '18000172173852', '14000167466056', '11000164354221', '3000170482532', '5000171519126', '10000167296813', '16000166943920', '28000166242312', '29000169886746', '27000169067425', '22000165871444', '30000171199926', '17000164480697', '19000167922285', '25000164097889', '3000167379701', '6000169597433', '18000165182222', '4000166357363', '26000164479761', '9000168185656', '18000175277631', '14000171241125', '8000173013069', '15000169663355', '15000163675886', '9000173136550', '29000172053100', '24000170045997')


SELECT *
FROM "coupang_order" WHERE "orderId" = 15000163675886



SELECT *
FROM "EZ_Order" as o,																		
		jsonb_to_recordset(o.order_products) as p(																	
			name character varying(255),																
			product_id character varying(255),																
			qty integer, 
			prd_amount integer,	
			prd_supply_price integer,															
			order_cs integer,																
			cancel_date character varying(255),																
			change_date character varying(255)																
		)
LEFT JOIN "bundle" as b on (p.product_id = b.ez_code)																	
LEFT JOIN "product" as pp on (b.product_no = pp.no)																		
WHERE	order_date > '2021-09-01' AND order_date < '2023-12-31' 
		AND order_id NOT IN (SELECT order_num FROM "Non_Order")
		 AND pp.term > 0 AND o.order_name <> '' AND shop_name = '쿠팡'
AND order_date BETWEEN '2022-12-31' AND '2023-05-01'
AND order_id IN (
'2000176951359', '22000175696242', '25000176093690', '5000176640977', '8000175638481', '30000177256670', '3000177700906', '17000176918563', '6000177164413', '8000175395960', '11000176027250', '2000175604737', '11000176172042', '9000177207213', '12000175773828', '6000178597183', '20000176856634', '15000175556312', '15000175275297', '1000176534152', '23000175974000', '18000177019037', '23000175718857', '13000177570215', '1000176381480', '11000175611432', '17000176764991', '4000178670188')



SELECT *
FROM "order_batch"
WHERE order_id IN (
'2000176951359', '22000175696242', '25000176093690', '5000176640977', '8000175638481', '30000177256670', '3000177700906', '17000176918563', '6000177164413', '8000175395960', '11000176027250', '2000175604737', '11000176172042', '9000177207213', '12000175773828', '6000178597183', '20000176856634', '15000175556312', '15000175275297', '1000176534152', '23000175974000', '18000177019037', '23000175718857', '13000177570215', '1000176381480', '11000175611432', '17000176764991', '4000178670188')


SELECT *
FROM "Non_Order"
WHERE order_num IN (
'2000176951359', '22000175696242', '25000176093690', '5000176640977', '8000175638481', '30000177256670', '3000177700906', '17000176918563', '6000177164413', '8000175395960', '11000176027250', '2000175604737', '11000176172042', '9000177207213', '12000175773828', '6000178597183', '20000176856634', '15000175556312', '15000175275297', '1000176534152', '23000175974000', '18000177019037', '23000175718857', '13000177570215', '1000176381480', '11000175611432', '17000176764991', '4000178670188')


SELECT *
FROM "EZ_Order"
WHERE order_id IN (
'2000176951359', '22000175696242', '25000176093690', '5000176640977', '8000175638481', '30000177256670', '3000177700906', '17000176918563', '6000177164413', '8000175395960', '11000176027250', '2000175604737', '11000176172042', '9000177207213', '12000175773828', '6000178597183', '20000176856634', '15000175556312', '15000175275297', '1000176534152', '23000175974000', '18000177019037', '23000175718857', '13000177570215', '1000176381480', '11000175611432', '17000176764991', '4000178670188')



SELECT * FROM "coupang_return_cancel"
WHERE "orderId"::TEXT IN (
'2000176951359', '22000175696242', '25000176093690', '5000176640977', '8000175638481', '30000177256670', '3000177700906', '17000176918563', '6000177164413', '8000175395960', '11000176027250', '2000175604737', '11000176172042', '9000177207213', '12000175773828', '6000178597183', '20000176856634', '15000175556312', '15000175275297', '1000176534152', '23000175974000', '18000177019037', '23000175718857', '13000177570215', '1000176381480', '11000175611432', '17000176764991', '4000178670188')
