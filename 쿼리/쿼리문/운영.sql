


-- 마케팅 비용은 컨텐츠와 기타로 나뉨.
-- 각각 보고서를 만들면 됨.

-- 컨텐츠부터.


-- 유튜브는 매핑 다시 해야 함
-- id가 아니라 키워드로 매핑해야 해서.


SELECT order_date, store, SUM(prd_amount_mod)
FROM "order_batch"
GROUP BY order_date, store
Order BY order_date desc


SELECT *
FROM "naver_order_product"


SELECT order_date, inflow_path, COUNT(DISTINCT order_id)
FROM "order_batch"
WHERE store = '스마트스토어_풀필먼트'
GROUP BY order_date, inflow_path
Order BY order_date desc




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



SELECT yymm, channel, store, brand, nick, owned_keyword,ad_type,campaign_type,adgroup, SUM(cost)AS cost, SUM(imp_cnt)AS 노출수, SUM(click_cnt) AS 클릭수, SUM(order_cnt) AS 전환수, SUM(order_price) AS 전환매출
FROM "ad_batch"
WHERE brand NOT IN ('기타','자사') AND channel='구글'
GROUP BY yymm, channel, store, brand, nick, owned_keyword,ad_type,campaign_type,adgroup
ORDER BY yymm DESC

select *,
	CASE WHEN (Channel = '메타' OR Channel = '구글') AND yymmdd <= '2023-02-09' THEN cost * 1.1
ELSE cost
END AS cost_markup
FROM "ad_batch"

SELECT * FROM "ad_batch" WHERE channel = '구글'


SELECT yymm, channel, SUM(cost)AS cost
FROM "ad_batch"
WHERE brand = '판토모나'
GROUP BY yymm, channel
ORDER BY yymm DESC

SELECT * 
FROM "ad_batch"
WHERE channel = '구글'


SELECT *
FROM "ad_google3"

SELECT DISTINCT adgroup_id
FROM "ad_mapping3"
WHERE channel_no = 2


SELECT *
FROM "ad_google3" AS g
LEFT JOIN "ad_mapping3" AS m ON (g.adgroup_id = m.adgroup_id)
WHERE g.campaign = '실적 최대화_파이토웨이 셋팅'


