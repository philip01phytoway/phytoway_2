
-- 2023-05-17 1차 미팅


------ db 프로그램 및 계정 정보 ------

Hedisql 다운로드 주소 : https://www.heidisql.com/download.php

ip 주소 : 115.68.228.168
아이디 : fixed_star
비밀번호 : Qnxqkrdlquf859#
포트 : 5432
DB명 : phytogether



SQL의 기본 명령문 4가지

1. SELECT : 조회
2. UPDATE : 수정
3. INSERT : 입력
4. DELETE : 삭제

fixed_star 계정은 SELECT만 할 수 있도록 권한 설정 되었음.

쿼리 실행하는 방법
1. 단축키 : Ctrl + F9 
2. 상단메뉴> 쿼리 > 선택실행

SELECT문 기본 구조 
SELECT 컬럼 FROM 테이블 WHERE 조건 GROUP BY 컬럼 ORDER BY 컬럼 LIMIT 개수

기타 연산자
LIKE, IN, *, NOT IN, NOT LIKE

주석
-- 프로그램 실행에는 영향 x. 참고정보 기입 용도.

데이터 출력하는 방법
1. 상단메뉴 > 도구 > 격자행 내보내기 > 클립보드로 복사
2. 상단메뉴 > 도구 > 격자행 내보내기 > 파일(Excel csv)


---- 샘플 쿼리


-- 1. 매출 관련

-- 1-1. 주문 데이터 조회
SELECT * 
FROM "order_batch" 
LIMIT 10000


-- 1-2. 스토어(판매처) 조회
SELECT DISTINCT store
FROM "order_batch" 


-- 1-3. 제품명 조회
SELECT DISTINCT nick
FROM "order_batch"


-- 1-4. 일별 매출 합계 
SELECT yymm, yyww, order_date, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y' -- 기타 제품 제외하는 조건. 기타 제품 포함 여부 판단 필요.
GROUP BY yymm, yyww, order_date
Order BY order_date DESC


-- 1-5. 일별 주문건수, 고객수, 판매수량, 매출 합계
SELECT yymm, yyww, order_date, SUM(order_cnt) AS order_cnt, COUNT(DISTINCT KEY) AS cust_cnt, SUM(out_qty) AS out_qty, SUM(prd_amount_mod) AS price
FROM "order_batch"
WHERE phytoway = 'y'
GROUP BY yymm, yyww, order_date
Order BY order_date DESC
LIMIT 1000



-- 2. 비용 관련

-- 2-1. 광고 비용
-- 메타 및 구글은 광고 매출에 개선 필요한 상태.
SELECT 	yymm, yyww, yymmdd, channel, account, 
			SUM(cost) AS cost, SUM(imp_cnt) AS imp_cnt, SUM(click_cnt) AS click_cnt, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "ad_batch"
WHERE yymmdd IS NOT NULL
GROUP BY yymm, yyww, yymmdd, channel, account
Order BY yymmdd DESC, channel, account


-- 2-2. 컨텐츠 및 기타 비용
SELECT 	yymm, yyww, yymmdd, channel, brand, nick, page_type,
			SUM(cost1) AS cost1, SUM(cost2) AS cost2, SUM(order_cnt) AS order_cnt, SUM(order_price) AS order_price
FROM "content_batch"
WHERE page_type IN ('블로그', '지식인', '카페', '유튜브', '광고', '소재제작', '리뷰', '사은품')
GROUP BY yymm, yyww, yymmdd, channel, brand, nick, page_type
Order BY yymmdd DESC, channel, nick, page_type





-- 참고 쿼리문 (기존 데이터마트 쿼리문)

-- 컨텐츠 통합 시트 > 자상호여부별 탭
SELECT 	yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type, --Keyword, id,
			SUM(cost1) AS cost1, sum(cost2) AS cost2, sum(pv) AS pv, sum(cc) AS cc, sum(cc2) AS cc2, sum(inflow_cnt) AS inflow_cnt, sum(order_cnt) AS order_cnt, sum(order_price) AS order_price
FROM "content_batch"
WHERE (yymmdd between '2022-10-01' AND '2023-05-17') AND page_type IN ('블로그', '지식인', '카페', '유튜브') AND Channel IN ('네이버', '구글')
GROUP BY yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type--, Keyword, id
Order BY yymm desc, yyww desc, yymmdd DESC, Channel, brand, nick, page_type, owned_keyword_type--, keyword


-- 기타 비용 (마케팅 비용에서 컨텐츠 비용이 아닌 것)
SELECT 	yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type, --Keyword, id,
			SUM(cost1) AS cost1, sum(cost2) AS cost2
FROM "content_batch"
WHERE yymmdd >= '2022-10-01' AND page_type IN ('광고', '소재제작', '리뷰', '사은품')
GROUP BY yymm, yyww, yymmdd, Channel, brand, nick, page_type, owned_keyword_type--, Keyword, id
Order BY yymm desc, yyww desc, yymmdd DESC, Channel, brand, nick, page_type, owned_keyword_type--, keyword



---- 추후 전달 쿼리

-- 1. 재고현황 관련


