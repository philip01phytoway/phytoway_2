-- 데이터 현황파악


-- 쿼리문 추출과 함께 기초적인 기술통계를 하면 좋겠다.
-- 단지 표만 봐서는 뭐가 어떤지를 모르니까.

-- 매출 현황
-- 일자별
SELECT yymm, yyww, order_date, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date
Order BY order_date DESC
LIMIT 1000

-- 전주 동요일 대비

-- 최근 8주간 동요일 대비



-- 이런 분석조차도 미리 준비된 것들을 실행시키기만 하면 되게끔 만들어야 한다.

-- 월별 sum.
-- 월 목표도 있으니까.

-- 일자, 브랜드별
SELECT yymm, yyww, order_date, brand, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date, brand
Order BY order_date DESC, price desc
LIMIT 1000

-- 기타 제품이 1000만원 넘게 팔렸으므로 특이한 일이니까 확인해보면
-- 로켓배송에서 매출이 나왔다.
SELECT *
FROM "order_batch"
WHERE order_date = '2023-05-15' AND nick = '기타'
Order BY prd_amount_mod DESC

-- 기타 제품을 제외한 매출을 보면
SELECT yymm, yyww, order_date, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y'
GROUP BY yymm, yyww, order_date
Order BY order_date DESC
LIMIT 1000
-- interval 30 days로 지난달과 비교해볼 수 있겠다.


-- 일자, 상품별
SELECT yymm, yyww, order_date, brand, nick, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date, brand, nick
Order BY order_date DESC, price desc
LIMIT 1000

-- 5월 13일에 brand = null인게 있네.
-- 쿠팡 제트배송 이었네.
SELECT *
FROM "order_batch"
WHERE brand IS NULL

SELECT *
FROM "coupang_sales"
WHERE reg_date = '2023-05-13'


-- 일자, 스토어별
SELECT yymm, yyww, order_date, store, SUM(prd_amount_mod) AS price
FROM "order_batch"
GROUP BY yymm, yyww, order_date, store
Order BY order_date DESC, price desc
LIMIT 1000


-- 평균과 변동.
-- 30일 이동평균 매출도 보고,
-- 변동도 구해보고,

-- 매출의 분포도 봐야겠다. 정규분포를 띄고 있을까?
-- 어쩌면 내가 통계분석을 수행하면 데이터에 대한 이해도가 높아질 수 있다.

-- CAGR로 연복리 성장율도 구해보고.

-- 기초적인 통계분석을 진행해보자.
-- 데이터를 혼자 가지고 놀아보자.


-- 신규고객수, 신규매출, 재구매고객수, 재구매매출

-- 명, 건, 개, 액


-- 매핑 누락, 중복 확인

-- 데이터 누락, 중복 확인



-- 네이버 광고


-- 매출 분석을 다각도로 시행한 논문이나 책이 있을 것이다.
-- 그런 책들을 여러권 조사해보면, 내가 매출을 어떻게 파악, 분석해야 하는지 감이 잡힐 것이다.
-- 아, 그리고 마소캠퍼스에서도 몇가지 기법이 나오지.


-- 시중의 여러가지 대시보드 툴이 있을 것이고
-- 그 툴들이 공통적으로 사용하는 지표들을 조사해서 추릴 수 있을 거다.

-- WBR마스터 시트도 매출분석이 상세하게 되어있는 표이다.

-- 비율도 보고 차이도 본다.

-- 매출에는 시간에 따른 변화가 꼭 물려있구나. 매출은 일자가 있을 수 밖에 없으니까.







-- EZ_Order에 스토어 매핑 누락 확인
SELECT DISTINCT shop_name
FROM	"EZ_Order" as o
LEFT JOIN "store" AS s ON (o.shop_id = s.ez_store_code)
WHERE s.ez_store_code IS NULL


