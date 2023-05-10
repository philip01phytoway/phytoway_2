-----------------------------------------

데이터수집 방어쿼리

-----------------------------------------

-- 사용자정의채널
SELECT * FROM "Naver_Custom_Order" Order by yymmdd DESC LIMIT 1000

-- 자동화 검증
SELECT SUM(customer_cnt), SUM(inflow_cnt), sum(page_cnt), SUM(order_cnt), SUM(order_price) FROM "Naver_Custom_Order" WHERE yymmdd = '2023-04-25'


-- 검색채널
SELECT * FROM "Naver_Search_Channel" Order by yymmdd DESC LIMIT 1000

SELECT * FROM "Naver_Search_Channel" WHERE yymmdd = '2023-04-25'


-- 네이버광고
SELECT DISTINCT id FROM "AD_Naver" WHERE reg_date = '2023-05-09'

SELECT * FROM "AD_Naver" WHERE reg_date = '2023-04-25' AND id = 'zero2one2'

-- 재고
SELECT * FROM "Stock" Order BY yymmdd DESC

-- 리뷰구매 리스트
SELECT * FROM "Non_Order" Order BY yymmdd desc

-- 쿠팡 판매통계 (제트배송) 계정 2개 모두.
SELECT * FROM "coupang_sales" Order BY reg_date DESC LIMIT 1000

SELECT * FROM "coupang_sales" WHERE reg_date = '2023-04-27' AND account <> 'A00197911'




-- 쿠팡 상품광고. 계정 2개 모두.
SELECT * FROM "AD_Coupang" Order BY reg_date desc LIMIT 10000


-- 쿠팡 브랜드광고
SELECT * FROM "AD_CoupangBrand" Order BY reg_date DESC LIMIT 10000

-- 구글 광고
SELECT * FROM "ad_google3" Order BY reg_date DESC

-- 구글 광고 매핑 누락 확인
광고그룹 id가 광고보고서에는 있는데 매핑 테이블에는 없는지

-- 구글 애널리틱스 광고그룹별
SELECT * FROM "ad_ga_aw" Order BY reg_date DESC 
매핑 누락 확인 필요

SELECT * FROM "ad_ga_aw" WHERE reg_date > '2023-04-27'

-- 구글 애널리틱스 utm_campaign별
SELECT * FROM "ad_ga_utm" Order BY reg_date DESC
매핑 누락 확인 필요

-- 메타 광고
SELECT * FROM "ad_meta" Order BY reg_date DESC


-- ADN 광고
SELECT * FROM "ad_adn" Order BY "date" DESC

-- 중복 매핑도 확인 필요. 누락 없이, 중복 없이 매핑해야 함. MECE.

SELECT distinct adgroup_id FROM "ad_mapping3" WHERE channel_no = 2

-- 네이버 중복 매핑 확인
SELECT campaign, adgroup
FROM "ad_mapping3" 
WHERE channel_no = 1
GROUP BY campaign, adgroup
HAVING COUNT(*) > 1


-- AD_Naver의 행 개수와 매핑 이후 행 개수를 비교해서 일치하는지 확인해야 할 듯

SELECT * FROM "AD_Naver" WHERE "B" = 'B_파이토웨이' AND "D" = '파이토웨이_MO'



-- 네이버 검색광고 매핑 누락 확인
SELECT DISTINCT "B", "D"
FROM "AD_Naver"
WHERE "B" NOT IN (SELECT DISTINCT campaign FROM "ad_mapping3" WHERE channel_no = 1)
AND reg_date >= '2023-10-01'

UNION ALL 

SELECT DISTINCT "B", "D"
FROM "AD_Naver"
WHERE "D" NOT IN (SELECT DISTINCT adgroup FROM "ad_mapping3" WHERE channel_no = 1)
AND reg_date >= '2023-10-01'

WITH naver_mapping AS (
		SELECT DISTINCT id, "B", "D", reg_date
		FROM "AD_Naver" AS a
		LEFT JOIN "ad_mapping3" AS m ON (a."B" = m.campaign AND a."D" = m.adgroup)
		WHERE m.campaign IS NULL OR m.adgroup IS NULL -- AND reg_date >= '2023-03-01'
		Order BY reg_date DESC
		LIMIT 100
)

SELECT DISTINCT id, "B", "D"
FROM "naver_mapping"


-- 쿠팡 상품광고 매핑 누락 확인
SELECT DISTINCT ad_account, c.product2, c.product2_id 
FROM "AD_Coupang" AS c 
LEFT JOIN "ad_mapping3" AS m ON (c.product2_id = m.product2_id) 
WHERE m.product2_id IS NULL

-- 쿠팡 브랜드광고 매핑 누락 확인
SELECT C.product2, C.product2_id
FROM "AD_CoupangBrand" AS c
LEFT JOIN "ad_mapping3" AS m ON (c.product2_id = m.product2_id)
WHERE m.product2_id IS NULL AND C.product2_id <> '0'

-- 구글 광고 매핑 누락 확인
SELECT * 
FROM "ad_google3" AS g
LEFT JOIN "ad_mapping3" AS m ON (g.adgroup_id = m.adgroup_id)
WHERE m.adgroup_id IS NULL 

SELECT *
FROM "ad_mapping3"
WHERE channel_no = 2

-- 메타 매핑 누락 확인
SELECT DISTINCT campaign, adgroup, ad
FROM (
			SELECT 	yymm, yyww, yymmdd, c.name AS channel, s.name AS store, p.nick, ad.campaign, ad.adgroup, ad.ad,
						SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click
			FROM "ad_meta" AS ad
			LEFT JOIN "ad_mapping3" AS m ON (ad.campaign = m.campaign AND ad.adgroup = m.adgroup AND ad.ad = m.ad)
			LEFT JOIN "YMD2" AS y ON (ad.reg_date = y.yymmdd)
			LEFT JOIN "product" AS p ON (m.product_no = p.no)
			LEFT JOIN "store" AS s ON (m.store_no = s.no)
			LEFT JOIN "channel" AS c ON (m.channel_no = c.no)
			WHERE adcost > 0
			GROUP BY yymm, yyww, yymmdd, c.name, s.name, p.nick, ad.campaign, ad.adgroup, ad.ad
			HAVING p.nick IS null
			Order BY yymm DESC, yyww desc, yymmdd desc, c.name, s.name, p.nick, ad.campaign, ad.adgroup, ad.ad
) AS t


SELECT * FROM "ad_meta"



SELECT * FROM "ad_mapping3" WHERE channel_no = 4
SELECT * FROM "ad_ga_utm" WHERE utm_content LIKE '%서효림%'

-----------------------------------------

데이터마트 > 매출 및 고객 폴더

-----------------------------------------

-- 이지어드민 주문수집 여부 확인
SELECT order_date, *
FROM "EZ_Order"
Order BY order_date desc
LIMIT 10000


-- 네이버 주문수집 여부 확인
SELECT 	"paymentDate", *
FROM 		"naver_order_product" AS n
LEFT JOIN "naver_option" AS o ON (n."optionCode" = o."option_code")
LEFT JOIN "product" AS p ON (o."product_no" = p."no")
WHERE 	"paymentDate" IS NOT NULL 
Order BY "paymentDate" DESC
LIMIT 10000


-- 쿠팡 주문수집 여부 확인
SELECT "orderedAt", *
FROM "coupang_order"
WHERE "orderedAt" IS NOT NULL
Order BY "orderedAt" DESC
LIMIT 10000


--총매출
SELECT yymm, yyww, yymmdd, product_name, store, SUM(price) AS price, SUM(order_cnt) AS order_cnt, SUM(out_qty) AS out_qty
FROM "order4" AS o
LEFT JOIN "YMD2" AS y ON (o.order_date = y.yymmdd)
WHERE yymmdd >= '2020-01-01'
GROUP BY yymm, yyww, yymmdd, product_name, store
Order BY yymmdd DESC



-- 풀필먼트 방어쿼리 (매핑 안된 옵션코드 있는지 확인)
SELECT DISTINCT "optionCode", "productName", "productOption"
FROM "naver_order_product" AS o
LEFT JOIN "naver_option" AS op ON (o."optionCode" = op."option_code")
WHERE op."option_code" IS NULL 
--AND o."deliveryAttributeType" = 'ARRIVAL_GUARANTEE'


-- 쿠팡 방어쿼리 (매핑 안된 옵션코드 있는지 확인)
SELECT DISTINCT p."vendorItemName", p."vendorItemId", op."option"
FROM "coupang_order" AS o,																
		json_to_recordset(o."orderItems") as p(	
			"vendorItemName" CHARACTER varying(255),																									
			"vendorItemId" CHARACTER varying(255)											
		)
LEFT JOIN "coupang_option" AS op ON (p."vendorItemId" = op."option")
WHERE op."option" IS NULL 

																						
SELECT	y.yymm, y.yyww, o.yymmdd, o.product, o.shop_name,																								
		sum(o.gross) as gross, sum(o.order_cnt) as order_cnt, sum(o.out_qty) as out_qty																							
FROM																									
																									
		(																							
			SELECT	o.yymmdd, o.product_name as product,																					
					case o.shop_name when '스토어팜(파이토웨이)' then '스마트스토어' ELSE o.shop_name end as shop_name,																				
					sum(o.prd_amount) as gross, sum(order_cnt) as order_cnt, sum(out_qty) as out_qty																				
			FROM																						
					(																				
						SELECT	o.seq, substring(case when p.order_cs = 0 then o.order_date else																		
												case when p.cancel_date = '' then p.change_date else p.cancel_date end end, 1, 10) as yymmdd,													
								o.shop_name,																	
								pp.nick as product_name, b.qty as product_qty, p.qty as order_qty,																	
								case when p.order_cs = 0 then p.prd_amount 
								else p.prd_amount * -1 
								end as prd_amount,																	
								case when p.order_cs = 0 and p.prd_amount > 0 then 1 else -1 end as order_cnt,																	
								case when p.order_cs = 0 then b.qty * p.qty else (b.qty * p.qty) * -1 end as out_qty,
								o.shop_id, o."options", pp.term, order_date, order_name																
						FROM	"EZ_Order" as o,																		
								jsonb_to_recordset(o.order_products) as p(																	
									name character varying(255),																
									product_id character varying(255),																
									qty integer, prd_amount integer,																
									order_cs integer,																
									cancel_date character varying(255),																
									change_date character varying(255)																
								)																	
								left join "bundle" as b on (p.product_id = b.ez_code)																	
								left join "product" as pp on (b.product_no = pp.no)	
																							
						WHERE	order_date > '2021-09-01' --AND shop_name = '롯데홈쇼핑'																		
						and order_date < '2023-12-31'																			
						AND order_id not in (																			
							select order_num from "Non_Order")	
						AND p.prd_amount < 500000 AND pp.term > 0 AND o.order_name <> '' and p.prd_amount > 0																					
					) as o	
			LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)	
			WHERE 
				(
					s.deal_type = 'B2C' AND "options" NOT LIKE '%메디%'
				)
			OR 
				(
					o."options" LIKE '%메디%' AND order_date < '2022-08-23'
				)															
			GROUP BY o.yymmdd, o.product_name, o.shop_name																						
																									
			UNION																						
																									
			select	o.order_date as yymmdd, p.nick as product,																					
					case o.shop_name when '스토어팜(파이토웨이)' then '스마트스토어' ELSE o.shop_name end as shop_name,																				
					sum(order_price) as gross, count(*) as order_cnt, sum(o.order_qty*b.qty) as out_qty																				
			FROM	"PA_Order2" as o left join "Bundle" as b on (o.order_code = b.order_code)																					
					left join "product" as p on (b.product_id = p.no)																				
			--where o.order_date >= '2021-01-01'																						
			group by o.order_date, p.nick, o.shop_name																						
		) as o left join																							
		(																							
			SELECT	yymmdd, yymm, yyww																					
			FROM	"YMD2"																					
		) as y on (o.yymmdd = y.yymmdd)																							
GROUP BY y.yymm, y.yyww, o.yymmdd, o.product, o.shop_name																									
ORDER BY o.yymmdd DESC																									
																																															

																			
-- 매출 및 고객 - 일자, 상품, 스토어 시트																					
with purchase_term as (
        select         key, product, shop, order_date, seq,
                        order_qty * product_qty * term * 1.2 as real_term,
                        case when order_qty * product_qty * term * 1.2 > 365 then 365 else order_qty * product_qty * term * 1.2 end as active_term,
                        to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
                                        order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd') as dead_date,
                        price,
                        lag(order_date, +1) over (partition by key order by order_date, order_date_time asc) as prev_order_date,
                        lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
                                        order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), +1) 
                                        over (partition by key order by order_date, order_date_time asc) as prev_dead_date,
                        lag(order_date, -1) over (partition by key order by order_date, order_date_time asc) as next_order_date,
                        lag(to_char(case when order_qty * product_qty * term * 1.2 > 365 then order_date::date + interval '1 day' * 365 else
                                        order_date::date + interval '1 day' * order_qty * product_qty * term * 1.2 end, 'yyyy-mm-dd'), -1) 
                                        over (partition by key order by order_date, order_date_time asc) as next_dead_date,
                        rank() over(partition BY key order by order_date, order_date_time desc) as rank
        from         "customer_zip5"  
        WHERE price < 500000
)

select        yymm, yyww, yymmdd, product, shop, 
                sum(dead_price) as dead_price, sum(reorder_price) as reorder_price, sum(chunk_price) as chunk_price, 
                sum(order_price) as order_price, sum(new_price) as new_price,
                sum(sustain_price) as sustain_price, 
                sum(sustain_price_w1) as sustain_price_w1, sum(sustain_price_w2) as sustain_price_w2, sum(sustain_price_w3) as sustain_price_w3, sum(sustain_price_w4) as sustain_price_w4, sum(sustain_price_w5) as sustain_price_w5,
                sum(return_price) as return_price, 
                sum(return_price_w1) as return_price_w1, sum(return_price_w2) as return_price_w2, sum(return_price_w3) as return_price_w3, sum(return_price_w4) as return_price_w4, sum(return_price_w5) as return_price_w5,
                avg(active_term) as active_term, sum(dead_cnt) as dead_cnt, sum(reorder_cnt) as reorder_cnt, sum(chunk_cnt) as chunk_cnt, 
                sum(order_cnt) as order_cnt, sum(new_cnt) as new_cnt,
                sum(sustain_cnt) as sustain_cnt, sum(sustain_cnt_w1) as sustain_cnt_w1, sum(sustain_cnt_w2) as sustain_cnt_w2, sum(sustain_cnt_w3) as sustain_cnt_w3, sum(sustain_cnt_w4) as sustain_cnt_w4, sum(sustain_cnt_w5) as sustain_cnt_w5,
                sum(return_cnt) as return_cnt, sum(return_cnt_w1) as return_cnt_w1, sum(return_cnt_w2) as return_cnt_w2, sum(return_cnt_w3) as return_cnt_w3, sum(return_cnt_w4) as return_cnt_w4, sum(return_cnt_w5) as return_cnt_w5,
                sum(remain_cnt) as reamin_cnt, sum(out_cnt) as out_cnt
from        (
                        select        yymm, yyww, yymmdd, product, shop,
                                        case when yymmdd = dead_date then price else 0 end as dead_price, -- 만료
                                        case when yymmdd = dead_date and next_order_date between order_date and dead_date then price else 0 end as reorder_price, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
                                        case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then price else 0 end as chunk_price, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
                                        case when yymmdd = order_date then price else 0 end as order_price, -- 매출
                                        case when yymmdd = order_date and prev_order_date is null then price else 0 end as new_price, -- 신규매출
                                        case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then price else 0 end as sustain_price, --유지매출
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then price else 0 end as sustain_price_w1, --(W-1)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then price else 0 end as sustain_price_w2, --(W-2)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then price else 0 end as sustain_price_w3, --(W-3)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then price else 0 end as sustain_price_w4, --(W-4)
                                        case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then price else 0 end as sustain_price_w5, --(W<-4)
                                        case when yymmdd = order_date and order_date > prev_dead_date then price else 0 end as return_price, --복귀매출
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then price else 0 end as return_price_w1, --(W+1)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then price else 0 end as return_price_w2, --(W+2)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then price else 0 end as return_price_w3, --(W+3)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then price else 0 end as return_price_w4, --(W+4)
                                        case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then price else 0 end as return_price_w5, --(W>+4)
                                        case when yymmdd = order_date then active_term else null end as active_term,
                                        case when yymmdd = dead_date then 1 else 0 end as dead_cnt, -- 만료주문건수
                                        case when yymmdd = dead_date and next_order_date between order_date and dead_date then 1 else 0 end as reorder_cnt, -- 해당일이 종료일이고 다음주문이 주문일과 종료일 사이에 있는 경우 유지
                                        case when yymmdd = dead_date and (next_order_date is null or dead_date < next_order_date) then 1 else 0 end as chunk_cnt, -- 해당일이 종료일이고 다음주문이 없거나 종료일보다 큰경우 이탈
                                        case when yymmdd = order_date then 1 else 0 end as order_cnt, -- 주문건수
                                        case when yymmdd = order_date and prev_order_date is null then 1 else 0 end as new_cnt, -- 신규
                                        case when yymmdd = order_date and order_date between prev_order_date and prev_dead_date then 1 else 0 end as sustain_cnt, --유지
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and prev_dead_date then 1 else 0 end as sustain_cnt_w1, --(W-1)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -13, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -7, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w2, --(W-2)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -20, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -14, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w3, --(W-3)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * -21, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w4, --(W-4)
                                        case when yymmdd = order_date and order_date < to_char(prev_dead_date::date + interval '1 day' * -27, 'yyyy-mm-dd') then 1 else 0 end as sustain_cnt_w5, --(W<-4)
                                        case when yymmdd = order_date and order_date > prev_dead_date then 1 else 0 end as return_cnt, --복귀
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w1, --(W+1)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 8, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 14, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w2, --(W+2)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 15, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 21, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w3, --(W+3)
                                        case when yymmdd = order_date and order_date between to_char(prev_dead_date::date + interval '1 day' * 22, 'yyyy-mm-dd') and to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd') then 1 else 0 end as return_cnt_w4, --(W+4)
                                        case when yymmdd = order_date and order_date > to_char(prev_dead_date::date + interval '1 day' * 28, 'yyyy-mm-dd')  then 1 else 0 end as return_cnt_w5, --(W>+4)
                                        case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * -6, 'yyyy-mm-dd') and dead_date then 1 else 0 end as remain_cnt, -- 잔존고객
                                        case when EXTRACT(ISODOW FROM yymmdd::date) = 2 and yymmdd between to_char(dead_date::date + interval '1 day' * 1, 'yyyy-mm-dd') and to_char(dead_date::date + interval '1 day' * 7, 'yyyy-mm-dd') then 1 else 0 end as out_cnt -- 이탈고객(W+1)
                        from        purchase_term as t cross join "YMD2" as y 
                )as t
WHERE  yymmdd = '2023-05-02'
group BY yymm, yyww, yymmdd, product, shop
order by yymmdd DESC


SELECT *
FROM "customer_zip5"
WHERE order_date BETWEEN '2023-04-12' AND '2023-04-13'
AND (shop = '스마트스토어' OR shop = '쿠팡')
	
-- B2B 매출		
-- 로켓배송 : 과거 : 주문일(b2b_gross), 신규 : 출고일(이지어드민)
-- 제트배송 : 계속 : 주문일(b2b_gross)
-- 마켓컬리 : 과거 : 출고일(b2b_gross), 신규 : 출고일(이지어드민, 넣어야 함, 넣기로 했음)
-- 메디크로스랩 : 과거 : 출고일(b2b_gross), 신규 : 출고일(이지어드민, 넣어야 함, 넣기로 했음)
-- 온유약국 : 과거 : 출고일(b2b_gross), 신규 : 출고일(이지어드민, 넣어야 함, 해결 필요)		

SELECT *
FROM 	(
			SELECT yymm, yyww, yymmdd, s.name AS store, p.nick, SUM(gross) AS gross, COUNT(*) AS order_cnt
			FROM "b2b_gross" AS b
			LEFT JOIN "store" AS s ON (b.store_no = s.no)
			LEFT JOIN "product" AS p ON (b.product_no = p.no)
			LEFT JOIN "YMD2" AS y ON (b.order_date = y.yymmdd)
			GROUP BY yymm, yyww, yymmdd, s.name, p.nick
			
			UNION ALL 	
			
			SELECT y.yymm, y.yyww, y.yymmdd, store, nick, sum(amount) AS gross, COUNT(*) AS order_cnt
			FROM 	(
						SELECT 	"substring"((o.order_date)::text, 1, 10) AS order_date,
									CASE WHEN o."options" LIKE '%메디%' THEN '메디크로스랩'
									WHEN o."options" LIKE '%온유%' THEN '온유약국'
									ELSE s.name
									END AS store,
									o.nick,
									o.amount
						FROM 	(
									SELECT *, p.qty AS order_qty, b.qty AS product_qty
									FROM "EZ_Order" AS o,
										(
											LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
											LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::TEXT)))
											LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
										)
									WHERE pp.term > 0
								) AS o
						LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
						WHERE 
								(
										(
											o.shop_id IN (10087, 10286, 10387) 
										)
									OR
										(
											o."options" LIKE '%메디%' AND order_date >= '2022-08-23'  
										)
									OR 
										(
											o."options" LIKE '%온유%'
										)
								) AND 
								o.order_date > '2019-01-01' AND o.order_date < '2024-01-01' 
								AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")									
					) AS t
			LEFT JOIN "YMD2" AS y ON (t.order_date = y.yymmdd)
			GROUP BY y.yymm, y.yyww, y.yymmdd, store, nick
		) AS t
Order BY yymmdd desc, store, nick


SELECT * FROM "b2b_gross"
WHERE store_no = 25 AND product_no = 1 AND qty = 1
Order BY order_date


SELECT * --o.order_date, nick, prd_amount
FROM "EZ_Order" AS o,
				(
					LATERAL jsonb_to_recordset(o.order_products) p(product_id character varying(255), qty integer, prd_amount INTEGER)
					LEFT JOIN "bundle" as b ON (((p.product_id)::text = (b.ez_code)::text)))
					LEFT JOIN "product" as pp ON ((b.product_no = pp.no)
				)
WHERE o.order_date >= '2023-04-12 14:00:00' AND o.order_date <= '2023-04-13 14:00:00' --AND pp.term > 0 AND o.order_name <> '' and p.prd_amount > 0
		AND o.order_id NOT IN ( SELECT "Non_Order".order_num FROM "Non_Order")	
		--AND o.order_id = '16000176640259'		
		AND shop_name IN ('스토어팜(파이토웨이)', '쿠팡')	
Order BY o.order_date DESC

LIMIT 10000

4월 12일 오후 2시 주문건 ~ 4월 13일 오후 2시 주문건
--WHERE order_id = '6000176902824'

SELECT JSONB_AGG(
  CASE WHEN idx = 0 THEN
    JSONB_SET(value, '{prd_amount}', to_jsonb((value->>'prd_amount')::numeric +
      (SELECT COALESCE(SUM((value2->>'prd_amount')::numeric), 0)
       FROM jsonb_array_elements("EZ_Order".order_products) WITH ORDINALITY el2(value2, idx2)
       WHERE idx2 > 0))
    )
  ELSE
    JSONB_SET(value, '{prd_amount}', '0')
  END
  ORDER BY idx
)
FROM "EZ_Order", jsonb_array_elements("EZ_Order".order_products) WITH ORDINALITY el(value, idx);
WHERE order_date >= '2023-04-12 14:00:00' AND order_date <= '2023-04-13 14:00:00'
AND shop_name IN ('스토어팜(파이토웨이)', '쿠팡')	




SELECT * --shop_name, product_name, "options", amount, order_products
FROM "EZ_Order"
WHERE order_date >= '2023-04-12 14:00:00' AND order_date <= '2023-04-13 14:00:00'
AND shop_name IN ('스토어팜(파이토웨이)', '쿠팡')	
AND (order_products ->> qty) = '2'

Order BY shop_name, order_products


AND ("order_products" ->> "prd_amount") > 0


order_products -> 1 ->> "prd_amount" > 0

"EZ_Order".order_products

WHERE "options" LIKE '%메디%' AND order_date >= '2022-08-23'  



-- 리셀러(50만원 이상 매출)
SELECT y.yymm, y.yyww, y.yymmdd, c.shop, c.brand, c.product, SUM(price) AS price, COUNT(*) AS order_cnt, SUM(order_qty * product_qty) AS out_qty
FROM "customer_zip5" AS c
LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
WHERE price >= 500000
GROUP BY y.yymm, y.yyww, y.yymmdd, c.shop, c.brand, c.product
Order BY y.yymmdd desc


-----------------------------------------

데이터마트 > 광고 폴더

-----------------------------------------

-- 광고 통합 시트
SELECT 	*, 
			CASE WHEN (Channel = '메타' OR Channel = '구글') AND yymmdd <= '2023-02-09' THEN adcost * 1.1
			ELSE adcost
			END AS adcost_markup
FROM 	(
			SELECT  	yymm, yyww, yymmdd, channel, store, Product, owned_keyword_type, 
			      	SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click, SUM("order") AS "order", SUM(price) AS price
			FROM "ad_view6"
			WHERE yymmdd >= '2022-10-01'
			GROUP BY yymm, yyww, yymmdd, channel, store, Product, owned_keyword_type
		) AS t
Order BY yymmdd desc, channel, store, Product, owned_keyword_type


SELECT SUM(adcost)
FROM "ad_view6"
WHERE yymm = '2022-11'



-- 네이버 - 검색채널 시트
SELECT         y.yymm, y.yyww, y.yymmdd, "D" AS "키워드", 
                        SUM("E") AS "고객수", SUM("F") AS "유입수", SUM("G") AS "페이지수", SUM("I") AS "결제수", SUM("K") AS "매출"
FROM                 "Naver_Search_Channel" AS n 
LEFT JOIN "YMD2" AS y ON (n.yymmdd = y.yymmdd)
WHERE n.yymmdd > '2022-09-30'
GROUP BY y.yymm, y.yyww, y.yymmdd, "D"
Order BY y.yymmdd desc


-- 네이버 - 브랜드검색 시트
SELECT t.yymm, t.yyww, t.reg_date AS yymmdd, t.channel_name AS channel, t.store_name AS store,
        CASE
            WHEN (t.brand IS NULL) THEN '파이토웨이'::character varying
            ELSE t.brand
        END AS brand,
        CASE
            WHEN (t.nick IS NULL) THEN '파이토웨이'::character varying
            ELSE t.nick
        END AS product,
    	t.owned_keyword_type, t.keyword,
    	sum(t.ad_cost) AS adcost, sum(t.imp_cnt) AS impression, sum(t.click_cnt) AS click, sum(t.order_cnt) AS "order", sum(t.order_price) AS price
FROM ( 
			SELECT 	y.yymm, y.yyww, ad.reg_date, ad.brand, ad.nick,
          		  	'스마트스토어'::text AS store_name,
            		'네이버'::text AS channel_name,
           			ad.keyword, ad.owner_brand_type AS owned_keyword_type,
            		ad.imp_cnt, ad.click_cnt,
	                CASE
	                    WHEN (ad.order_cnt = 0) THEN ns.order_cnt
	                    ELSE ad.order_cnt
	                END AS order_cnt,
	                CASE
	                    WHEN (ad.order_price = 0) THEN ns.order_price
	                    ELSE ad.order_price
	                END AS order_price,
          		  ad.ad_cost
         FROM ((( 
							SELECT 	ad_1.reg_date, pp.brand, pp.nick, s.name AS store_name,
                        	CASE
                           	 WHEN ((p.owned_keyword)::text = '자상호'::text) THEN '자상호'::text
                            	ELSE '비자상호'::text
                        	END AS owner_brand_type,
                    			ad_1."F" AS Keyword, sum(ad_1."L") AS imp_cnt, sum(ad_1."M") AS click_cnt, sum(ad_1."Q") AS order_cnt, sum(ad_1."U") AS order_price, sum(ad_1."P") AS ad_cost
                   	FROM ((("AD_Naver" ad_1
                  	LEFT JOIN ad_mapping3 p ON ((((ad_1."B")::text = (p.campaign)::text) AND ((ad_1."D")::text = (p.adgroup)::text))))
                     LEFT JOIN product pp ON ((p.product_no = pp.no)))
                     LEFT JOIN store s ON ((p.store_no = s.no)))
                     WHERE "E" LIKE '%브랜드검색%'
                  	GROUP BY ad_1.reg_date, s.name, pp.brand, pp.nick, p.owned_keyword, ad_1."F") as ad
         LEFT JOIN ( 
							SELECT	t_1.yymmdd,
                 				 	t_1.arr[1] AS keyword,
                    				sum(t_1."I") AS order_cnt,
                    				sum(t_1."K") AS order_price
                 		FROM ( 
							  			SELECT string_to_array(("Naver_Search_Channel"."D")::text, '_'::text) AS arr, *
                         		FROM "Naver_Search_Channel"
                          		WHERE (("Naver_Search_Channel"."B")::text ~~ '%광고%'::TEXT) AND "C" LIKE '%브랜드검색%') t_1
                  	GROUP BY t_1.yymmdd, t_1.arr[1]) ns ON ((((ad.reg_date)::text = (ns.yymmdd)::text) AND ((ad.keyword)::text = ns.keyword))))
         LEFT JOIN "YMD2" y ON (((ad.reg_date)::text = (y.yymmdd)::text)))
      	WHERE (((ad.reg_date)::text > '2022-08-31'::text))) t
GROUP BY t.yymm, t.yyww, t.reg_date, t.channel_name, t.store_name, t.brand, t.nick, t.owned_keyword_type, t.keyword
Order BY t.reg_date desc



-- 메타 4차
SELECT yymm, yy.yyww, yy.yymmdd, yy.campaign, yy.ad_mod, ad.adcost, ad.impression, ad.click, ga."order", ga.gross, ad_account
FROM 	(
			SELECT *
			FROM "YMD2" AS y
			CROSS JOIN (
			SELECT DISTINCT 	campaign, ad, ad_account,
								CASE WHEN adgroup LIKE '%리타겟%' AND ad NOT LIKE '%리타겟%' THEN ad || '_리타겟'
								ELSE ad
								END AS ad_mod,
									utm_campaign, utm_content, channel_no, product_no, store_no FROM "ad_mapping3" WHERE channel_no = 4
			) AS t
		) AS yy
LEFT JOIN (
				SELECT 	reg_date, campaign, ad_mod, 
							SUM(adcost) AS adcost, SUM(impression) AS impression, SUM(click) AS click
				FROM 	(
							SELECT 	*,
										CASE WHEN adgroup LIKE '%리타겟%' AND ad NOT LIKE '%리타겟%' THEN ad || '_리타겟'
										ELSE ad
										END AS ad_mod
							FROM "ad_meta"
						) AS t
				GROUP BY reg_date, campaign, ad_mod, ad_account
			) AS ad ON (yy.yymmdd = ad.reg_date AND yy.campaign = ad.campaign AND yy.ad_mod = ad.ad_mod)
LEFT JOIN (
				SELECT reg_date, utm_campaign, utm_content,
						SUM("order") AS "order", SUM(gross) AS gross
				FROM "ad_ga_utm"
				GROUP BY reg_date, utm_campaign, utm_content
			) AS ga ON (yy.yymmdd = ga.reg_date AND yy.utm_campaign = ga.utm_campaign AND yy.utm_content = ga.utm_content)
LEFT JOIN "product" AS p ON (yy.product_no = p.no)
LEFT JOIN "store" AS s ON (yy.store_no = s.no)
LEFT JOIN "channel" AS c ON (yy.channel_no = c.no)
WHERE ad.campaign IS NOT NULL OR ga.utm_campaign IS NOT null
Order BY yymmdd DESC, yy.campaign, yy.ad_mod


-- 쿠팡 계정 분리
SELECT *
FROM 	(
			 SELECT y.yymm, y.yyww, y.yymmdd, '쿠팡' AS Channel, '쿠팡' AS store, p.brand, p.nick, c.account, '상품광고' AS "ad_type",
			        CASE
			            WHEN (((c.campaign)::text ~~ '%자상호%'::text) AND ((c.keyword)::text <> ''::text)) THEN '자상호'::text
			            WHEN c.keyword LIKE concat('%', p.brand, '%') THEN '자상호'
			            ELSE '비자상호'::text
			        END AS owned_keyword_type,
			    c.keyword,
			    sum(c.adcost) AS adcost,
			    sum(c.impressions) AS impression,
			    sum(c.clicks) AS click,
			    sum(c.order_cnt) AS "order",
			    sum(c.gross) AS price
			  
			   FROM "AD_Coupang" AS c
			   LEFT JOIN "ad_mapping3" AS m ON (m.product2_id::text = c.product2_id::text)
			   LEFT JOIN "product" AS p ON (m.product_no = p.no)
			   LEFT JOIN "YMD2" y ON (y.yymmdd::text = c.reg_date::text)
			  	WHERE y.yymmdd::text > '2022-09-30'::TEXT --and
			  	
			  	GROUP BY y.yymm, y.yyww, y.yymmdd, p.brand, p.nick, c.account, c.campaign, c.keyword, c.product2_id
			
			
			UNION ALL
			 SELECT y.yymm,
			    y.yyww,
			    y.yymmdd,
			    '쿠팡'::text AS channel,
			    '쿠팡'::text AS store,
			    		CASE
			            WHEN ((cb.product2_id)::text <> '0'::text) THEN p.brand
			            ELSE '파이토웨이'::character varying
			        END AS brand,
			        CASE
			            WHEN ((cb.product2_id)::text <> '0'::text) THEN p.nick
			            ELSE '파이토웨이'::character varying
			        END AS product,
			        cb.account, '브랜드광고' AS "ad_type",
			        CASE
			            WHEN cb.ad_group::text ~~ '%자상호%'::text THEN '자상호'::text
			            ELSE '비자상호'::text
			        END AS owned_keyword_type,
			    cb.impression_keyword AS keyword,
			    sum(cb.adcost) AS adcost,
			    sum(cb.impressions) AS impression,
			    sum(cb.clicks) AS click,
			    sum(cb.order_cnt) AS "order",
			    sum(cb.gross) AS price
			   FROM "AD_CoupangBrand" AS cb         
			   LEFT JOIN "ad_mapping3" AS  m ON (m.product2_id::text = cb.product2_id::text)
			   LEFT JOIN "product" AS p ON (m.product_no = p.no)
			   LEFT JOIN "YMD2" y ON (cb.reg_date::text = y.yymmdd::text)
			  	WHERE ((cb.reg_date)::text <> ''::text)
			  	GROUP BY y.yyww, y.yymm, y.yymmdd, cb.product2_id, p.brand, p.nick, cb.account, cb.campaign, cb.ad_group, cb.impression_keyword
		) AS t
WHERE yymmdd >= '2023-02-01'
Order BY yymmdd DESC, account, ad_type desc, owned_keyword_type desc, Keyword desc


-----------------------------------------

데이터마트 > 컨텐츠 폴더

-----------------------------------------

-- 컨텐츠 통합 시트 > 컨텐츠id별 탭
-- 날짜 오늘로 수정
SELECT *
FROM "content_view3"
WHERE (yymmdd between '2023-01-01' AND '2023-05-02') AND page_type IN ('블로그', '지식인', '카페', '유튜브') AND Channel IN ('네이버', '구글')
Order BY yymmdd DESC, Channel, brand, nick, page_type, id DESC, Keyword, owned_keyword_type


-- 컨텐츠 통합 시트 > 자상호여부별 탭
SELECT 	yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type, --Keyword, id,
			SUM(cost1) AS cost1, sum(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
FROM "content_view3"
WHERE (yymmdd between '2022-10-01' AND '2023-05-10') AND page_type IN ('블로그', '지식인', '카페', '유튜브') AND Channel IN ('네이버', '구글')
GROUP BY yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type--, Keyword, id
Order BY yymm desc, yyww desc, yymmdd DESC, Channel, brand, nick, page_type, owned_keyword_type--, keyword



-- 사용자정의채널
SELECT	y.yyww,y.yymm,y.yymmdd, nt_detail,		
		case when nt_detail = 'omega3kang' then '고객연구소' else channel end as channel,	
		page_type, nt_keyword,	
		sum(customer_cnt) as customer_cnt, sum(inflow_cnt) as inflow_cnt, sum(page_cnt) as page_cnt,	
		sum(order_cnt) as order_cnt, sum(order_price) as order_price	
from "Naver_Custom_Order" as o left join "Page" as p on o.nt_detail = p.id::varchar(100)			
LEFT JOIN "YMD2" AS y ON (o.yymmdd = y.yymmdd)			
WHERE y.yymmdd > '2022-06-20' --and order_price > 0			
group by y.yyww,y.yymm,y.yymmdd, nt_detail,channel, page_type, nt_keyword			
order BY y.yymmdd desc, order_price DESC			
		

--블로그 자상호 조회수, 클릭수
SELECT y.yymm, y.yyww, y.yymmdd, t.nick, t.keyword,
                 SUM(t.pv) AS pv, SUM(t.cc) AS cc, SUM(t.cc2) AS cc2
FROM         (
                        select        to_char(pl."createdAt", 'YYYY-MM-DD') AS ymd, p.id, p.product_id,
                                                pp.nick,        p.keyword, p.channel, p.page_type, p.page_title, p.page_url,                                                                
                                                sum(case when pl.action_type = 'Page' then 1 else 0 end) as pv,                                                        
                                                sum(case when pl.action_type = 'Click' then 1 else 0 end) as cc,                                                        
                                                sum(case when pl.action_type = 'Click2' then 1 else 0 end) as cc2                        
                        FROM    "Page" p 
                        left join "Product" pp on (p.product_id = pp.id)                                                                        
                        left join (                                                        
                                                        select        min("createdAt") as "createdAt", to_char("createdAt", 'YYYY-MM-DD'), page_id, product_id, action_type, header_agent, header_referer                                        
                                                        FROM        "Page_Log"                                        
                                                        group by to_char("createdAt", 'YYYY-MM-DD'), page_id, product_id, action_type, header_agent, header_referer                                                
                                                ) pl on (p.id = pl.page_id)                                                        
                        where        to_char(pl."createdAt", 'YYYY-MM-DD') is not NULL 
                        AND p.channel = '네이버' AND p.page_type = '블로그' 
								AND (p.Keyword LIKE '%판토모나%' OR p.Keyword LIKE '%큐시%' OR p.Keyword LIKE '%싸이토팜%' OR p.Keyword LIKE '%페미론큐%' OR p.Keyword LIKE '%루테콤%' OR p.Keyword LIKE '%트리플%')
                        group by to_char(pl."createdAt", 'YYYY-MM-DD'), p.id, p.product_id, pp.nick, p.channel, p.page_type, p.page_title, p.page_url                                                                        
                        order by to_char(pl."createdAt", 'YYYY-MM-DD') desc, p.id DESC        
                ) AS t
LEFT JOIN "YMD2" AS Y ON (t.ymd = y.yymmdd)
GROUP BY y.yymm, y.yyww, y.yymmdd, t.nick, t.keyword
Order BY y.yymm DESC , y.yyww desc, y.yymmdd desc, t.nick, t.keyword


SELECT *
FROM "Naver_Custom_Order"


-- 유튜브 클릭수
SELECT         y.yymm, y.yyww, y.yymmdd, nt_source, nt_medium, nt_keyword,
                        SUM(customer_cnt) AS "고객수", SUM(inflow_cnt) AS "유입수", SUM(page_cnt) AS "페이지수", SUM(order_cnt) AS "결제수", SUM(order_price) AS "결제금액",
                        SUM(contribute_cnt) AS "결제수(14일)", SUM(contribute_price) AS "결제금액(14일)"
FROM                 "Naver_Custom_Order" AS n 
LEFT JOIN "YMD2" AS y ON (n.yymmdd = y.yymmdd)
WHERE         nt_source = 'youtube'
GROUP BY y.yymm, y.yyww, y.yymmdd, nt_source, nt_medium, nt_keyword
Order BY yymmdd DESC



-----------------------------------------

데이터마트 > 콜링 폴더

-----------------------------------------

-- 콜링 시트 > 콜링1 탭
SELECT	y.yymm, y.yyww, y.yymmdd,	
		case when p.nick is null then '파이토웨이' else p.nick end as Product,
		sum(q.mobile_cnt) as mobile_cnt, sum(q.pc_cnt) as pc_cnt, sum(q.mobile_cnt+q.pc_cnt) as sum
FROM 	"Query_Log" as q 
LEFT JOIN "Keyword" as k on (q.keyword = k.keyword)	
LEFT JOIN "product" as p on (k.product_id = p.no)
LEFT JOIN "YMD2" as y on (q.query_date = y.yymmdd)
GROUP BY y.yymm, y.yyww, y.yymmdd, product		
ORDER BY yymmdd desc, product DESC		


-- 콜링 > 콜링2 > 제품별
SELECT	y.yymm, y.yyww, y.yymmdd,			
		CASE WHEN p.nick is null then '파이토웨이' 
		ELSE p.nick 
		END AS Product,		
		sum(q.mobile_cnt) as mobile_cnt, sum(q.pc_cnt) as pc_cnt, sum(q.mobile_cnt+q.pc_cnt) as sum		
FROM	"Query_Log2" as q 
LEFT JOIN "Keyword2" as k on (q.keyword = k.keyword)			
LEFT JOIN "product" as p on (k.product_id = p.no)		
LEFT JOIN "YMD2" as y on (q.query_date = y.yymmdd)		
GROUP BY y.yymm, y.yyww, y.yymmdd, product				
ORDER BY yymmdd desc, product DESC				
	

-- 콜링 > 콜링2 > 판토모나 브랜드		
SELECT	y.yymm, y.yyww, y.yymmdd, brand,		
		sum(q.mobile_cnt) as mobile_cnt, sum(q.pc_cnt) as pc_cnt, sum(q.mobile_cnt+q.pc_cnt) as sum		
FROM	"Query_Log2" as q 
LEFT JOIN "Keyword2" as k on (q.keyword = k.keyword)	
LEFT JOIN "product" as p on (k.product_id = p.no)	
LEFT JOIN "YMD2" as y on (q.query_date = y.yymmdd)	
WHERE brand = '판토모나'	
GROUP BY y.yymm, y.yyww, y.yymmdd, brand				
ORDER BY yymmdd desc, brand DESC	


-- 콜링 > 콜링2 > 페미론큐 브랜드		
SELECT	y.yymm, y.yyww, y.yymmdd, brand,		
		sum(q.mobile_cnt) as mobile_cnt, sum(q.pc_cnt) as pc_cnt, sum(q.mobile_cnt+q.pc_cnt) as sum		
FROM	"Query_Log2" as q 
LEFT JOIN "Keyword2" as k on (q.keyword = k.keyword)	
LEFT JOIN "product" as p on (k.product_id = p.no)	
LEFT JOIN "YMD2" as y on (q.query_date = y.yymmdd)	
WHERE brand = '페미론큐'	
GROUP BY y.yymm, y.yyww, y.yymmdd, brand				
ORDER BY yymmdd desc, brand DESC	




-- 구글 SA / DA 시트
SELECT 	*,
			CASE WHEN yymmdd <= '2023-02-09' THEN adcost * 1.1
			ELSE adcost
			END AS adcost_markup
FROM 	(
		 SELECT t.yymm,
		    t.yyww,
		    t.yymmdd,
		    t.channel,
		    t.store,
		    --t.brand,
		    t.nick AS product,
		    t.campaign_type, 
		        CASE
		            WHEN ((t.owned_keyword)::text = '자상호'::text) THEN t.owned_keyword
		            ELSE '비자상호'::character varying
		        END AS owned_keyword_type,
			 t.campaign, t.adgroup, 
		    --'-'::character varying AS keyword,
		    sum(t.adcost) AS adcost,
		    sum(t.impression) AS impression,
		    sum(t.click) AS click,
		    sum(t.order_cnt) AS "order",
		    sum(t.gross) AS price
		   FROM ( SELECT yy.yymm,
		            yy.yyww,
		            yy.yymmdd,
		            c.name AS channel,
		            s.name AS store,
		           		 CASE
		                    WHEN (p.brand IS NOT NULL) THEN p.brand
		                    ELSE '파이토웨이'::character varying
		                END AS brand,
		                CASE
		                    WHEN (p.nick IS NOT NULL) THEN p.nick
		                    ELSE '파이토웨이'::character varying
		                END AS nick,
		            yy.campaign_type,
		            yy.campaign,
		            yy.adgroup,
		            g.adcost,
		            g.impression,
		            g.click,
		            aw.order_cnt,
		            aw.gross,
		            yy.owned_keyword
		           FROM (((((( SELECT "YMD2".yymmdd,
		                    "YMD2".yymm,
		                    "YMD2".yyww,
		                    "YMD2".yyww_int,
		                    y.campaign_type,
		                    y.campaign,
		                    y.adgroup,
		                    y.adgroup_id,
		                    y.channel_no,
		                    y.store_no,
		                    y.product_no,
		                    y.owned_keyword
		                   FROM ("YMD2"
		                     CROSS JOIN ( SELECT DISTINCT ad_mapping3.campaign_type,
		                            ad_mapping3.campaign,
		                            ad_mapping3.adgroup,
		                            ad_mapping3.adgroup_id,
		                            ad_mapping3.channel_no,
		                            ad_mapping3.store_no,
		                            ad_mapping3.product_no,
		                            ad_mapping3.owned_keyword
		                           FROM ad_mapping3
		                          WHERE (ad_mapping3.channel_no = 2)) y)) yy
		             LEFT JOIN ( SELECT ad_google3.reg_date,
		                        CASE
		                            WHEN ((ad_google3.adgroup)::text <> ''::text) THEN ad_google3.adgroup
		                            ELSE '0'::character varying
		                        END AS adgroup,
		                        CASE
		                            WHEN ((ad_google3.adgroup_id)::text <> ''::text) THEN ad_google3.adgroup_id
		                            ELSE '0'::character varying
		                        END AS adgroup_id,
		                    max((ad_google3.campaign_type)::text) AS campaign_type,
		                    sum(ad_google3.adcost) AS adcost,
		                    sum(ad_google3.impression) AS impression,
		                    sum(ad_google3.click) AS click
		                   FROM ad_google3
		                  GROUP BY ad_google3.reg_date, ad_google3.adgroup, ad_google3.adgroup_id) g ON ((((yy.yymmdd)::text = (g.reg_date)::text) AND ((yy.adgroup)::text = (g.adgroup)::text) AND ((yy.adgroup_id)::text = (g.adgroup_id)::text))))
		             LEFT JOIN ad_ga_aw aw ON ((((yy.yymmdd)::text = (aw.reg_date)::text) AND ((yy.adgroup)::text = (aw.adgroup)::text) AND ((yy.adgroup_id)::text = (aw.adgroup_id)::text))))
		             LEFT JOIN channel c ON ((c.no = yy.channel_no)))
		             LEFT JOIN store s ON ((s.no = yy.store_no)))
		             LEFT JOIN product p ON ((p.no = yy.product_no)))
		          WHERE ((g.adcost IS NOT NULL) OR (aw.gross IS NOT NULL))) t
		  GROUP BY t.yymm, t.yyww, t.yymmdd, t.channel, t.store, t.brand, t.nick, t.campaign_type, t.campaign, t.adgroup, t.owned_keyword
		) AS T
Order BY yymmdd DESC, Product, campaign_type, owned_keyword_type, campaign, adgroup
  

		


-- 일일고객 시트
SELECT         y.yyww, y.yymmdd, c.order_name, c.tel, c.shop, c.product, c.product_qty, c.order_qty, c.rank
FROM         (
                  SELECT *, rank() over(partition BY key order by order_date, seq asc) as rank
                  FROM "customer_zip3"
                ) AS c
LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
WHERE         yyww = '2023-09'
Order BY c.order_date DESC, c.rank
									
					
					

-- 기타 비용 (마케팅 비용에서 컨텐츠 비용이 아닌 것)
SELECT 	yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type, --Keyword, id,
			SUM(cost1) AS cost1, sum(cost2) AS cost2
FROM "content_view3"
WHERE yymmdd >= '2022-10-01' AND page_type IN ('광고', '소재제작', '리뷰', '사은품')
GROUP BY yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type--, Keyword, id
Order BY yymm desc, yyww desc, yymmdd DESC, Channel, brand, nick, page_type, owned_keyword_type--, keyword




--네이버 광고 유형별, 2023-02-02
select        y.yymm, y.yyww, y.yymmdd, '네이버' as channel, s.name AS store, pp.brand, 
                        case when pp.nick is null THEN '파이토웨이'
                        else pp.nick END AS nick, "C" AS ad_type,
                        case when p.owned_keyword = '자상호' then '자상호' 
                        else '비자상호' 
                        end as owner_brand_type,
                        "F" as keyword,
                        sum("P") as ad_cost, sum("L") as imp_cnt, sum("M") as click_cnt
from        "AD_Naver" as ad 
left JOIN "ad_mapping3" as p on (ad."B" = p.campaign and ad."D" = p.adgroup)
LEFT JOIN "product" AS pp ON (p.product_no = pp.no)
LEFT JOIN "store" AS s ON (p.store_no = s.no)
LEFT JOIN "YMD2" AS y ON (ad.reg_date = y.yymmdd)
group BY y.yymm, y.yyww, y.yymmdd, s.name, "C", pp.brand, pp.nick, p.owned_keyword, "F"
HAVING y.yyww BETWEEN '2022-49' AND '2023-12'
Order BY y.yymmdd desc



--타겟2
SELECT	t.yymmdd, t.product, o.gross, o.order_cnt, o.out_qty, k.query_sum, t.gross_target, t.gross_prev, t.calling_target, t.calling_prev, t.conv_target, t.conv_prev,									
		t.gross_forecast, t.calling_forecast								
FROM										
		(								
			select	y.yymm, y.yyww, t.yymmdd, product, gross_target, gross_prev, calling_target, calling_prev, conv_target, conv_prev,						
					f.gross2 as gross_forecast, f.calling2 as calling_forecast					
			from "Target" as t left join "YMD2" as y on (t.yymmdd = y.yymmdd) left join (							
			select * from fn_gross_forecast(30)) as f on (t.yymmdd = f.yymmdd2)							
		) as t left join								
		(								
			SELECT	o.order_date as yymmdd, o.product_name as product, sum(o.prd_amount) as gross, sum(order_cnt) as order_cnt, sum(out_qty) as out_qty						
			FROM							
					(					
						SELECT	o.seq, substring(case when p.order_cs = 0 then o.order_date else p.cancel_date end, 1, 10) as order_date,			
								o.shop_name,		
								CASE WHEN pp.nick IN ('루테콤', '트리플마그네슘', '페미론큐', '싸이토팜', '콘디맥스') THEN '자사'		
									WHEN pp.nick IN ('판토모나맨', '판토모나레이디', '판토모나') then '판토모나' else pp.nick END AS product_name,	
								b.qty as product_qty, p.qty as order_qty,		
								case when p.order_cs = 0 then p.prd_amount else p.prd_amount * -1 end as prd_amount,		
								case when p.order_cs = 0 then 1 else -1 end as order_cnt,		
								case when p.order_cs = 0 then b.qty * p.qty else (b.qty * p.qty) * -1 end as out_qty		
						FROM	"EZ_Order" as o,			
								jsonb_to_recordset(o.order_products) as p(		
									name character varying(255),	
									product_id character varying(255),	
									qty integer, prd_amount integer,	
									order_cs integer,	
									cancel_date  character varying(255)	
								)		
								left join "Bundle" as b on (p.product_id = b.order_code)		
								left join "Product" as pp on (b.product_id = pp.id)		
						WHERE	order_date > '2021-09-01' and order_date < '2022-12-31' AND order_id not in (			
							select order_num from "Non_Order")			
					) as o					
			GROUP BY o.order_date, o.product_name							
		) as o on (t.yymmdd = o.yymmdd and t.product = o.product) left join								
		(								
			SELECT	q.query_date as yymmdd,						
					case when p.nick is null then '파이토웨이' else p.nick end as product,					
					sum(q.mobile_cnt) as query_sum					
			FROM	Query_Log2 as q left join "Keyword2" as k on (q.keyword = k.keyword)						
					left join "Product" as p on (k.product_id = p.id)					
			GROUP BY q.query_date, product							
		) as k on (t.yymmdd = k.yymmdd and t.product = k.product)								
ORDER BY t.yymmdd DESC										
					



-- 네이버 광고보고서 요약. 2023-03-08
SELECT 	y.yymm, y.yyww, y.yymmdd, c.name AS channel, s.name AS store, p.nick, a."F" AS keyword,
			sum(a."P") AS ad_cost, sum(a."L") AS imp_cnt, sum(a."M") AS click_cnt, sum(a."Q") AS order_cnt, sum(a."U") AS order_price
FROM 		"AD_Naver" AS a
LEFT JOIN "ad_mapping3" as m ON (a."B" = m.campaign AND a."D" = m.adgroup) 
LEFT JOIN "product" as p ON (m.product_no = p.no)
LEFT JOIN "store" as s ON (m.store_no = s.no)
LEFT JOIN "channel" AS c ON (m.channel_no = c.no)
LEFT JOIN "YMD2" AS y ON (a.reg_date = y.yymmdd) 
WHERE a.reg_date >= '2023-01-01'
GROUP BY y.yymm, y.yyww, y.yymmdd, c.name, s.name, p.nick,  a."F"
Order BY y.yymmdd DESC, store, p.nick, Keyword



-- 리셀러(50만원 이상 매출)
SELECT y.yymm, y.yyww, y.yymmdd, c.shop, c.brand, c.product, SUM(price) AS price, COUNT(*) AS order_cnt
FROM "customer_zip5" AS c
LEFT JOIN "YMD2" AS y ON (c.order_date = y.yymmdd)
WHERE price >= 500000
GROUP BY y.yymm, y.yyww, y.yymmdd, c.shop, c.brand, c.product
Order BY y.yymmdd desc


SELECT * 
FROM "customer_zip5"
LIMIT 100



SELECT * 
FROM "cost_marketing"
Order BY INDEX desc


SELECT * 
FROM "cost_product"
Order BY INDEX DESC


SELECT *
FROM "b2b_gross"
Order BY order_date



-- 이름 + id

WITH cust_key AS (
-- 네이버 주문수집 여부 확인
SELECT 	"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "name_zip", 
			"ordererName" || "ordererTel" AS "name_tel", 
			"ordererTel" AS "tel", 
			"ordererName" || "ordererId" AS "name_id"
			, 
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
WHERE 	"paymentDate" IS NOT NULL 
Order BY "order_date_time" DESC
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
-- 네이버 주문수집 여부 확인
SELECT 	"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "name_zip", 
			"ordererName" || "ordererTel" AS "name_tel", 
			"ordererTel" AS "tel", 
			"ordererName" || "ordererId" AS "name_id"
			, 
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
--WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE'
--Order BY "order_date" DESC
)

SELECT cnt, SUM(cnt)
FROM 	(
			SELECT "name_tel", COUNT(*) AS cnt
			FROM "cust_key"
			GROUP BY "name_tel"
		) AS t
GROUP BY cnt
Order BY cnt






-- 전화번호

WITH cust_key AS (
-- 네이버 주문수집 여부 확인
SELECT 	"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "name_zip", 
			"ordererName" || "ordererTel" AS "name_tel", 
			"ordererTel" AS "tel", 
			"ordererName" || "ordererId" AS "name_id"
			, 
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
--WHERE 	"deliveryAttributeType" = 'ARRIVAL_GUARANTEE'
--Order BY "order_date" DESC
)

SELECT cnt, SUM(cnt)
FROM 	(
			SELECT "tel", COUNT(*) AS cnt
			FROM "cust_key"
			GROUP BY "tel"
		) AS t
GROUP BY cnt
Order BY cnt





-- 이름 + 우편번호

WITH cust_key AS (
-- 네이버 주문수집 여부 확인
SELECT 	"ordererName" || ("shippingAddress" ->> 'zipCode')::text AS "name_zip", 
			"ordererName" || "ordererTel" AS "name_tel", 
			"ordererTel" AS "tel", 
			"ordererName" || "ordererId" AS "name_id"
			, 
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
WHERE 	"paymentDate" IS NOT NULL -- "deliveryAttributeType" = 'ARRIVAL_GUARANTEE'
Order BY "order_date_time" DESC
)

SELECT cnt, SUM(cnt)
FROM 	(
			SELECT "name_zip", COUNT(*) AS cnt
			FROM "cust_key"
			GROUP BY "name_zip"
		) AS t
GROUP BY cnt
Order BY cnt



SELECT "orderId", "ordererName", "ordererTel", ("shippingAddress" ->> 'baseAddress')::TEXT AS recv_address, 
		"ordererId", "paymentDate"
FROM "naver_order_product"
WHERE "ordererTel" NOT LIKE '010%'

141422
1046

SELECT *
FROM "EZ_Order"
WHERE order_mobile IN (


SELECT "ordererTel"
FROM "naver_order_product"
WHERE "ordererTel" NOT LIKE '010%'
)

order_id =
'2022031783418571'

-- 중복 확인
SELECT "option"
FROM "coupang_option"
GROUP BY "option"
HAVING COUNT(*) > 1


-- 누락 확인
SELECT DISTINCT option_id, option_name, sales_type
FROM "coupang_sales" AS s
LEFT JOIN "coupang_option" AS op ON (s.option_id = op."option")
WHERE op."option" IS NULL 


SELECT SUM(net_sales_price), SUM(net_sales_cnt)
FROM "coupang_sales" AS s
LEFT JOIN "coupang_option" AS op ON (s.option_id = op."option")
LEFT JOIN "product" AS p ON (op.product_no = p.no)
WHERE account = 'A00197911' AND s.reg_date BETWEEN '2023-01-01' AND '2023-04-19'  --sales_type = '로켓그로스'

-- 판매통계에서는 구매한 일자와 취소한 일자를 분리해서 보여주고,
-- api에서는 구매 후 취소 되었으면 주문 api로 안보내주는 듯.


-- 근데 부계정도 다운받아야 됨.



SELECT *
FROM "coupang_option"







SELECT * FROM "order_batch"

SELECT * FROM "ad_batch" LIMIT 10000
WHERE Channel IS NULL 

A. 검색_써큐시안_MO, *코큐텐
브랜드형_써큐시안, 01. 오메가3
# 써큐시안(고혈압), MO. 고혈압
/P_03.루테콤

SELECT * FROM "ad_mapping3" WHERE campaign = '브랜드형_써큐시안'

'A. 검색_써큐시안_MO' 


SELECT yymm, yyww, order_date, SUM(prd_amount_mod)
FROM "order_batch" 
GROUP BY yymm, yyww, order_date
Order BY order_date DESC


SELECT yymm, yyww, order_date, store, SUM(prd_amount_mod)
FROM "order_batch" 
GROUP BY yymm, yyww, order_date, store
Order BY order_date DESC, SUM(prd_amount_mod) DESC 




---- 배치 테이블 스케줄링 쿼리문 ----

-- order_batch
DELETE FROM "order_batch"

INSERT INTO "order_batch" (yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type, inflow_path, dead_date, prev_dead_date, next_dead_date, prev_order_date, next_order_date)
SELECT yymm, yyww, order_date, order_date_time, key, order_id, order_status, order_name, cust_id, order_tel, recv_name, recv_tel, recv_zip, recv_address, store, phytoway, brand, nick, product_qty, order_qty, out_qty, order_cnt, prd_amount_mod, prd_supply_price, term, decide_date, all_cust_type, brand_cust_type, inflow_path, dead_date, prev_dead_date, next_dead_date, prev_order_date, next_order_date FROM "order5"


-- ad_batch
DELETE FROM "ad_batch"

INSERT INTO "ad_batch" (yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, cost, imp_cnt, click_cnt, order_cnt, order_price, order_cnt_14, order_price_14, option_id)
SELECT yymm, yyww, yymmdd, channel, store, brand, nick, account, ad_type, campaign_type, imp_area, campaign, adgroup, creative, owned_keyword, keyword, cost, imp_cnt, click_cnt, order_cnt, order_price, order_cnt_14, order_price_14, option_id FROM "ad_view7"


-- content_batch
DELETE FROM "content_batch"

INSERT INTO "content_batch" (yymm, yyww, yymmdd, channel, brand, nick, page_type, id, keyword, owned_keyword_type, cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price)
SELECT yymm, yyww, yymmdd, channel, brand, nick, page_type, id, keyword, owned_keyword_type, cost1, cost2, pv, cc, cc2, inflow_cnt, order_cnt, order_price FROM "content_view3"


SELECT * FROM "ad_batch" WHERE Channel = '네이버' AND nick = '파이토웨이'

SELECT * FROM "ad_batch" WHERE Channel IS NOT NULL AND nick IS null


-- 고객 시트 > 전체 탭																			
select	y.yymm, y.yyww, y.yymmdd, new_cnt,																				
		sum(new_cnt) over (order by t1.order_date asc) as tot_cnt,																			
		cross_cnt, rank, cnt																			
from	(	select	order_date,																		
					case when rank = 1 then count(*) else 0 end as new_cnt,																
					rank, count(*) as cnt																
			from	(																	
						select	key, order_date,														
								rank() over(partition BY key order by key asc, order_date asc) as rank													
						from "customer7"															
					) t																
			group by order_date, rank																		
		) t1 left join (																			
			select	order_date, count(*) as cross_cnt																	
			from	(																	
						select	key, product, order_date, prev_product														
						from	(														
									select	key, product, order_date,											
											lag(product, -1) over (partition by key order by key asc, order_date desc) as prev_product										
									from "customer7"												
								) t													
						where	product <> prev_product														
					) t																
			group by order_date																		
		) t2 on (t1.order_date = t2.order_date) left join																			
		"YMD2" as y on (t1.order_date = y.yymmdd)																			
where t1.order_date < '2024-12-31'																					
order by t1.order_date desc, rank ASC																					
																																										
																																									
-- 고객 시트 > 상품별 탭																				
select	y.yymm, y.yyww, y.yymmdd, product, new_cnt,																				
			sum(new_cnt) over (partition BY product order by t1.order_date ASC, product asc) as tot_cnt, rank, cnt																		
from	(	select	order_date, product,																		
					case when rank = 1 then count(*) else 0 end as new_cnt,																
					rank, count(*) as cnt																
			from	(																	
						select	KEY, product, order_date,														
								rank() over(partition BY key order by key ASC, product asc, order_date asc) as rank													
						from "customer7"															
					) t																
			group by order_date, product, rank																		
		) t1 left join																			
		"YMD2" as y on (t1.order_date = y.yymmdd)																			
where t1.order_date < '2024-12-31' AND Product IS NOT null																					
order by t1.order_date desc, product ASC, rank ASC																					
	


	
--ad_view6 - 쿠팡
SELECT  yymm, yyww, yymmdd, channel, store, Product, owned_keyword_type, "keyword",
                        SUM(adcost) AS "광고비", SUM(impression) AS "노출수", SUM(click) AS "클릭수", SUM("order") AS "구매수", SUM(price) AS "매출"
FROM "ad_view6"
WHERE Channel = '쿠팡' AND yymmdd > '2022-09-30'
GROUP BY yymm, yyww, yymmdd, channel, store, Product, owned_keyword_type, "keyword"
Order BY yymmdd desc, channel, store, Product, owned_keyword_type



SELECT *
FROM "Query_Log2"
WHERE query_date = '45049'